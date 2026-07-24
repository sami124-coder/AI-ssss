import { describe, expect, it } from 'vitest';
import { canAccessBranch, canManageMembers, canModifyData } from './policies.js';
import type { TenantContext } from './auth-service.js';

const context = (role: 'OWNER' | 'MANAGER' | 'VIEWER'): TenantContext => ({ userId: '10000000-0000-4000-8000-000000000001', organizationId: '20000000-0000-4000-8000-000000000001', restaurantId: '30000000-0000-4000-8000-000000000001', permittedBranchIds: ['40000000-0000-4000-8000-000000000001'], role, sessionId: '50000000-0000-4000-8000-000000000001' });

describe('authorization policies', () => {
  it('only owners manage members and ownership', () => { expect(canManageMembers(context('OWNER'))).toBe(true); expect(canManageMembers(context('MANAGER'))).toBe(false); });
  it('viewers cannot modify restaurant data', () => { expect(canModifyData(context('VIEWER'))).toBe(false); expect(canModifyData(context('MANAGER'))).toBe(true); });
  it('enforces permitted branches', () => { expect(canAccessBranch(context('OWNER'), context('OWNER').permittedBranchIds[0]!)).toBe(true); expect(canAccessBranch(context('OWNER'), '60000000-0000-4000-8000-000000000001')).toBe(false); });
});
