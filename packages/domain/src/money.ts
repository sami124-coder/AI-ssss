import { Decimal } from 'decimal.js';
import { z } from 'zod';

Decimal.set({ precision: 28, rounding: Decimal.ROUND_HALF_UP });

export const moneyInputSchema = z.union([z.string(), z.number()]).refine(
  (value) => {
    try { return new Decimal(value).isFinite(); } catch { return false; }
  },
  'Invalid monetary amount',
);

export type MoneyInput = z.infer<typeof moneyInputSchema>;

export function money(value: MoneyInput): Decimal {
  return new Decimal(moneyInputSchema.parse(value));
}

export function monetary(value: Decimal): string {
  return value.toDecimalPlaces(2).toFixed(2);
}

export function ratio(value: Decimal): string {
  return value.toDecimalPlaces(4).toFixed(4);
}
