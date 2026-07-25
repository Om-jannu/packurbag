import mongoose, { Schema, Document, Types } from "mongoose";
import bcrypt from "bcrypt";

export interface ItineraryItem {
  text: string;
  date: Date;
  completed: boolean;
  priority: number;
  location: string;
  dateOfCreation?: Date;
}

export interface PackingItem {
  text: string;
  category: string;
  packed: boolean;
}

export interface Expense {
  title: string;
  amount: number;
  currency: string;
  category: string;
  date: Date;
}

export interface Trip {
  title: string;
  destination: string;
  startDate: Date;
  endDate: Date;
  coverColor: string;
  budgetAmount?: number;
  budgetCurrency: string;
  itinerary: Types.DocumentArray<ItineraryItem>;
  packingItems: Types.DocumentArray<PackingItem>;
  expenses: Types.DocumentArray<Expense>;
}

export interface UserDocument extends Document {
  username: string;
  userEmail: string;
  password: string;
  trips: Types.DocumentArray<Trip>;
  location: {
    type: "Point";
    coordinates: [number, number];
  };
  locationUpdatedAt?: Date;
  isDiscoverable: boolean;
  comparePassword(candidatePassword: string): Promise<boolean>;
}

const itineraryItemSchema = {
  text: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  completed: {
    type: Boolean,
    default: false,
  },
  priority: {
    type: Number,
    default: 0,
  },
  location: {
    type: String,
    default: "",
  },
  dateOfCreation: {
    type: Date,
  },
};

const packingItemSchema = {
  text: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    default: "General",
  },
  packed: {
    type: Boolean,
    default: false,
  },
};

const expenseSchema = {
  title: {
    type: String,
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  currency: {
    type: String,
    default: "INR",
  },
  category: {
    type: String,
    default: "Other",
  },
  date: {
    type: Date,
    default: Date.now,
  },
};

const tripSchema = {
  title: {
    type: String,
    required: true,
  },
  destination: {
    type: String,
    required: true,
  },
  startDate: {
    type: Date,
    required: true,
  },
  endDate: {
    type: Date,
    required: true,
  },
  coverColor: {
    type: String,
    default: "FF6B4A",
  },
  budgetAmount: {
    type: Number,
  },
  budgetCurrency: {
    type: String,
    default: "INR",
  },
  itinerary: {
    type: [itineraryItemSchema],
    default: [],
  },
  packingItems: {
    type: [packingItemSchema],
    default: [],
  },
  expenses: {
    type: [expenseSchema],
    default: [],
  },
};

const userSchema = new Schema<UserDocument>({
  username: {
    type: String,
    required: true,
  },
  userEmail: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  trips: {
    type: [tripSchema],
    default: [],
  },
  location: {
    type: {
      type: String,
      enum: ["Point"],
      default: "Point",
    },
    coordinates: {
      type: [Number],
      default: [0, 0],
    },
  },
  locationUpdatedAt: {
    type: Date,
  },
  isDiscoverable: {
    type: Boolean,
    default: false,
  },
});

userSchema.index({ location: "2dsphere" });

const SALT_ROUNDS = 12;

userSchema.pre("save", async function () {
  if (!this.isModified("password")) return;
  this.password = await bcrypt.hash(this.password, SALT_ROUNDS);
});

userSchema.methods.comparePassword = function (
  this: UserDocument,
  candidatePassword: string
) {
  return bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model<UserDocument>("User", userSchema);
export default User;
