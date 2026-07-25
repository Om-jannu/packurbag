export interface RegisterBody {
  username: string;
  password: string;
  userEmail: string;
}

export interface LoginBody {
  userEmail: string;
  password: string;
}

export interface TripBody {
  title: string;
  destination: string;
  startDate: string;
  endDate: string;
  coverColor?: string;
  budgetAmount?: number;
  budgetCurrency?: string;
}

export interface ItineraryItemBody {
  text: string;
  date: string;
  priority?: number;
  location?: string;
}

export interface CompletedStatusBody {
  completed: boolean;
}

export interface PackedStatusBody {
  packed: boolean;
}

export interface PackingItemBody {
  text: string;
  category?: string;
}

export interface ExpenseBody {
  title: string;
  amount: number;
  currency?: string;
  category?: string;
  date?: string;
}

export interface LocationBody {
  lat?: number;
  lng?: number;
  isDiscoverable?: boolean;
}

export interface SendMessageBody {
  senderId: string;
  receiverId: string;
  text: string;
}

export interface AiChatBody {
  message: string;
  history?: { role: "user" | "assistant" | "system"; content: string }[];
  destination?: string;
}

export interface OpenWeatherResponse {
  message?: string;
  main?: { temp: number; feels_like: number };
  weather?: { main: string; description: string; icon: string }[];
  name?: string;
}
