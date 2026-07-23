import { MembershipRole, Prisma, PrismaClient, SalesChannelType } from '@prisma/client';

const database = new PrismaClient();
const money = (value: string) => new Prisma.Decimal(value);

const ids = {
  organization: '10000000-0000-4000-8000-000000000001',
  restaurant: '20000000-0000-4000-8000-000000000001',
  branchShanghai: '30000000-0000-4000-8000-000000000001',
  branchYiwu: '30000000-0000-4000-8000-000000000002',
  owner: '40000000-0000-4000-8000-000000000001',
  manager: '40000000-0000-4000-8000-000000000002',
  viewer: '40000000-0000-4000-8000-000000000003',
  categoryMains: '50000000-0000-4000-8000-000000000001',
  categoryDrinks: '50000000-0000-4000-8000-000000000002',
  itemMandi: '60000000-0000-4000-8000-000000000001',
  itemFahsa: '60000000-0000-4000-8000-000000000002',
  itemTea: '60000000-0000-4000-8000-000000000003',
  ingredientRice: '70000000-0000-4000-8000-000000000001',
  ingredientLamb: '70000000-0000-4000-8000-000000000002',
  channelDineIn: '80000000-0000-4000-8000-000000000001',
  channelDelivery: '80000000-0000-4000-8000-000000000002',
  orderShanghai: '90000000-0000-4000-8000-000000000001',
  orderYiwu: '90000000-0000-4000-8000-000000000002',
  itemShanghai: 'a0000000-0000-4000-8000-000000000001',
  itemYiwu: 'a0000000-0000-4000-8000-000000000002',
} as const;

const tenant = {
  organizationId: ids.organization,
  restaurantId: ids.restaurant,
};

