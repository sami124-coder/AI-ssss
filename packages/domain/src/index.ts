/**
 * Framework-independent domain boundary.
 *
 * Business rules will be introduced in a later phase. Keeping this package
 * dependency-free prevents accidental coupling to HTTP, persistence, or AI.
 */
export const domainPackageName = '@rda/domain';
