import type { NextFunction, Request, Response } from 'express';
import { requireAuth } from './auth.js';

/** Establishes tenant identity exclusively from the authenticated server session. */
export const tenantContextMiddleware = (request: Request, response: Response, next: NextFunction) => requireAuth(request, response, next);

/** Use this before any AI/tool operation; request payload tenant IDs are intentionally ignored. */
export const authenticatedTenant = (request: Request) => {
  if (!request.tenant) throw new Error('UNAUTHENTICATED');
  return request.tenant;
};
