"use client";

import { useState } from "react";
import { ArrowLeft, User, Mail, Lock } from "lucide-react";

export default function RegisterMock() {
  const [fields, setFields] = useState({ username: "", email: "", password: "", confirm: "" });

  const update = (key: keyof typeof fields) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setFields((prev) => ({ ...prev, [key]: e.target.value }));

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      <div className="flex items-center gap-2 border-b border-black/5 px-4 pb-3 pt-9">
        <ArrowLeft size={15} className="text-teal-dark" />
        <span className="text-[12px] font-extrabold text-teal-dark">Create account</span>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-6 pt-5">
        <p className="text-[14px] font-extrabold text-teal-dark">Create your account</p>

        <div className="mt-5 space-y-3">
          <label className="flex items-center gap-2 rounded-2xl bg-black/[0.04] px-3 py-2.5">
            <User size={13} className="text-black/40" />
            <input
              value={fields.username}
              onChange={update("username")}
              placeholder="Username"
              className="w-full bg-transparent text-[10.5px] text-teal-dark outline-none placeholder:text-black/35"
            />
          </label>
          <label className="flex items-center gap-2 rounded-2xl bg-black/[0.04] px-3 py-2.5">
            <Mail size={13} className="text-black/40" />
            <input
              value={fields.email}
              onChange={update("email")}
              placeholder="Email"
              className="w-full bg-transparent text-[10.5px] text-teal-dark outline-none placeholder:text-black/35"
            />
          </label>
          <label className="flex items-center gap-2 rounded-2xl bg-black/[0.04] px-3 py-2.5">
            <Lock size={13} className="text-black/40" />
            <input
              value={fields.password}
              onChange={update("password")}
              type="password"
              placeholder="Password"
              className="w-full bg-transparent text-[10.5px] text-teal-dark outline-none placeholder:text-black/35"
            />
          </label>
          <label className="flex items-center gap-2 rounded-2xl bg-black/[0.04] px-3 py-2.5">
            <Lock size={13} className="text-black/40" />
            <input
              value={fields.confirm}
              onChange={update("confirm")}
              type="password"
              placeholder="Confirm password"
              className="w-full bg-transparent text-[10.5px] text-teal-dark outline-none placeholder:text-black/35"
            />
          </label>
        </div>

        <button
          type="button"
          className="mt-6 w-full rounded-2xl bg-teal-dark py-3 text-[11px] font-bold text-white"
        >
          Register
        </button>
      </div>
    </div>
  );
}
