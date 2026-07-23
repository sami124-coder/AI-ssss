# Architecture

The repository uses a pnpm workspace with two applications and four packages:

- `apps/web`: React browser application.
- `apps/api`: Express HTTP API.
- `packages/domain`: framework-independent business rules (empty in this phase).
- `packages/database`: Prisma and PostgreSQL access.
- `packages/shared`: transport-safe schemas and errors.
- `packages/config`: environment validation and structured logging.

Dependencies point inward: applications may use packages, while domain code must not import
application, database, HTTP, or AI-provider code.
