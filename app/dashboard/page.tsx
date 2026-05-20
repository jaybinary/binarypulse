import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import Nav from "@/components/nav";

export default async function DashboardPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Try to read app user row — will succeed only if RLS lets us (allow-list)
  const { data: appUser, error } = await supabase
    .from("users").select("id, name, email, role, designation, department_id, standard_hours, active")
    .eq("id", user.id).maybeSingle();

  if (error || !appUser) {
    return (
      <main className="min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md text-center">
          <h1 className="text-2xl font-bold text-binary-700 mb-3">Not on the allow-list</h1>
          <p className="text-sm text-gray-600 mb-6">
            Your account <span className="font-medium">{user.email}</span> isn't enrolled in BinaryPulse yet.
            Please ask Jayesh to add you.
          </p>
          <form action="/auth/signout" method="post">
            <button className="px-4 py-2 rounded bg-gray-100 hover:bg-gray-200 text-sm">Sign out</button>
          </form>
        </div>
      </main>
    );
  }

  return (
    <div className="min-h-screen">
      <Nav user={appUser} />
      <main className="max-w-6xl mx-auto px-4 py-10">
        <h1 className="text-3xl font-bold text-binary-700">Welcome, {appUser.name.split(" ")[0]}</h1>
        <p className="text-sm text-gray-500 mt-1 capitalize">{appUser.role} · {appUser.designation ?? "—"}</p>

        <div className="grid md:grid-cols-3 gap-4 mt-10">
          <Card title="Daily Check-in" subtitle="Coming Week 2" />
          <Card title="My Dashboard" subtitle="Coming Week 2" />
          <Card title="Team View" subtitle="Coming Week 3" />
        </div>

        <div className="mt-12 text-xs text-gray-400">
          Build: scaffold v0.1 · authenticated as {appUser.email}
        </div>
      </main>
    </div>
  );
}

function Card({ title, subtitle }: { title: string; subtitle: string }) {
  return (
    <div className="bg-white border border-binary-100 rounded-xl p-6">
      <h3 className="font-semibold text-binary-700">{title}</h3>
      <p className="text-xs text-gray-500 mt-1">{subtitle}</p>
    </div>
  );
}
