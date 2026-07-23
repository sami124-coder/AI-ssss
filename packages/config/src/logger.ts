import pino, { type Logger } from 'pino';
import type { ApiEnvironment } from './environment.js';

export function createLogger(config: Pick<ApiEnvironment, 'LOG_LEVEL' | 'NODE_ENV'>): Logger {
  return pino({
    level: config.LOG_LEVEL,
    base: { service: 'restaurant-decision-api', environment: config.NODE_ENV },
    redact: {
      paths: ['req.headers.authorization', 'req.headers.cookie', '*.password', '*.token'],
      censor: '[REDACTED]',
    },
  });
}
