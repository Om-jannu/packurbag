"use client";

import { useState } from "react";
import { MapPin, Plus } from "lucide-react";
import PhoneNavBar, { type NavTab } from "./PhoneNavBar";
import SpeedDialFab from "./SpeedDialFab";
import TripDetailMock, { type TripDetailData } from "./TripDetailMock";

const initialTrips: TripDetailData[] = [
  {
    id: "bali",
    color: "coral",
    title: "Bali Getaway",
    destination: "Bali, Indonesia",
    dateRange: "1 Sep – 10 Sep",
    budgetAmount: 50000,
    budgetCurrency: "INR",
    itinerary: [
      { id: "i1", text: "Visit temple", date: "2 Sep", completed: false, priority: 3, location: "Uluwatu" },
      { id: "i2", text: "Surf lesson", date: "3 Sep", completed: true, priority: 2 },
      { id: "i3", text: "Rice terrace hike", date: "4 Sep", completed: false, priority: 1 },
    ],
    packing: [
      { id: "p1", text: "Swimsuit", category: "Clothing", packed: true },
      { id: "p2", text: "Sunscreen", category: "Toiletries", packed: true },
      { id: "p3", text: "Passport", category: "Documents", packed: false },
    ],
    expenses: [
      { id: "e1", title: "Hotel", amount: 18000, currency: "INR", category: "Stay" },
      { id: "e2", title: "Flights", amount: 14000, currency: "INR", category: "Transport" },
    ],
    documents: [
      { id: "d1", title: "Passport", type: "passport" },
      { id: "d2", title: "Flight ticket", type: "ticket" },
    ],
  },
  {
    id: "kerala",
    color: "amber",
    title: "Kerala Backwaters",
    destination: "Kerala, India",
    dateRange: "1 Oct – 5 Oct",
    budgetAmount: 25000,
    budgetCurrency: "INR",
    itinerary: [
      { id: "i4", text: "Houseboat check-in", date: "1 Oct", completed: false, priority: 3 },
      { id: "i5", text: "Book train tickets", date: "4 Oct", completed: false, priority: 2 },
    ],
    packing: [{ id: "p4", text: "Mosquito repellent", category: "Toiletries", packed: false }],
    expenses: [{ id: "e3", title: "Houseboat", amount: 5000, currency: "INR", category: "Stay" }],
    documents: [{ id: "d3", title: "ID proof", type: "passport" }],
  },
  {
    id: "tokyo",
    color: "teal",
    title: "Tokyo Adventure",
    destination: "Tokyo, Japan",
    dateRange: "12 Dec – 20 Dec",
    budgetAmount: 90000,
    budgetCurrency: "INR",
    itinerary: [],
    packing: [],
    expenses: [{ id: "e4", title: "Visa fee", amount: 4500, currency: "INR", category: "Other" }],
    documents: [{ id: "d4", title: "Visa", type: "visa" }],
  },
];

const STATUS_LABELS: Record<string, string> = {
  bali: "In 12 days",
  kerala: "In 43 days",
  tokyo: "In 106 days",
};

const NEW_TRIP_TEMPLATE: Omit<TripDetailData, "id"> = {
  color: "coral",
  title: "Goa Weekend",
  destination: "Goa, India",
  dateRange: "14 Nov – 16 Nov",
  budgetAmount: 15000,
  budgetCurrency: "INR",
  itinerary: [],
  packing: [],
  expenses: [],
  documents: [],
};

const badgeClasses: Record<TripDetailData["color"], string> = {
  coral: "bg-coral/10 text-coral",
  amber: "bg-amber/10 text-amber",
  teal: "bg-teal/10 text-teal",
};

const barClasses: Record<TripDetailData["color"], string> = {
  coral: "bg-coral",
  amber: "bg-amber",
  teal: "bg-teal",
};

interface TripsMockProps {
  onNavigate?: (tab: NavTab) => void;
}

export default function TripsMock({ onNavigate }: TripsMockProps) {
  const [trips, setTrips] = useState(initialTrips);
  const [statuses, setStatuses] = useState(STATUS_LABELS);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const addTrip = () => {
    if (trips.length >= 5) return;
    const id = `new-${trips.length}`;
    setTrips((prev) => [{ ...NEW_TRIP_TEMPLATE, id }, ...prev]);
    setStatuses((prev) => ({ ...prev, [id]: "In 78 days" }));
  };

  const selectedTrip = trips.find((t) => t.id === selectedId);
  if (selectedTrip) {
    return <TripDetailMock trip={selectedTrip} onBack={() => setSelectedId(null)} />;
  }

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      <div className="flex items-center justify-between border-b border-black/5 px-4 pb-3 pt-9">
        <span className="text-[13px] font-extrabold text-teal-dark">My Trips</span>
        <button
          type="button"
          onClick={addTrip}
          className="flex h-6 w-6 items-center justify-center rounded-full bg-teal/10 transition hover:bg-teal/20"
        >
          <Plus size={13} className="text-teal" />
        </button>
      </div>

      <div className="relative flex-1 min-h-0">
        <div className="h-full space-y-2.5 overflow-y-auto px-3 pb-20 pt-3">
          {trips.map((trip) => (
            <button
              key={trip.id}
              type="button"
              onClick={() => setSelectedId(trip.id)}
              className="flex w-full items-center gap-2.5 rounded-2xl bg-black/[0.03] p-2.5 text-left transition hover:bg-black/[0.05]"
            >
              <div className={`h-10 w-1.5 shrink-0 rounded-full ${barClasses[trip.color]}`} />
              <div className="flex-1">
                <p className="text-[11px] font-bold text-teal-dark">{trip.title}</p>
                <div className="mt-0.5 flex items-center gap-1 text-[9px] text-black/50">
                  <MapPin size={9} />
                  {trip.destination}
                </div>
                <p className="mt-0.5 text-[8px] text-black/40">{trip.dateRange}</p>
              </div>
              <span className={`rounded-lg px-2 py-1 text-[8px] font-bold ${badgeClasses[trip.color]}`}>
                {statuses[trip.id] ?? "Upcoming"}
              </span>
            </button>
          ))}
        </div>

        <SpeedDialFab onAction={(action) => action === "newTrip" && addTrip()} />
      </div>

      <PhoneNavBar active="trips" enabled={onNavigate ? ["home", "nearby"] : []} onSelect={onNavigate} />
    </div>
  );
}
