"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { saveCheckin } from "./actions";

interface Project { id: number; code: string; name: string; billable: boolean; }
interface AppUser {
  id: string; name: string; email: string; role: string;
  designation: string | null; standard_hours: number; default_billable: boolean;
}
interface Log {
  status?: string; project_id?: number | null; task_description?: string | null;
  actual_hours?: number | null; category?: string | null; priority?: string | null;
  billable?: boolean | null; blocker?: string | null; next_action?: string | null;
  remarks?: string | null;
}

const STATUSES = [
  ["having_task",     "Having Task"],
  ["no_task",         "No Task"],
  ["research",        "Research"],
  ["internal_work",   "Internal Work"],
  ["waiting_client",  "Waiting for Client"],
  ["waiting_pm",      "Waiting for PM"],
  ["qa_review",       "QA Review"],
  ["deployment",      "Deployment"],
  ["leave",           "Leave"],
  ["training",        "Training"],
];
const CATEGORIES = [
  "development","design","qa","research","meeting",
  "client_support","internal_rd","catalog","admin","marketing"
];
const PRIORITIES = ["P1","P2","P3"];

export default function CheckinForm({
  appUser, projects, existingLog, yesterdayLog
}: { appUser: AppUser; projects: Project[]; existingLog: Log | null; yesterdayLog: Log | null; }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const initial = existingLog ?? yesterdayLog ?? {};
  const [status, setStatus] = useState<string>(initial.status ?? "having_task");
  const [projectId, setProjectId] = useState<string>(String(initial.project_id ?? ""));
  const [hours, setHours] = useState<string>(String(existingLog?.actual_hours ?? appUser.standard_hours ?? 8));
  const [task, setTask] = useState<string>(existingLog?.task_description ?? "");
  const [billable, setBillable] = useState<boolean>(existingLog?.billable ?? appUser.default_billable ?? true);
  const [category, setCategory] = useState<string>(existingLog?.category ?? "");
  const [priority, setPriority] = useState<string>(existingLog?.priority ?? "");
  const [blocker, setBlocker] = useState<string>(existingLog?.blocker ?? "");
  const [nextAction, setNextAction] = useState<string>(existingLog?.next_action ?? "");
  const [remarks, setRemarks] = useState<string>(existingLog?.remarks ?? "");

  const isOffDay = status === "leave" || status === "training";
  const needsBlocker = ["no_task","waiting_client","waiting_pm"].includes(status);

  function submit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!isOffDay && status === "having_task" && !projectId) {
      setError("Pick a project for 'Having Task'.");
      return;
    }
    if (!task.trim()) { setError("Today's task description is required."); return; }
    if (needsBlocker && (!blocker.trim() || !nextAction.trim())) {
      setError("Blocker and Next Action are required when waiting / no task.");
      return;
    }

    startTransition(async () => {
      const res = await saveCheckin({
        status, projectId: projectId ? Number(projectId) : null,
        actualHours: Number(hours), taskDescription: task, billable,
        category: category || null, priority: priority || null,
        blocker: blocker || null, nextAction: nextAction || null, remarks: remarks || null,
      });
      if (res.ok) {
        setSuccess(true);
        setTimeout(() => router.push("/me"), 800);
      } else {
        setError(res.error ?? "Could not save. Try again.");
      }
    });
  }

  return (
    <form onSubmit={submit} className="mt-8 space-y-5 bg-white border border-binary-100 rounded-xl p-5 sm:p-7 shadow-sm">

      {/* Status */}
      <div>
        <Label>Status</Label>
        <select value={status} onChange={e => setStatus(e.target.value)} className={inputClass}>
          {STATUSES.map(([v,l]) => <option key={v} value={v}>{l}</option>)}
        </select>
      </div>

      {/* Project */}
      {!isOffDay && (
        <div>
          <Label>Project</Label>
          <select value={projectId} onChange={e => setProjectId(e.target.value)} className={inputClass}>
            <option value="">— Select project —</option>
            {projects.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
          </select>
        </div>
      )}

      {/* Hours */}
      <div>
        <Label>Hours worked <span className="text-gray-400 font-normal">(0–12, you're standard at {appUser.standard_hours})</span></Label>
        <input type="number" min={0} max={12} step={0.5} value={hours} onChange={e => setHours(e.target.value)} className={inputClass} required />
      </div>

      {/* Task */}
      <div>
        <Label>Today's task</Label>
        <textarea value={task} onChange={e => setTask(e.target.value)} rows={3} placeholder="What did you work on?" className={inputClass} required />
      </div>

      {/* Billable */}
      {!isOffDay && (
        <div className="flex items-center gap-3">
          <input type="checkbox" id="bill" checked={billable} onChange={e => setBillable(e.target.checked)} className="h-4 w-4 rounded text-binary-700" />
          <label htmlFor="bill" className="text-sm text-gray-700">Billable</label>
        </div>
      )}

      {/* Optional grid: Category, Priority */}
      {!isOffDay && (
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Category <Optional/></Label>
            <select value={category} onChange={e => setCategory(e.target.value)} className={inputClass}>
              <option value="">—</option>
              {CATEGORIES.map(c => <option key={c} value={c}>{c.replace("_"," ")}</option>)}
            </select>
          </div>
          <div>
            <Label>Priority <Optional/></Label>
            <select value={priority} onChange={e => setPriority(e.target.value)} className={inputClass}>
              <option value="">—</option>
              {PRIORITIES.map(p => <option key={p} value={p}>{p}</option>)}
            </select>
          </div>
        </div>
      )}

      {/* Blocker fields (highlighted when needed) */}
      {(needsBlocker || blocker) && (
        <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 space-y-3">
          <div>
            <Label>Blocker / Reason {needsBlocker && <Required/>}</Label>
            <textarea value={blocker} onChange={e => setBlocker(e.target.value)} rows={2} className={inputClass} placeholder="What's stopping you?" />
          </div>
          <div>
            <Label>Next Action {needsBlocker && <Required/>}</Label>
            <textarea value={nextAction} onChange={e => setNextAction(e.target.value)} rows={2} className={inputClass} placeholder="What's the unblocker?" />
          </div>
        </div>
      )}

      {/* Remarks */}
      <div>
        <Label>Remarks <Optional/></Label>
        <input type="text" value={remarks} onChange={e => setRemarks(e.target.value)} className={inputClass} />
      </div>

      {/* Errors / Success */}
      {error && <div className="bg-red-50 border border-red-200 rounded-lg px-3 py-2 text-sm text-red-700">{error}</div>}
      {success && <div className="bg-green-50 border border-green-200 rounded-lg px-3 py-2 text-sm text-green-700">Saved. Redirecting to your dashboard…</div>}

      {/* Submit */}
      <div className="pt-2">
        <button type="submit" disabled={isPending}
          className="w-full sm:w-auto px-6 py-3 rounded-lg bg-binary-700 text-white font-medium hover:bg-binary-900 transition disabled:opacity-50">
          {isPending ? "Saving…" : existingLog ? "Update check-in" : "Save check-in"}
        </button>
      </div>
    </form>
  );
}

const inputClass = "mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-binary-500 focus:border-binary-500 outline-none text-sm";
function Label({ children }: { children: React.ReactNode }) {
  return <label className="block text-sm font-medium text-gray-700">{children}</label>;
}
function Required() { return <span className="text-red-500 ml-1">*</span>; }
function Optional() { return <span className="text-gray-400 font-normal text-xs ml-1">(optional)</span>; }
