"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

interface CheckinInput {
  status: string;
  projectId: number | null;
  actualHours: number;
  taskDescription: string;
  billable: boolean;
  category: string | null;
  priority: string | null;
  blocker: string | null;
  nextAction: string | null;
  remarks: string | null;
}

export async function saveCheckin(input: CheckinInput): Promise<{ ok: boolean; error?: string }> {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Not signed in." };

  // Pull standard_hours snapshot for variance calc
  const { data: profile } = await supabase
    .from("users").select("standard_hours").eq("id", user.id).maybeSingle();
  const standardHours = profile?.standard_hours ?? 8;

  const today = new Date().toISOString().slice(0, 10);

  // late_entry = was this submitted after 12:00 PM IST?
  const nowIST = new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Kolkata" }));
  const lateEntry = nowIST.getHours() >= 12;

  // Upsert by (user_id, log_date)
  const { error } = await supabase
    .from("daily_logs")
    .upsert({
      user_id: user.id,
      log_date: today,
      status: input.status,
      project_id: input.projectId,
      task_description: input.taskDescription,
      actual_hours: input.actualHours,
      standard_hours: standardHours,
      billable: input.billable,
      category: input.category,
      priority: input.priority,
      blocker: input.blocker,
      next_action: input.nextAction,
      remarks: input.remarks,
      late_entry: lateEntry,
      source: "web",
    }, { onConflict: "user_id,log_date" });

  if (error) return { ok: false, error: error.message };

  revalidatePath("/me");
  revalidatePath("/checkin");
  return { ok: true };
}
