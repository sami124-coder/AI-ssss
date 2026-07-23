# Database schema

Restaurant Decision AI uses PostgreSQL through Prisma. All identifiers are UUIDs and all audit,
business, and lifecycle timestamps use UTC `timestamptz(3)`. Money and rates use fixed-precision
`numeric` columns; currency values are three-letter ISO 4217 codes.

## Tenant boundary

`Organization` is the top-level tenant. `Restaurant` belongs to one organization and `Branch`
belongs to one restaurant. Every restaurant-owned table stores `organizationId` and
`restaurantId`; branch-specific tables additionally store `branchId`. Composite foreign keys
include those tenant columns, so an ID from another organization cannot be attached accidentally.

The API must always derive the organization, restaurant, and branch scope from the authenticated
session. `TenantOrderRepository` demonstrates repository-level filtering. The migration also
enables PostgreSQL row-level security on tenant tables. API transactions set
`app.organization_id`; the RLS policy permits only rows for that organization.

## Table groups

| Group | Tables | Purpose |
| --- | --- | --- |
| Identity and tenancy | `organizations`, `restaurants`, `branches`, `users`, `memberships`, `invitations`, `sessions`, `password_reset_tokens` | Tenant ownership, access roles, and secure sessions/tokens. |
| Restaurant data | `sales_channels`, `menu_categories`, `menu_items`, `menu_item_costs`, `ingredients`, `recipes`, `recipe_ingredients`, `orders`, `order_items`, `discounts`, `refunds`, `delivery_commissions`, `operating_costs`, `labor_costs` | Source operational data and fixed-precision costs/revenue. |
| Imports | `import_jobs`, `import_files`, `import_mappings`, `import_row_errors`, `import_batches`, `import_audits` | Validated CSV/XLSX ingestion, source provenance, and deduplication. |
| Decisions | `metric_snapshots`, `detected_issues`, `recommendations`, `recommendation_evidence`, `recommendation_events`, `recommendation_notes`, `outcome_reviews` | Deterministic metrics, evidence-backed actions, and 7/14-day measurement. |
| AI and knowledge | `ai_conversations`, `ai_messages`, `ai_tool_executions`, `knowledge_documents`, `knowledge_chunks` | Explainability and consented knowledge retrieval metadata. |
| Governance | `audit_logs`, `data_export_requests`, `data_deletion_requests` | Change history and privacy operations. |

## Integrity and retention rules

- Source identifiers are retained on imported records and protected by tenant-scoped unique keys.
- Deleting an organization cascades through its tenant data. Child records generally cascade with
  their parent; references that should remain auditable use `RESTRICT`.
- Currency and non-negative amount checks are enforced in PostgreSQL, not only in TypeScript.
- `ImportFile` hashes and `ImportBatch` checksums prevent duplicate source data.
- Membership roles are `OWNER`, `MANAGER`, and `VIEWER`. Recommendation and import lifecycle
  states are represented by PostgreSQL-backed enums.

The migration is `20260724010000_restaurant_decision_schema`. The seed creates one Yemeni
restaurant organization, two branches, owner/manager/viewer users, menu and ingredient data, and
sample orders, discounts, refunds, and delivery commissions.
