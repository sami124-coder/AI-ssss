# Restaurant Decision AI

Production-oriented monorepo foundation for Restaurant Decision AI. This phase contains platform
infrastructure only—no restaurant decision or financial business functionality.

## Requirements

- Node.js 24
- pnpm 11
- Docker with Compose

## Local setup

1. Copy `.env.example` to `.env`.
2. Start PostgreSQL: `docker compose -f infrastructure/docker-compose.yml up -d`.
3. Install dependencies: `pnpm install`.
4. Generate and migrate the database: `pnpm db:generate && pnpm db:migrate`.
5. Seed development metadata: `pnpm db:seed`.
6. Start the applications: `pnpm dev`.

The web app runs at `http://localhost:5173` and the API at `http://localhost:3000`.
See [`docs/architecture.md`](docs/architecture.md) and
[`docs/development.md`](docs/development.md) for additional details.

## Quality commands

| Command          | Purpose                                     |
| ---------------- | ------------------------------------------- |
| `pnpm build`     | Build all packages and applications         |
| `pnpm test`      | Run unit, integration, and end-to-end tests |
| `pnpm lint`      | Run ESLint                                  |
| `pnpm typecheck` | Check all TypeScript projects               |
| `pnpm format`    | Format supported files with Prettier        |
