import { describe, expect, it } from 'vitest';
import { healthResponseSchema } from './health.js';

describe('healthResponseSchema', () => {
  it('accepts a valid health response', () => {
    expect(
      healthResponseSchema.parse({
        status: 'ok',
        service: 'api',
        timestamp: '2026-01-01T00:00:00.000Z',
      }),
    ).toBeDefined();
  });
});
