ALTER TABLE "users" ADD COLUMN "failedLoginAttempts" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "users" ADD COLUMN "lockedUntil" TIMESTAMPTZ(3);
ALTER TABLE "sessions" ADD COLUMN "revokedAt" TIMESTAMPTZ(3);
CREATE INDEX "sessions_revokedAt_expiresAt_idx" ON "sessions" ("revokedAt", "expiresAt");
