import type { Order, Prisma, PrismaClient } from '@prisma/client';

export interface RestaurantScope {
  organizationId: string;
  restaurantId: string;
}

export interface BranchScope extends RestaurantScope {
  branchId: string;
}

type DatabaseClient = PrismaClient | Prisma.TransactionClient;

const requireUuid = (name: string, value: string): void => {
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value)) {
    throw new TypeError(`${name} must be a UUID`);
  }
};

export class TenantOrderRepository {
  public constructor(
    private readonly client: DatabaseClient,
    private readonly scope: BranchScope,
  ) {
    requireUuid('organizationId', scope.organizationId);
    requireUuid('restaurantId', scope.restaurantId);
    requireUuid('branchId', scope.branchId);
  }

  public findById(id: string): Promise<Order | null> {
    requireUuid('orderId', id);
    return this.client.order.findFirst({
      where: {
        id,
        organizationId: this.scope.organizationId,
        restaurantId: this.scope.restaurantId,
        branchId: this.scope.branchId,
      },
    });
  }

  public list(): Promise<Order[]> {
    return this.client.order.findMany({
      where: {
        organizationId: this.scope.organizationId,
        restaurantId: this.scope.restaurantId,
        branchId: this.scope.branchId,
      },
      orderBy: [{ orderedAt: 'desc' }, { id: 'asc' }],
    });
  }
}

export const withTenantTransaction = async <T>(
  client: PrismaClient,
  organizationId: string,
  operation: (transaction: Prisma.TransactionClient) => Promise<T>,
): Promise<T> => {
  requireUuid('organizationId', organizationId);

  return client.$transaction(async (transaction) => {
    await transaction.$executeRaw`SELECT set_config('app.organization_id', ${organizationId}, true)`;
    return operation(transaction);
  });
};
