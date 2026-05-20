import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import Link from "next/link";
import Nav from "@/components/nav";
import { getRecentLogs, getMyStats, getTodayLog } from "@/lib/data/logs";

export default async function MePage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: appUser } = await supabase
    .from("users")
    .select("id, name, email, role, designation, standard_hours")
    .eq("id", user.id).maybeSingle();
  if (!appUser) redirect("/dashboard");

  const stats = await getMyStats(user.id);
  const logs = await getRecentLogs(user.id, 30);
  const todayLog = await getTodayLog(user.id);

  const utilColor = (u: number) => u >= 0.8 ? "bg-green-100 text-green-800" : u >= 0.6 ? "bg-amber-100 text-amber-800" : "bg-red-100 text-red-800";

  return (
    <div className="min-h-screen">
      <Nav user={appUser} />
      <main className="max-w-5xl mx-auto px-4 py-8">
        <div className="flex items-end justify-between flex-wrap gap-3">
          <div>
            <h1 className="text-2xl sm:text-3xl font-bold text-binary-700">My Dashboard</h1>
            <p className="text-sm text-gray-500 mt-1 capitalize">{appUser.role} · {appUser.designation ?? "—"}</p>
          </div>
          <Link href="/checkin" className="inline-block px-5 py-2.5 rounded-lg bg-binary-700 text-white text-sm font-medium hover:bg-binary-900 transition">
            {todayLog ? "Edit today's check-in" : "+ Add today's check-in"}
          </Link>
        </div>

        {/* Stats row */}
        {stats && (
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-7">
            <StatCard label="Days logged (30d)" value={String(stats.daysLogged)} />
            <StatCard label="Having Task" value={String(stats.havingTaskDays)} />
            <StatCard label="Utilisation" value={`${Math.round(stats.utilisation * 100)}%`}
              badgeClass={utilColor(stats.utilisation)} />
            <StatCard label="Efficiency (hrs)" value={`${Math.round(stats.efficiency * 100)}%`} />
          </div>
        )}

        {/* Recent logs */}
        <section className="mt-10">
          <h2 className="text-lg font-semibold text-binary-700 mb-3">Last 30 days</h2>
          {logs.length === 0 ? (
            <div className="bg-white border border-dashed border-binary-200 rounded-xl p-8 text-center">
              <p className="text-sm text-gray-500">No check-ins yet.</p>
              <Link href="/checkin" className="mt-3 inline-block text-sm font-medium text-binary-700 hover:underline">Add your first check-in →</Link>
            </div>
          ) : (
            <div className="bg-white border border-binary-100 rounded-xl overflow-hidden">
              <table className="w-full text-sm">
                <thead className="bg-binary-50 text-binary-700">
                  <tr>
                    <Th>Date</Th><Th>Status</Th><Th>Project</Th><Th>Task</Th><Th align="right">Hrs</Th><Th align="right">Var</Th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {logs.map(l => (
                    <tr key={l.id} className="hover:bg-gray-50">
                      <Td>{l.log_date}</Td>
                      <Td><StatusPill status={l.status as string} /></Td>
                      <Td>{(l as any).projects?.name ?? "—"}</Td>
                      <Td className="max-w-xs truncate" title={l.task_description ?? ""}>{l.task_description}</Td>
                      <Td align="right">{l.hours ?? "—"}</Td>
                      <Td align="right" className={l.variance_hours && Number(l.variance_hours) < 0 ? "text-red-600" : Number(l.variance_hours ?? 0) > 0 ? "text-green-700" : "text-gray-500"}>
                        {l.variance_hours == null ? "—" : (Number(l.variance_hours) > 0 ? "+" : "") + l.variance_hours}
                      </Td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </main>
    </div>
  );
}

function StatCard({ label, value, badgeClass }: { label: string; value: string; badgeClass?: string }) {
  return (
    <div className="bg-white border border-binary-100 rounded-xl p-4">
      <p className="text-xs text-gray-500 uppercase tracking-wide">{label}</p>
      <p className={`text-2xl font-bold mt-1 inline-block px-2 rounded ${badgeClass ?? "text-binary-700"}`}>{value}</p>
    </div>
  );
}
function Th({ children, align }: { children: React.ReactNode; align?: "right" }) {
  return <th className={`px-3 py-2 text-${align ?? "left"} font-medium uppercase text-xs`}>{children}</th>;
}
function Td({ children, align, className, title }: any) {
  return <td title={title} className={`px-3 py-2 text-${align ?? "left"} ${className ?? ""}`}>{children}</td>;
}
const STATUS_COLORS: Record<string,string> = {
  having_task:     "bg-green-100 text-green-800",
  no_task:         "bg-red-100 text-red-800",
  leave:           "bg-red-100 text-red-800",
  waiting_client:  "bg-amber-100 text-amber-800",
  waiting_pm:      "bg-amber-100 text-amber-800",
  research:        "bg-blue-100 text-blue-800",
  internal_work:   "bg-blue-100 text-blue-800",
  qa_review:       "bg-purple-100 text-purple-800",
  deployment:      "bg-purple-100 text-purple-800",
  training:        "bg-gray-100 text-gray-700",
};
function StatusPill({ status }: { status: string }) {
  const cls = STATUS_COLORS[status] ?? "bg-gray-100 text-gray-700";
  return <span className={`inline-block px-2 py-0.5 rounded text-xs ${cls}`}>{status.replace("_"," ")}</span>;
}
