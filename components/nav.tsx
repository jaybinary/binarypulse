"use client";
import { AppUser } from "@/lib/types";

export default function Nav({ user }: { user: Partial<AppUser> }) {
  return (
    <nav className="bg-white border-b border-binary-100">
      <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
        <span className="font-bold text-binary-700">BinaryPulse</span>
        <div className="flex items-center gap-3 text-sm">
          <span className="text-gray-600">{user.name}</span>
          <span className="px-2 py-0.5 rounded bg-binary-50 text-binary-700 text-xs capitalize">{user.role}</span>
          <form action="/auth/signout" method="post">
            <button className="text-gray-500 hover:text-binary-700 text-xs">Sign out</button>
          </form>
        </div>
      </div>
    </nav>
  );
}
