import { z } from 'zod';

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_URL: z.string().url(),
  SESSION_SECRET: z.string().min(32),
  PORT: z.coerce.number().int().positive().default(3000),
});
export type Config = z.infer<typeof schema>;
export function readConfig(environment: NodeJS.ProcessEnv = process.env): Config { return schema.parse(environment); }
