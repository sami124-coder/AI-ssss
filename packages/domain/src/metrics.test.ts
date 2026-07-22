import { describe, expect, it } from 'vitest';
import { calculateFinancialMetrics } from './metrics.js';

describe('calculateFinancialMetrics', () => {
  it('uses decimal-safe arithmetic', () => {
    expect(calculateFinancialMetrics({ grossSales: '100.10', discounts: '0.10', refunds: '10', foodCost: '27', laborCost: '18' })).toEqual({
      netSales: '90.00', grossProfit: '63.00', foodCostRatio: '0.3000', laborCostRatio: '0.2000', missingData: [],
    });
  });
  it('makes missing data explicit and withholds dependent metrics', () => {
    expect(calculateFinancialMetrics({ grossSales: '100' })).toEqual({
      netSales: '100.00', grossProfit: null, foodCostRatio: null, laborCostRatio: null, missingData: ['foodCost', 'laborCost'],
    });
  });
  it('does not divide by zero', () => {
    expect(calculateFinancialMetrics({ grossSales: '0', foodCost: '0' }).foodCostRatio).toBeNull();
  });
  it('rejects impossible negative net sales', () => {
    expect(() => calculateFinancialMetrics({ grossSales: '10', refunds: '11' })).toThrow('Net sales cannot be negative');
  });
});
