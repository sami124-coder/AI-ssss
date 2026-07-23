# Local development

Use the root commands documented in the README. PostgreSQL is exposed only for local development
through port 5432. The API validates its environment during startup and exits immediately when
required configuration is invalid.

Integration tests require the PostgreSQL container and the migrated development database.
End-to-end tests start a Vite server automatically.
