import type { Prisma, PrismaClient } from '@prisma/client';
import type { TenantContext } from '../tenant.js';

export class AuditService {
  public constructor(private readonly db: PrismaClient) {}
  public record(scope: TenantContext, event: { action: string; entityType: string; entityId?: string; metadata?: Prisma.InputJsonValue }) {
    return this.db.auditLog.create({ data: {
      organizationId: scope.organizationId, restaurantId: scope.restaurantId,
      ...(scope.branchId ? { branchId: scope.branchId } : {}), actorUserId: scope.userId,
      action: event.action, entityType: event.entityType,
      ...(event.entityId ? { entityId: event.entityId } : {}), metadata: event.metadata ?? {},
    } });
  }
}
