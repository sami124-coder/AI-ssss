import type { PrismaClient } from '@prisma/client';
import type { TenantContext } from '../tenant.js';

export class BranchRepository {
  public constructor(private readonly db: PrismaClient) {}
  public list(scope: TenantContext) {
    return this.db.branch.findMany({
      where: { organizationId: scope.organizationId, restaurantId: scope.restaurantId, ...(scope.branchId ? { id: scope.branchId } : {}) },
      orderBy: { name: 'asc' },
    });
  }
}
