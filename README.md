# Restaurant Decision AI

Multi-tenant decision support for restaurants. Existing operational systems remain the source of truth; this application validates imported data, calculates figures deterministically, and tracks one evidence-backed action through review.

## Development

1. Copy `.env.example` to `.env` and change `SESSION_SECRET`.
2. Run `docker compose up -d`.
3. Run `pnpm install`, `pnpm db:generate`, then `pnpm build`.
4. Run `pnpm --filter @rda/api dev` and `pnpm --filter @rda/web dev`.

Financial calculations live only in `packages/domain`. API tenant identity is derived from the authenticated session and repositories require explicit tenant scope.
