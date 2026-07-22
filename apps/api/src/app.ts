import express from 'express';
import helmet from 'helmet';
import session from 'express-session';
import type { Config } from './config.js';
import { requireTenant, tenantFrom } from './tenant.js';

export function createApp(config: Pick<Config, 'NODE_ENV' | 'SESSION_SECRET'>, store?: session.Store) {
  const app = express();
  app.set('trust proxy', 1);
  app.use(helmet());
  app.use(express.json({ limit: '1mb' }));
  const sessionOptions: session.SessionOptions = {
    name: 'rda.sid', secret: config.SESSION_SECRET, resave: false, saveUninitialized: false,
    ...(store ? { store } : {}),
    cookie: { httpOnly: true, secure: config.NODE_ENV === 'production', sameSite: 'lax', maxAge: 8 * 60 * 60 * 1000 },
  };
  app.use(session(sessionOptions));
  app.get('/health', (_request, response) => response.json({ status: 'ok' }));
  app.get('/api/context', requireTenant, (request, response) => response.json({ tenant: tenantFrom(request) }));
  return app;
}
