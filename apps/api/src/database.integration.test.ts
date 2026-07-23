import { database, TenantOrderRepository } from '@rda/database';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { randomUUID } from 'node:crypto';

const ids = {
  organizationA: randomUUID(),
  organizationB: randomUUID(),
  restaurantA: randomUUID(),
  restaurantB: randomUUID(),
  branchA1: randomUUID(),
  branchA2: randomUUID(),
  branchB1: randomUUID(),
  orderA1: randomUUID(),
  orderA2: randomUUID(),
  orderB1: randomUUID(),
  importJobA: randomUUID(),
};

describe('PostgreSQL integration', () => {
  beforeAll(async () => {
    await database.organization.createMany({
      data: [
        { id: ids.organizationA, name: 'Test Tenant A', slug: `test-a-${ids.organizationA.slice(0, 8)}` },
        { id: ids.organizationB, name: 'Test Tenant B', slug: `test-b-${ids.organizationB.slice(0, 8)}` },
      ],
    });
    await database.restaurant.createMany({
      data: [
        { id: ids.restaurantA, organizationId: ids.organizationA, name: 'Restaurant A', currency: 'CNY', timezone: 'UTC' },
        { id: ids.restaurantB, organizationId: ids.organizationB, name: 'Restaurant B', currency: 'CNY', timezone: 'UTC' },
      ],
    });
    await database.branch.createMany({
      data: [
        { id: ids.branchA1, organizationId: ids.organizationA, restaurantId: ids.restaurantA, name: 'A Main', code: 'A1', timezone: 'UTC' },
        { id: ids.branchA2, organizationId: ids.organizationA, restaurantId: ids.restaurantA, name: 'A Second', code: 'A2', timezone: 'UTC' },
        { id: ids.branchB1, organizationId: ids.organizationB, restaurantId: ids.restaurantB, name: 'B Main', code: 'B1', timezone: 'UTC' },
      ],
    });
    await database.order.createMany({
      data: [
        { id: ids.orderA1, organizationId: ids.organizationA, restaurantId: ids.restaurantA, branchId: ids.branchA1, externalId: 'ORDER-1', orderedAt: new Date(), subtotal: '100.00', total: '100.00', currency: 'CNY', sourceSystem: 'test' },
        { id: ids.orderA2, organizationId: ids.organizationA, restaurantId: ids.restaurantA, branchId: ids.branchA2, externalId: 'ORDER-2', orderedAt: new Date(), subtotal: '200.00', total: '200.00', currency: 'CNY', sourceSystem: 'test' },
        { id: ids.orderB1, organizationId: ids.organizationB, restaurantId: ids.restaurantB, branchId: ids.branchB1, externalId: 'ORDER-1', orderedAt: new Date(), subtotal: '300.00', total: '300.00', currency: 'CNY', sourceSystem: 'test' },
      ],
    });
    await database.importJob.create({
      data: { id: ids.importJobA, organizationId: ids.organizationA, restaurantId: ids.restaurantA, type: 'SALES', status: 'COMPLETED', requestedById: (await database.user.create({ data: { email: `test-${ids.organizationA.slice(0, 8)}@example.com`, passwordHash: 'test', displayName: 'Test User' } })).id, sourceSystem: 'test' },
    });
  });

  afterAll(async () => {
    await database.organization.deleteMany({ where: { id: { in: [ids.organizationA, ids.organizationB] } } });
    await database.$disconnect();
  });

  it('can execute a database query', async () => {
    const result = await database.$queryRaw<Array<{ value: number }>>`SELECT 1 AS value`;
    expect(result).toEqual([{ value: 1 }]);
  });

  it('cannot retrieve another tenant through a scoped repository', async () => {
    const repository = new TenantOrderRepository(database, {
      organizationId: ids.organizationA,
      restaurantId: ids.restaurantA,
      branchId: ids.branchA1,
    });
    expect(await repository.findById(ids.orderB1)).toBeNull();
  });

  it('filters records to the selected branch', async () => {
    const repository = new TenantOrderRepository(database, {
      organizationId: ids.organizationA,
      restaurantId: ids.restaurantA,
      branchId: ids.branchA1,
    });
    expect((await repository.list()).map((order) => order.id)).toEqual([ids.orderA1]);
  });

  it('rejects duplicate source import records', async () => {
    await expect(database.importFile.create({
      data: { organizationId: ids.organizationA, restaurantId: ids.restaurantA, importJobId: ids.importJobA, storageKey: `test/${ids.importJobA}`, originalName: 'sales.csv', mediaType: 'text/csv', sizeBytes: 10n, sha256: 'duplicate-sha' },
    })).resolves.toBeDefined();
    await expect(database.importFile.create({
      data: { organizationId: ids.organizationA, restaurantId: ids.restaurantA, importJobId: ids.importJobA, storageKey: `test/${ids.importJobA}-2`, originalName: 'sales-copy.csv', mediaType: 'text/csv', sizeBytes: 10n, sha256: 'duplicate-sha' },
    })).rejects.toMatchObject({ code: 'P2002' });
  });

  it('rejects a foreign-key relationship from another tenant', async () => {
    await expect(database.order.create({
      data: { organizationId: ids.organizationA, restaurantId: ids.restaurantA, branchId: ids.branchB1, externalId: 'INVALID', orderedAt: new Date(), subtotal: '1.00', total: '1.00', currency: 'CNY', sourceSystem: 'test' },
    })).rejects.toMatchObject({ code: 'P2003' });
  });
});
