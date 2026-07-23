import { describe, expect, it } from 'vitest';
import { readApiEnvironment } from './environment.js';

describe('readApiEnvironment', () => {
  it('parses and defaults valid environment values', () => {
    const config = readApiEnvironment({
      DATABASE_URL: 'postgresql://postgres:postgres@localhost:5432/app',
    });
    expect(config.PORT).toBe(3000);
    expect(config.NODE_ENV).toBe('development');
  });

  it('rejects invalid database URLs', () => {
    expect(() => readApiEnvironment({ DATABASE_URL: 'not-a-url' })).toThrow();
  });
});
