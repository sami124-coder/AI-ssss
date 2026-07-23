import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createLogger } from '@rda/config';
import { createApp } from './app.js';

const config = {
  NODE_ENV: 'test' as const,
  DATABASE_URL: 'postgresql://postgres:postgres@localhost:5432/restaurant_decision_ai',
  PORT: 3000,
  LOG_LEVEL: 'silent' as const,
  CORS_ORIGIN: 'http://localhost:5173',
};

const app = createApp({ config, logger: createLogger(config) });

describe('API foundation', () => {
  it('returns health information and a request ID', async () => {
    const result = await request(app).get('/health').expect(200);
    expect(result.body).toMatchObject({ status: 'ok', service: 'restaurant-decision-api' });
    expect(result.headers['x-request-id']).toEqual(expect.any(String));
  });

  it('returns a structured error for unknown routes', async () => {
    const result = await request(app).get('/missing').expect(404);
    expect(result.body).toMatchObject({
      error: { code: 'not_found', message: 'Route not found' },
    });
  });
});
