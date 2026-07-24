import type { MembershipRole } from '@rda/database';
import type { TenantContext } from './auth-service.js';

export const canManageMembers = (context: TenantContext) => context.role === ('OWNER' as MembershipRole);
export const canManageRestaurant = (context: TenantContext) => context.role === ('OWNER' as MembershipRole) || context.role === ('MANAGER' as MembershipRole);
export const canModifyData = canManageRestaurant;
export const canAccessBranch = (context: TenantContext, branchId: string) => context.permittedBranchIds.length === 0 || context.permittedBranchIds.includes(branchId);
