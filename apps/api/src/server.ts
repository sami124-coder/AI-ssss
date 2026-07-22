import 'dotenv/config';
import connectPgSimple from 'connect-pg-simple';
import session from 'express-session';
import pg from 'pg';
import { createApp } from './app.js';
import { readConfig } from './config.js';

const config = readConfig();
const pool = new pg.Pool({ connectionString: config.DATABASE_URL });
const PgStore = connectPgSimple(session);
const store = new PgStore({ pool, createTableIfMissing: true });
const app = createApp(config, store);
const server = app.listen(config.PORT, () => process.stdout.write(`API listening on ${config.PORT}\n`));
const shutdown = () => server.close(() => void pool.end());
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