try {
  await database.$transaction(async (tx) => {
    await tx.serviceMetadata.upsert({
      where: { key: 'schema_version' },
      update: { value: '2' },
      create: { key: 'schema_version', value: '2' },
    });

    await tx.organization.upsert({
      where: { id: ids.organization },
      update: { name: 'Sana’a Yemen Restaurant' },
      create: {
        id: ids.organization,
        name: 'Sana’a Yemen Restaurant',
        slug: 'sanaa-yemen-restaurant',
      },
    });

    await tx.restaurant.upsert({
      where: { id: ids.restaurant },
      update: { name: 'Sana’a Yemen Restaurant' },
      create: {
        id: ids.restaurant,
        organizationId: ids.organization,
        name: 'Sana’a Yemen Restaurant',
        legalName: 'Sana’a Yemeni Cuisine Co.',
        currency: 'CNY',
        timezone: 'Asia/Shanghai',
      },
    });

    for (const branch of [
      {
        id: ids.branchShanghai,
        name: 'Shanghai Branch',
        code: 'SHA',
        address: 'Pudong, Shanghai, China',
      },
      {
        id: ids.branchYiwu,
        name: 'Yiwu Branch',
        code: 'YIW',
        address: 'Futian, Yiwu, Zhejiang, China',
      },
    ]) {
      await tx.branch.upsert({
        where: { id: branch.id },
        update: { name: branch.name, address: branch.address },
        create: { ...tenant, ...branch, timezone: 'Asia/Shanghai' },
      });
    }

    for (const user of [
      {
        id: ids.owner,
        email: 'owner@example.restaurant',
        displayName: 'Ahmed Al-Hakimi',
        locale: 'ar',
      },
      {
        id: ids.manager,
        email: 'manager@example.restaurant',
        displayName: 'Li Wei',
        locale: 'en',
      },
      {
        id: ids.viewer,
        email: 'viewer@example.restaurant',
        displayName: 'Mariam Saleh',
        locale: 'ar',
      },
    ]) {
      await tx.user.upsert({
        where: { id: user.id },
        update: { displayName: user.displayName, locale: user.locale },
        create: { ...user, passwordHash: '!seed-account-login-disabled!' },
      });
    }

    for (const membership of [
      { id: '41000000-0000-4000-8000-000000000001', userId: ids.owner, role: MembershipRole.OWNER },
      {
        id: '41000000-0000-4000-8000-000000000002',
        userId: ids.manager,
        role: MembershipRole.MANAGER,
      },
      {
        id: '41000000-0000-4000-8000-000000000003',
        userId: ids.viewer,
        role: MembershipRole.VIEWER,
      },
    ]) {
      await tx.membership.upsert({
        where: { id: membership.id },
        update: { role: membership.role },
        create: { ...tenant, ...membership },
      });
    }

    for (const category of [
      { id: ids.categoryMains, name: 'Main dishes', externalId: 'CAT-MAINS', sortOrder: 1 },
      { id: ids.categoryDrinks, name: 'Drinks', externalId: 'CAT-DRINKS', sortOrder: 2 },
    ]) {
      await tx.menuCategory.upsert({
        where: { id: category.id },
        update: { name: category.name },
        create: { ...tenant, ...category },
      });
    }

    for (const item of [
      {
        id: ids.itemMandi,
        categoryId: ids.categoryMains,
        name: 'Lamb Mandi',
        sku: 'MANDI-LAMB',
        externalId: 'MENU-001',
        sellingPrice: money('128.00'),
      },
      {
        id: ids.itemFahsa,
        categoryId: ids.categoryMains,
        name: 'Fahsa',
        sku: 'FAHSA',
        externalId: 'MENU-002',
        sellingPrice: money('88.00'),
      },
      {
        id: ids.itemTea,
        categoryId: ids.categoryDrinks,
        name: 'Yemeni Milk Tea',
        sku: 'TEA-YEMENI',
        externalId: 'MENU-003',
        sellingPrice: money('18.00'),
      },
    ]) {
      await tx.menuItem.upsert({
        where: { id: item.id },
        update: { sellingPrice: item.sellingPrice },
        create: { ...tenant, ...item, currency: 'CNY' },
      });
    }

    for (const ingredient of [
      {
        id: ids.ingredientRice,
        name: 'Basmati rice',
        unit: 'kg',
        unitCost: money('18.50'),
        externalId: 'ING-RICE',
      },
      {
        id: ids.ingredientLamb,
        name: 'Lamb',
        unit: 'kg',
        unitCost: money('76.00'),
        externalId: 'ING-LAMB',
      },
    ]) {
      await tx.ingredient.upsert({
        where: { id: ingredient.id },
        update: { unitCost: ingredient.unitCost },
        create: {
          ...tenant,
          ...ingredient,
          currency: 'CNY',
          effectiveAt: new Date('2026-07-01T00:00:00.000Z'),
        },
      });
    }

    for (const channel of [
      {
        id: ids.channelDineIn,
        name: 'Dine in',
        type: SalesChannelType.DINE_IN,
        externalId: 'POS-DINE-IN',
      },
      {
        id: ids.channelDelivery,
        name: 'Meituan Delivery',
        type: SalesChannelType.DELIVERY,
        externalId: 'MEITUAN',
      },
    ]) {
      await tx.salesChannel.upsert({
        where: { id: channel.id },
        update: { name: channel.name },
        create: { ...tenant, ...channel },
      });
    }

    const orders = [
      {
        id: ids.orderShanghai,
        branchId: ids.branchShanghai,
        salesChannelId: ids.channelDineIn,
        externalId: 'SHA-20260701-0001',
        orderedAt: new Date('2026-07-01T11:30:00.000Z'),
        subtotal: money('128.00'),
        discountTotal: money('8.00'),
        refundTotal: money('0.00'),
        total: money('120.00'),
      },
      {
        id: ids.orderYiwu,
        branchId: ids.branchYiwu,
        salesChannelId: ids.channelDelivery,
        externalId: 'YIW-20260701-0001',
        orderedAt: new Date('2026-07-01T12:15:00.000Z'),
        subtotal: money('88.00'),
        discountTotal: money('0.00'),
        refundTotal: money('20.00'),
        total: money('68.00'),
      },
    ];

    for (const order of orders) {
      await tx.order.upsert({
        where: { id: order.id },
        update: { total: order.total },
        create: {
          ...tenant,
          ...order,
          taxTotal: money('0.00'),
          currency: 'CNY',
          sourceSystem: 'pilot-csv',
        },
      });
    }

    await tx.orderItem.upsert({
      where: { id: ids.itemShanghai },
      update: { netAmount: money('120.00') },
      create: {
        ...tenant,
        id: ids.itemShanghai,
        branchId: ids.branchShanghai,
        orderId: ids.orderShanghai,
        menuItemId: ids.itemMandi,
        externalId: '1',
        itemName: 'Lamb Mandi',
        quantity: money('1'),
        unitPrice: money('128.00'),
        grossAmount: money('128.00'),
        discountAmount: money('8.00'),
        netAmount: money('120.00'),
        currency: 'CNY',
      },
    });

    await tx.orderItem.upsert({
      where: { id: ids.itemYiwu },
      update: { netAmount: money('88.00') },
      create: {
        ...tenant,
        id: ids.itemYiwu,
        branchId: ids.branchYiwu,
        orderId: ids.orderYiwu,
        menuItemId: ids.itemFahsa,
        externalId: '1',
        itemName: 'Fahsa',
        quantity: money('1'),
        unitPrice: money('88.00'),
        grossAmount: money('88.00'),
        discountAmount: money('0.00'),
        netAmount: money('88.00'),
        currency: 'CNY',
      },
    });

    await tx.discount.upsert({
      where: { id: 'b0000000-0000-4000-8000-000000000001' },
      update: { amount: money('8.00') },
      create: {
        ...tenant,
        id: 'b0000000-0000-4000-8000-000000000001',
        branchId: ids.branchShanghai,
        orderId: ids.orderShanghai,
        orderItemId: ids.itemShanghai,
        externalId: 'DISC-001',
        reason: 'Pilot opening promotion',
        amount: money('8.00'),
        currency: 'CNY',
        occurredAt: new Date('2026-07-01T11:30:00.000Z'),
      },
    });

    await tx.refund.upsert({
      where: { id: 'c0000000-0000-4000-8000-000000000001' },
      update: { amount: money('20.00') },
      create: {
        ...tenant,
        id: 'c0000000-0000-4000-8000-000000000001',
        branchId: ids.branchYiwu,
        orderId: ids.orderYiwu,
        externalId: 'REF-001',
        reason: 'Missing side dish',
        amount: money('20.00'),
        currency: 'CNY',
        refundedAt: new Date('2026-07-01T13:00:00.000Z'),
      },
    });

    await tx.deliveryCommission.upsert({
      where: { id: 'd0000000-0000-4000-8000-000000000001' },
      update: { amount: money('17.60') },
      create: {
        ...tenant,
        id: 'd0000000-0000-4000-8000-000000000001',
        branchId: ids.branchYiwu,
        orderId: ids.orderYiwu,
        salesChannelId: ids.channelDelivery,
        externalId: 'COMM-001',
        rate: money('0.200000'),
        amount: money('17.60'),
        currency: 'CNY',
        chargedAt: new Date('2026-07-01T12:15:00.000Z'),
      },
    });
  });
} finally {
  await database.$disconnect();
}
