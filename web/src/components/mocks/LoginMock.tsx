"use client";

import { useState } from "react";
import Image from "next/image";
import { Mail, Lock, Eye, EyeOff } from "lucide-react";

export default function LoginMock() {
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  return (
    <div className="flex h-full flex-col overflow-y-auto bg-white px-5 pb-6 pt-12 text-[11px]">
      <div className="mx-auto flex h-28 w-full items-center justify-center rounded-2xl bg-teal/10">
        <Image src="/packurbag-logo.png" alt="" width={44} height={44} />
      </div>

      <p className="mt-4 text-center text-[15px] font-extrabold text-teal-dark">Welcome back</p>

      <div className="mt-6 space-y-3">
        <label className="flex items-center gap-2 rounded-2xl bg-black/[0.04] px-3 py-2.5">
          <Mail size={13} className="text-black/40" />
          <input
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="Email"
            className="w-full bg-transparent text-[10.5px] text-teal-dark outline-none placeholder:text-black/35"
          />
        </label>
        <label className="flex items-center gap-2 rounded-2xl bg-black/[0.04] px-3 py-2.5">
          <Lock size={13} className="text-black/40" />
          <input
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            type={showPassword ? "text" : "password"}
            placeholder="Password"
            className="w-full bg-transparent text-[10.5px] text-teal-dark outline-none placeholder:text-black/35"
          />
          <button type="button" onClick={() => setShowPassword((s) => !s)}>
            {showPassword ? (
              <EyeOff size={13} className="text-black/40" />
            ) : (
              <Eye size={13} className="text-black/40" />
            )}
          </button>
        </label>
      </div>

      <button
        type="button"
        className="mt-5 rounded-2xl bg-teal-dark py-3 text-[11px] font-bold text-white"
      >
        Sign In
      </button>

      <div className="mt-5 flex items-center justify-center gap-1 text-[9.5px]">
        <span className="text-black/50">Don&apos;t have an account?</span>
        <span className="font-bold text-teal">Register</span>
      </div>
    </div>
  );
}
