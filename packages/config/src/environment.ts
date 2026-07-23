import { z } from 'zod';

export const apiEnvironmentSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_URL: z.url(),
  PORT: z.coerce.number().int().min(1).max(65_535).default(3000),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']).default('info'),
  CORS_ORIGIN: z.url().default('http://localhost:5173'),
});

export type ApiEnvironment = z.infer<typeof apiEnvironmentSchema>;

export function readApiEnvironment(environment: NodeJS.ProcessEnv = process.env): ApiEnvironment {
  return apiEnvironmentSchema.parse(environment);
}
