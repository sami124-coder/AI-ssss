import type { NextFunction, Request, Response } from 'express';
import type { Logger } from 'pino';
import { AuthService } from '../auth/auth-service.js';
import { database } from '@rda/database';

export const requireAuth = async (request: Request, response: Response, next: NextFunction) => {
  const token = request.header('cookie')?.match(/(?:^|;\s*)rda_session=([^;]+)/)?.[1];
  const context = token ? await new AuthService(database).resolveSession(token) : null;
  if (!context) { response.status(401).json({ error: { code: 'UNAUTHENTICATED', message: 'Authentication required' } }); return; }
  request.tenant = context; next();
};

export const requireRole = (...roles: Array<'OWNER' | 'MANAGER' | 'VIEWER'>) => (request: Request, response: Response, next: NextFunction) => {
  if (!request.tenant || !roles.includes(request.tenant.role)) { response.status(403).json({ error: { code: 'FORBIDDEN', message: 'Insufficient role' } }); return; }
  next();
};

export const csrfProtection = (request: Request, response: Response, next: NextFunction) => {
  if (['GET', 'HEAD', 'OPTIONS'].includes(request.method)) return next();
  const cookie = request.header('cookie')?.match(/(?:^|;\s*)rda_csrf=([^;]+)/)?.[1];
  if (!cookie || request.header('x-csrf-token') !== cookie) { response.status(403).json({ error: { code: 'CSRF_FAILED', message: 'CSRF token required' } }); return; }
  next();
};

export const audit = (logger: Logger, action: string) => (request: Request, _response: Response, next: NextFunction) => { logger.info({ action, requestId: request.id, userId: request.tenant?.userId, organizationId: request.tenant?.organizationId }, 'security audit'); next(); };
