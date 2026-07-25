"use client";

import { useState } from "react";
import {
  ArrowLeft,
  Pencil,
  Plus,
  MapPin,
  Lock,
  Trash2,
  BadgeCheck,
  ScrollText,
  Ticket,
  ChevronRight,
  type LucideIcon,
} from "lucide-react";

export interface ItineraryItemData {
  id: string;
  text: string;
  date: string;
  completed: boolean;
  priority: 0 | 1 | 2 | 3 | 4;
  location?: string;
}

export interface PackingItemData {
  id: string;
  text: string;
  category: string;
  packed: boolean;
}

export interface ExpenseData {
  id: string;
  title: string;
  amount: number;
  currency: string;
  category: string;
}

export interface DocumentData {
  id: string;
  title: string;
  type: "passport" | "visa" | "ticket";
  hasPhoto?: boolean;
}

export interface TripDetailData {
  id: string;
  color: "coral" | "amber" | "teal";
  title: string;
  destination: string;
  dateRange: string;
  budgetAmount: number;
  budgetCurrency: string;
  itinerary: ItineraryItemData[];
  packing: PackingItemData[];
  expenses: ExpenseData[];
  documents: DocumentData[];
}

const TABS = ["Itinerary", "Packing", "Budget", "Documents"] as const;
type Tab = (typeof TABS)[number];

const PACKING_TEMPLATE_NAMES = ["Beach", "Hiking", "Business", "General"];

const PRIORITY_COLORS = ["bg-slate-400", "bg-blue-400", "bg-amber-400", "bg-orange-400", "bg-red-500"];

const DOCUMENT_ICONS: Record<DocumentData["type"], LucideIcon> = {
  passport: BadgeCheck,
  visa: ScrollText,
  ticket: Ticket,
};

const colorClasses = {
  coral: { bg: "bg-coral", text: "text-coral", tint: "bg-coral/15", ring: "ring-coral" },
  amber: { bg: "bg-amber", text: "text-amber", tint: "bg-amber/15", ring: "ring-amber" },
  teal: { bg: "bg-teal", text: "text-teal", tint: "bg-teal/15", ring: "ring-teal" },
};

/**
 * Design-reference mock of the real trip detail screen. Checking items off
 * is a real (local-only) toggle since there's only ever a handful of them —
 * but nothing here actually adds, edits, or deletes list content; those
 * controls stay visible (matching the real screen) without being wired up.
 */
