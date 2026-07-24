declare global {
  namespace Express {
    interface Request {
      id: string;
      tenant?: import('../auth/auth-service.js').TenantContext;
    }
  }
}

export {};
