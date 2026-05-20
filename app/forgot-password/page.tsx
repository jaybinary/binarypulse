"use client";

import { createClient } from "@/lib/supabase/client";
import { useState } from "react";
import Link from "next/link";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  async function reset(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true); setError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`
    });
    if (error) { setError(error.message); setLoading(false); return; }
    setSent(true); setLoading(false);
  }

  if (sent) {
    return (
      <main className="min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md text-center bg-white rounded-2xl shadow-xl border border-binary-100 p-10">
          <h2 className="text-2xl font-bold text-binary-700 mb-3">Reset email sent</h2>
          <p className="text-sm text-gray-600 mb-6">
            If <span className="font-medium">{email}</span> exists in our system, you'll get a reset link in your inbox.
          </p>
          <Link href="/login" className="text-sm text-binary-700 hover:underline font-medium">← Back to sign in</Link>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen flex items-center justify-center bg-gradient-to-br from-binary-50 to-white px-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-binary-100 p-8 sm:p-10">
        <h1 className="text-2xl font-bold text-binary-700 mb-2">Forgot password?</h1>
        <p className="text-sm text-gray-500 mb-6">Enter your email and we'll send you a reset link.</p>

        <form onSubmit={reset} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Work email</label>
            <input type="email" required value={email} onChange={e => setEmail(e.target.value)}
              placeholder="you@binaryic.in"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-binary-500 focus:border-binary-500 outline-none" />
          </div>

          {error && <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2">{error}</div>}

          <button type="submit" disabled={loading}
            className="w-full px-6 py-3 rounded-lg bg-binary-700 text-white font-medium hover:bg-binary-900 transition disabled:opacity-50">
            {loading ? "Sending…" : "Send reset link"}
          </button>
        </form>

        <div className="mt-6 text-center text-sm">
          <Link href="/login" className="text-binary-700 font-medium hover:underline">← Back to sign in</Link>
        </div>
      </div>
    </main>
  );
}
