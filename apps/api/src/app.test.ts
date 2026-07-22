import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createApp } from './app.js';

const config = { NODE_ENV: 'test' as const, SESSION_SECRET: 'test-secret-that-is-at-least-32-characters' };
describe('API security boundary', () => {
  it('exposes health without authentication', async () => { await request(createApp(config)).get('/health').expect(200, { status: 'ok' }); });
  it('does not accept tenant identity from request input', async () => {
    const result = await request(createApp(config)).get('/api/context?organizationId=attacker').set('x-organization-id', 'attacker');
    expect(result.status).toBe(401);
    expect(result.text).toBe('{"error":"authentication_required"}');
  });
});
