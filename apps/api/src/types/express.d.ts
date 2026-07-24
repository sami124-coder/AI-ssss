import type { TenantContext } from '../auth/auth-service.js';

declare global {
  namespace Express {
    interface Request {
      id: string;
      tenant?: TenantContext;
    }
  }
}

export {};
