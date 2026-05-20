import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import Nav from "@/components/nav";
import CheckinForm from "./form";
import { getActiveProjects } from "@/lib/data/projects";
import { getTodayLog } from "@/lib/data/logs";

export default async function CheckinPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: appUser } = await supabase
    .from("users")
    .select("id, name, email, role, designation, standard_hours, default_billable")
    .eq("id", user.id).maybeSingle();
  if (!appUser) redirect("/dashboard");

  const projects = await getActiveProjects();
  const todayLog = await getTodayLog(user.id);

  // Pre-fill from yesterday if no log for today exists yet
  let yesterdayLog = null;
  if (!todayLog) {
    const yesterday = new Date(Date.now() - 86400_000).toISOString().slice(0, 10);
    const { data } = await supabase
      .from("daily_logs")
      .select("project_id, status, billable, category, priority")
      .eq("user_id", user.id)
      .eq("log_date", yesterday)
      .maybeSingle();
    yesterdayLog = data;
  }

  return (
    <div className="min-h-screen">
      <Nav user={appUser} />
      <main className="max-w-2xl mx-auto px-4 py-8 sm:py-12">
        <h1 className="text-2xl sm:text-3xl font-bold text-binary-700">Daily Check-in</h1>
        <p className="text-sm text-gray-500 mt-1">
          {todayLog ? "Edit your check-in for today." : "Add your check-in for today. Takes ~30 seconds."}
        </p>
        <CheckinForm
          appUser={appUser}
          projects={projects}
          existingLog={todayLog}
          yesterdayLog={yesterdayLog}
        />
      </main>
    </div>
  );
}
