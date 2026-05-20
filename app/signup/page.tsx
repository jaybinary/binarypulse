"use client";

import { createClient } from "@/lib/supabase/client";
import { useState } from "react";
import Link from "next/link";

export default function SignupPage() {
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  async function signUp(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (password !== confirm) { setError("Passwords don't match."); return; }
    if (password.length < 8) { setError("Password must be at least 8 characters."); return; }
    if (!email.endsWith("@binaryic.in")) { setError("Only @binaryic.in emails are allowed."); return; }

    setLoading(true);
    const supabase = createClient();
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: name },
        emailRedirectTo: `${window.location.origin}/auth/callback`
      }
    });

    if (error) { setError(error.message); setLoading(false); return; }
    setSuccess(true); setLoading(false);
  }

  if (success) {
    return (
      <main className="min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md text-center bg-white rounded-2xl shadow-xl border border-binary-100 p-10">
          <h2 className="text-2xl font-bold text-binary-700 mb-3">Check your inbox</h2>
          <p className="text-sm text-gray-600 mb-6">
            We sent a confirmation email to <span className="font-medium">{email}</span>.
            Click the link in that email to activate your account, then come back here to sign in.
          </p>
          <Link href="/login" className="text-sm text-binary-700 hover:underline font-medium">← Back to sign in</Link>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen flex items-center justify-center bg-gradient-to-br from-binary-50 to-white px-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-binary-100 p-8 sm:p-10">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-binary-700">Create account</h1>
          <p className="text-sm text-gray-500 mt-1">For allow-listed @binaryic.in employees</p>
        </div>

        <form onSubmit={signUp} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Full name</label>
            <input type="text" required value={name} onChange={e => setName(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-binary-500 focus:border-binary-500 outline-none" />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Work email</label>
            <input type="email" required value={email} onChange={e => setEmail(e.target.value)}
              placeholder="you@binaryic.in"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-binary-500 focus:border-binary-500 outline-none" />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input type="password" required value={password} onChange={e => setPassword(e.target.value)}
              placeholder="At least 8 characters"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-binary-500 focus:border-binary-500 outline-none" />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Confirm password</label>
            <input type="password" required value={confirm} onChange={e => setConfirm(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-binary-500 focus:border-binary-500 outline-none" />
          </div>

          {error && <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2">{error}</div>}

          <button type="submit" disabled={loading}
            className="w-full px-6 py-3 rounded-lg bg-binary-700 text-white font-medium hover:bg-binary-900 transition disabled:opacity-50">
            {loading ? "Creating account…" : "Create account"}
          </button>
        </form>

        <div className="mt-6 text-center text-sm">
          <span className="text-gray-500">Already have an account? </span>
          <Link href="/login" className="text-binary-700 font-medium hover:underline">Sign in</Link>
        </div>
      </div>
    </main>
  );
}
