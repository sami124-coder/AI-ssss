import 'express-session';
declare module 'express-session' {
  interface SessionData {
    auth?: { userId: string; organizationId: string; restaurantId: string; branchId?: string };
  }
}
