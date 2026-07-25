import { Hono } from "hono";
import User from "../models/userSchema";
import type { ExpenseBody } from "../types/requests";

export const expensesRoutes = new Hono();

expensesRoutes.get("/:userId/:tripId/expenses", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    return c.json({ success: true, message: "Expenses found", data: trip.expenses });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error fetching expenses" }, 500);
  }
});

expensesRoutes.post("/:userId/:tripId/expenses", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    trip.expenses.push((await c.req.json<ExpenseBody>()) as never);
    await user!.save();
    return c.json({ success: true, message: "Expense added" }, 201);
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error adding expense" }, 500);
  }
});

expensesRoutes.delete("/:userId/:tripId/expenses/:expenseId", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const expense = trip.expenses.id(c.req.param("expenseId"));
    if (!expense) {
      return c.json({ success: false, message: "Expense not found" }, 404);
    }
    expense.deleteOne();
    await user!.save();
    return c.json({ success: true, message: "Expense deleted" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error deleting expense" }, 500);
  }
});
