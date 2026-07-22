import type { Request, RequestHandler } from 'express';

export interface TenantContext { userId: string; organizationId: string; restaurantId: string; branchId?: string }
declare global {
  // Express exposes its request extension point through this global namespace.
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express { interface Request { tenant?: TenantContext } }
}

export const requireTenant: RequestHandler = (request, response, next) => {
  const auth = request.session.auth;
  if (!auth) { response.status(401).json({ error: 'authentication_required' }); return; }
  request.tenant = { ...auth };
  next();
};

export function tenantFrom(request: Request): TenantContext {
  if (!request.tenant) throw new Error('Tenant middleware was not applied');
  return request.tenant;
}