export default function TripDetailMock({
  trip,
  onBack,
}: {
  trip: TripDetailData;
  onBack: () => void;
}) {
  const [tab, setTab] = useState<Tab>("Itinerary");
  const [itinerary, setItinerary] = useState(trip.itinerary);
  const [packing, setPacking] = useState(trip.packing);
  const { expenses, documents } = trip;

  const c = colorClasses[trip.color];

  const toggleItinerary = (id: string) =>
    setItinerary((prev) => prev.map((i) => (i.id === id ? { ...i, completed: !i.completed } : i)));

  const togglePacking = (id: string) =>
    setPacking((prev) => prev.map((i) => (i.id === id ? { ...i, packed: !i.packed } : i)));

  const packedCount = packing.filter((i) => i.packed).length;
  const totalSpent = expenses.reduce((sum, e) => sum + e.amount, 0);
  const remaining = trip.budgetAmount - totalSpent;
  const groupedPacking = packing.reduce<Record<string, PackingItemData[]>>((acc, item) => {
    (acc[item.category] ??= []).push(item);
    return acc;
  }, {});

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      {/* app bar */}
      <div className={`flex items-center gap-2 px-3 pb-2.5 pt-9 ${c.tint}`}>
        <button type="button" onClick={onBack} className="flex h-6 w-6 items-center justify-center">
          <ArrowLeft size={15} className="text-teal-dark" />
        </button>
        <span className="flex-1 text-[12px] font-extrabold text-teal-dark">{trip.title}</span>
        <button type="button" className="flex h-6 w-6 items-center justify-center">
          <Pencil size={13} className="text-teal-dark" />
        </button>
      </div>

      {/* tab bar */}
      <div className="flex border-b border-black/5">
        {TABS.map((t) => (
          <button
            key={t}
            type="button"
            onClick={() => setTab(t)}
            className={`flex-1 border-b-2 py-2 text-[8.5px] font-bold transition-colors ${
              tab === t ? `border-current ${c.text}` : "border-transparent text-black/40"
            }`}
          >
            {t}
          </button>
        ))}
      </div>

      {/* content */}
      <div className="relative flex-1 min-h-0">
        <div className="h-full overflow-y-auto pb-16">
          {tab === "Itinerary" && (
            <div className="px-1 pt-2">
              {itinerary.length === 0 && <EmptyRow text="No itinerary items yet" />}
              {itinerary.map((item) => (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => toggleItinerary(item.id)}
                  className="flex w-full items-start gap-2 px-3 py-2 text-left"
                >
                  <span
                    className={`mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded-full border-2 ${
                      item.completed ? `${c.bg} border-transparent` : "border-black/25"
                    }`}
                  >
                    {item.completed && <span className="h-1.5 w-1.5 rounded-full bg-white" />}
                  </span>
                  <span className="flex-1">
                    <span
                      className={`block font-semibold text-teal-dark ${
                        item.completed ? "text-black/40 line-through" : ""
                      }`}
                    >
                      {item.text}
                    </span>
                    <span className="mt-0.5 flex items-center gap-1.5 text-[8px] text-black/40">
                      <span className={`h-1.5 w-1.5 rounded-full ${PRIORITY_COLORS[item.priority]}`} />
                      {item.date}
                      {item.location && (
                        <>
                          <MapPin size={9} /> {item.location}
                        </>
                      )}
                    </span>
                  </span>
                </button>
              ))}
            </div>
          )}

          {tab === "Packing" && (
            <div className="px-3 pt-2.5">
              <p className="text-[9px] font-bold text-black/50">Quick-apply a template</p>
              <div className="mt-1.5 flex flex-wrap gap-1.5">
                {PACKING_TEMPLATE_NAMES.map((name) => (
                  <button
                    key={name}
                    type="button"
                    className="rounded-full bg-black/[0.04] px-2.5 py-1 text-[8px] font-semibold text-teal-dark"
                  >
                    {name}
                  </button>
                ))}
              </div>

              {packing.length > 0 && (
                <>
                  <div className="mt-2.5 h-1.5 overflow-hidden rounded-full bg-black/10">
                    <div
                      className={`h-full rounded-full ${c.bg}`}
                      style={{ width: `${(packedCount / packing.length) * 100}%` }}
                    />
                  </div>
                  <p className="mt-1 text-[8px] text-black/50">
                    {packedCount} of {packing.length} packed
                  </p>
                </>
              )}

              <div className="mt-2 pb-2">
                {Object.entries(groupedPacking).map(([category, items]) => (
                  <div key={category}>
                    <p className="mt-2 text-[8px] font-bold uppercase tracking-wide text-black/40">
                      {category}
                    </p>
                    {items.map((item) => (
                      <button
                        key={item.id}
                        type="button"
                        onClick={() => togglePacking(item.id)}
                        className="flex w-full items-center gap-2 py-1.5 text-left"
                      >
                        <span
                          className={`flex h-4 w-4 shrink-0 items-center justify-center rounded border-2 ${
                            item.packed ? `${c.bg} border-transparent` : "border-black/25"
                          }`}
                        >
                          {item.packed && <span className="h-1.5 w-1.5 rounded-full bg-white" />}
                        </span>
                        <span
                          className={
                            item.packed ? "text-black/40 line-through" : "font-medium text-teal-dark"
                          }
                        >
                          {item.text}
                        </span>
                      </button>
                    ))}
                  </div>
                ))}
              </div>
            </div>
          )}

          {tab === "Budget" && (
            <div className="px-3 pt-2.5">
              <div className={`rounded-2xl p-3 ${c.tint}`}>
                <p className="text-[8px] font-bold text-black/50">Spent so far</p>
                <p className="mt-0.5 text-[14px] font-extrabold text-teal-dark">
                  {totalSpent.toFixed(0)} {trip.budgetCurrency}
                </p>
                <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-black/10">
                  <div
                    className={`h-full rounded-full ${remaining < 0 ? "bg-red-500" : c.bg}`}
                    style={{ width: `${Math.min(100, (totalSpent / trip.budgetAmount) * 100)}%` }}
                  />
                </div>
                <p className="mt-1 text-[8px] text-black/50">
                  {remaining < 0
                    ? `${Math.abs(remaining).toFixed(0)} ${trip.budgetCurrency} over budget`
                    : `${remaining.toFixed(0)} ${trip.budgetCurrency} remaining of ${trip.budgetAmount}`}
                </p>
              </div>

              <div className="mt-2.5 pb-2">
                {expenses.length === 0 && <EmptyRow text="No expenses logged yet" />}
                {expenses.map((expense) => (
                  <div key={expense.id} className="flex items-center gap-2 py-2">
                    <div className="flex-1">
                      <p className="font-semibold text-teal-dark">{expense.title}</p>
                      <p className="text-[8px] text-black/40">{expense.category}</p>
                    </div>
                    <span className="text-[9px] font-bold text-teal-dark">
                      {expense.amount.toFixed(0)} {expense.currency}
                    </span>
                    <button type="button" className="text-black/20">
                      <Trash2 size={11} />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {tab === "Documents" && (
            <div className="px-3 pt-2.5">
              <div className="flex items-center gap-1.5 text-[8px] text-black/40">
                <Lock size={10} />
                Stored only on this device — never uploaded.
              </div>
              <div className="mt-2 pb-2">
                {documents.length === 0 && <EmptyRow text="No travel documents yet" />}
                {documents.map((doc) => {
                  const Icon = DOCUMENT_ICONS[doc.type];
                  return (
                    <div key={doc.id} className="flex items-center gap-2.5 rounded-xl px-1 py-2">
                      {doc.hasPhoto ? (
                        <span
                          className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-gradient-to-br ${c.bg} to-black/20`}
                        >
                          <Icon size={14} className="text-white" />
                        </span>
                      ) : (
                        <span className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full ${c.tint}`}>
                          <Icon size={14} className={c.text} />
                        </span>
                      )}
                      <span className="flex-1 font-semibold text-teal-dark">{doc.title}</span>
                      <ChevronRight size={13} className="text-black/25" />
                      <button type="button" className="text-black/20">
                        <Trash2 size={11} />
                      </button>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>

        <button
          type="button"
          className={`absolute bottom-3 right-3 z-20 flex h-10 w-10 items-center justify-center rounded-full text-white shadow-lg ${c.bg}`}
        >
          <Plus size={16} />
        </button>
      </div>
    </div>
  );
}

function EmptyRow({ text }: { text: string }) {
  return <p className="px-1 py-6 text-center text-[9px] text-black/35">{text}</p>;
}
