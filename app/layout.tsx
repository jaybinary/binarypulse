import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "BinaryPulse",
  description: "Resource utilisation & talent intelligence for Binary"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen">{children}</body>
    </html>
  );
}
