import type { Decimal } from 'decimal.js';
import { z } from 'zod';
import { monetary, money, moneyInputSchema, ratio, type MoneyInput } from './money.js';

export const financialInputSchema = z.object({
  grossSales: moneyInputSchema,
  discounts: moneyInputSchema.default('0'),
  refunds: moneyInputSchema.default('0'),
  foodCost: moneyInputSchema.optional(),
  laborCost: moneyInputSchema.optional(),
});

export interface FinancialMetrics {
  netSales: string;
  grossProfit: string | null;
  foodCostRatio: string | null;
  laborCostRatio: string | null;
  missingData: Array<'foodCost' | 'laborCost'>;
}

function safeRatio(numerator: Decimal, denominator: Decimal): string | null {
  return denominator.isZero() ? null : ratio(numerator.dividedBy(denominator));
}

export function calculateFinancialMetrics(raw: {
  grossSales: MoneyInput;
  discounts?: MoneyInput;
  refunds?: MoneyInput;
  foodCost?: MoneyInput;
  laborCost?: MoneyInput;
}): FinancialMetrics {
  const input = financialInputSchema.parse(raw);
  const netSales = money(input.grossSales).minus(money(input.discounts)).minus(money(input.refunds));
  if (netSales.isNegative()) throw new Error('Net sales cannot be negative');
  const foodCost = input.foodCost === undefined ? null : money(input.foodCost);
  const laborCost = input.laborCost === undefined ? null : money(input.laborCost);
  const missingData: FinancialMetrics['missingData'] = [];
  if (foodCost === null) missingData.push('foodCost');
  if (laborCost === null) missingData.push('laborCost');
  return {
    netSales: monetary(netSales),
    grossProfit: foodCost === null ? null : monetary(netSales.minus(foodCost)),
    foodCostRatio: foodCost === null ? null : safeRatio(foodCost, netSales),
    laborCostRatio: laborCost === null ? null : safeRatio(laborCost, netSales),
    missingData,
  };
}
