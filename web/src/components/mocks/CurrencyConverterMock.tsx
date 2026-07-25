"use client";

import { useState } from "react";
import { ArrowLeft, ArrowUpDown, ChevronDown, Search, X } from "lucide-react";

const CURRENCIES: Record<string, string> = {
  INR: "Indian Rupee",
  USD: "US Dollar",
  EUR: "Euro",
  GBP: "British Pound",
  JPY: "Japanese Yen",
  IDR: "Indonesian Rupiah",
  THB: "Thai Baht",
};

// Rough demo rates (per USD) — good enough for an illustrative conversion.
const USD_RATES: Record<string, number> = {
  INR: 83.2,
  USD: 1,
  EUR: 0.92,
  GBP: 0.79,
  JPY: 156.4,
  IDR: 15850,
  THB: 36.6,
};

export default function CurrencyConverterMock() {
  const [amount, setAmount] = useState("1000");
  const [from, setFrom] = useState("INR");
  const [to, setTo] = useState("USD");
  const [picking, setPicking] = useState<"from" | "to" | null>(null);
  const [search, setSearch] = useState("");
  const [result, setResult] = useState<string | null>(null);

  const convert = () => {
    const value = parseFloat(amount);
    if (Number.isNaN(value)) return;
    const usd = value / USD_RATES[from];
    const converted = usd * USD_RATES[to];
    setResult(`${amount} ${from} = ${converted.toFixed(4)} ${to}`);
  };

  const swap = () => {
    setFrom(to);
    setTo(from);
    setResult(null);
  };

  const filteredCurrencies = Object.entries(CURRENCIES).filter(
    ([code, name]) =>
      code.toLowerCase().includes(search.toLowerCase()) ||
      name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="relative flex h-full flex-col bg-white text-[11px]">
      <div className="flex items-center gap-2 border-b border-black/5 px-4 pb-3 pt-9">
        <ArrowLeft size={15} className="text-teal-dark" />
        <span className="text-[12px] font-extrabold text-teal-dark">Currency Converter</span>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-6 pt-5">
        <label className="block">
          <span className="text-[9px] font-bold text-black/40">Amount</span>
          <input
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            inputMode="decimal"
            className="mt-1 w-full rounded-2xl border border-black/10 px-3 py-2.5 text-[11px] font-semibold text-teal-dark outline-none"
          />
        </label>

        <div className="mt-4 flex items-center gap-2">
          <button
            type="button"
            onClick={() => setPicking("from")}
            className="flex flex-1 items-center justify-between rounded-2xl border border-black/10 px-3 py-2.5"
          >
            <span className="font-bold text-teal-dark">{from}</span>
            <ChevronDown size={13} className="text-black/40" />
          </button>
          <button
            type="button"
            onClick={swap}
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-black/[0.05]"
          >
            <ArrowUpDown size={14} className="text-teal-dark" />
          </button>
          <button
            type="button"
            onClick={() => setPicking("to")}
            className="flex flex-1 items-center justify-between rounded-2xl border border-black/10 px-3 py-2.5"
          >
            <span className="font-bold text-teal-dark">{to}</span>
            <ChevronDown size={13} className="text-black/40" />
          </button>
        </div>

        <button
          type="button"
          onClick={convert}
          className="mt-5 w-full rounded-2xl bg-teal-dark py-3 text-[11px] font-bold text-white"
        >
          Convert
        </button>

        {result && (
          <p className="mt-5 text-center text-[12px] font-bold text-teal-dark">{result}</p>
        )}
      </div>

      {picking && (
        <div className="absolute inset-0 z-30 flex flex-col bg-white">
          <div className="flex items-center gap-2 border-b border-black/5 px-3 py-2.5">
            <Search size={13} className="text-black/40" />
            <input
              autoFocus
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search currencies"
              className="flex-1 bg-transparent text-[10px] text-teal-dark outline-none placeholder:text-black/35"
            />
            <button type="button" onClick={() => setPicking(null)}>
              <X size={14} className="text-black/40" />
            </button>
          </div>
          <div className="flex-1 overflow-y-auto">
            {filteredCurrencies.map(([code, name]) => (
              <button
                key={code}
                type="button"
                onClick={() => {
                  if (picking === "from") setFrom(code);
                  else setTo(code);
                  setPicking(null);
                  setSearch("");
                  setResult(null);
                }}
                className="flex w-full items-center px-4 py-2.5 text-left text-[10.5px] text-teal-dark hover:bg-black/[0.03]"
              >
                <span className="font-bold">{code}</span>
                <span className="ml-2 text-black/50">{name}</span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
