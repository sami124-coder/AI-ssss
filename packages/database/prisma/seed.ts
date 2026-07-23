import { PrismaClient } from '@prisma/client';

const database = new PrismaClient();

try {
  await database.serviceMetadata.upsert({
    where: { key: 'schema_version' },
    update: { value: '1' },
    create: { key: 'schema_version', value: '1' },
  });
} finally {
  await database.$disconnect();
}
