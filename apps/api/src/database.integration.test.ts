import { database } from '@rda/database';
import { afterAll, describe, expect, it } from 'vitest';

describe('PostgreSQL integration', () => {
  afterAll(async () => {
    await database.$disconnect();
  });

  it('can execute a database query', async () => {
    const result = await database.$queryRaw<Array<{ value: number }>>`SELECT 1 AS value`;
    expect(result).toEqual([{ value: 1 }]);
  });
});
