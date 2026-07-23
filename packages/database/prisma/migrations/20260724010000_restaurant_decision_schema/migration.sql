-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "MembershipRole" AS ENUM ('OWNER', 'MANAGER', 'VIEWER');

-- CreateEnum
CREATE TYPE "ImportStatus" AS ENUM ('PENDING', 'VALIDATING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ImportType" AS ENUM ('SALES', 'MENU', 'INGREDIENT_COSTS', 'OPERATING_COSTS', 'LABOR_COSTS');

-- CreateEnum
CREATE TYPE "RecommendationStatus" AS ENUM ('PROPOSED', 'ACCEPTED', 'REJECTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "RecommendationPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "RecommendationConfidence" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'WITHHELD');

-- CreateEnum
CREATE TYPE "OutcomeReviewType" AS ENUM ('SEVEN_DAY', 'FOURTEEN_DAY');

-- CreateEnum
CREATE TYPE "DataQualityStatus" AS ENUM ('COMPLETE', 'PARTIAL', 'MISSING', 'INVALID');

-- CreateEnum
CREATE TYPE "SalesChannelType" AS ENUM ('DINE_IN', 'TAKEAWAY', 'DELIVERY', 'OTHER');

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'IMPORT', 'EXPORT', 'ACCEPT', 'REJECT', 'COMPLETE');

-- CreateTable
CREATE TABLE "organizations" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "organizations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "restaurants" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "legalName" TEXT,
    "currency" CHAR(3) NOT NULL,
    "timezone" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "restaurants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branches" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "address" TEXT,
    "timezone" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "locale" TEXT NOT NULL DEFAULT 'en',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "memberships" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID,
    "branchId" UUID,
    "userId" UUID NOT NULL,
    "role" "MembershipRole" NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "memberships_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invitations" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID,
    "branchId" UUID,
    "email" TEXT NOT NULL,
    "role" "MembershipRole" NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "invitedById" UUID NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "acceptedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "invitations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "lastSeenAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "password_reset_tokens" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "usedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "password_reset_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sales_channels" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "name" TEXT NOT NULL,
    "type" "SalesChannelType" NOT NULL,
    "externalId" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "sales_channels_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_categories" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "externalId" TEXT,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "menu_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_items" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "categoryId" UUID,
    "name" TEXT NOT NULL,
    "sku" TEXT,
    "externalId" TEXT,
    "sellingPrice" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "menu_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "menu_item_costs" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "menuItemId" UUID NOT NULL,
    "amount" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "effectiveFrom" TIMESTAMPTZ(3) NOT NULL,
    "effectiveTo" TIMESTAMPTZ(3),
    "sourceExternalId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "menu_item_costs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ingredients" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "unit" TEXT NOT NULL,
    "unitCost" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "externalId" TEXT,
    "effectiveAt" TIMESTAMPTZ(3) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "ingredients_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recipes" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "menuItemId" UUID NOT NULL,
    "yieldQuantity" DECIMAL(18,6) NOT NULL DEFAULT 1,
    "version" INTEGER NOT NULL DEFAULT 1,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "recipes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recipe_ingredients" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "recipeId" UUID NOT NULL,
    "ingredientId" UUID NOT NULL,
    "quantity" DECIMAL(18,6) NOT NULL,
    "unit" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "recipe_ingredients_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orders" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "salesChannelId" UUID,
    "externalId" TEXT NOT NULL,
    "orderedAt" TIMESTAMPTZ(3) NOT NULL,
    "subtotal" DECIMAL(19,4) NOT NULL,
    "discountTotal" DECIMAL(19,4) NOT NULL DEFAULT 0,
    "refundTotal" DECIMAL(19,4) NOT NULL DEFAULT 0,
    "taxTotal" DECIMAL(19,4) NOT NULL DEFAULT 0,
    "total" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "sourceSystem" TEXT NOT NULL,
    "importBatchId" UUID,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_items" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "menuItemId" UUID,
    "externalId" TEXT,
    "itemName" TEXT NOT NULL,
    "quantity" DECIMAL(18,6) NOT NULL,
    "unitPrice" DECIMAL(19,4) NOT NULL,
    "grossAmount" DECIMAL(19,4) NOT NULL,
    "discountAmount" DECIMAL(19,4) NOT NULL DEFAULT 0,
    "netAmount" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "order_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "discounts" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "orderItemId" UUID,
    "externalId" TEXT,
    "reason" TEXT,
    "amount" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "occurredAt" TIMESTAMPTZ(3) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "discounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refunds" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "externalId" TEXT NOT NULL,
    "reason" TEXT,
    "amount" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "refundedAt" TIMESTAMPTZ(3) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refunds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_commissions" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "salesChannelId" UUID,
    "externalId" TEXT,
    "rate" DECIMAL(9,6),
    "amount" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "chargedAt" TIMESTAMPTZ(3) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "delivery_commissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "operating_costs" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "category" TEXT NOT NULL,
    "description" TEXT,
    "amount" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "incurredAt" TIMESTAMPTZ(3) NOT NULL,
    "externalId" TEXT,
    "sourceSystem" TEXT,
    "importBatchId" UUID,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "operating_costs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "labor_costs" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "roleName" TEXT,
    "hours" DECIMAL(12,4),
    "amount" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "workDate" DATE NOT NULL,
    "externalId" TEXT,
    "sourceSystem" TEXT,
    "importBatchId" UUID,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "labor_costs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_jobs" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "type" "ImportType" NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'PENDING',
    "requestedById" UUID NOT NULL,
    "sourceSystem" TEXT NOT NULL,
    "startedAt" TIMESTAMPTZ(3),
    "completedAt" TIMESTAMPTZ(3),
    "rowCount" INTEGER NOT NULL DEFAULT 0,
    "acceptedCount" INTEGER NOT NULL DEFAULT 0,
    "rejectedCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "import_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_files" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "importJobId" UUID NOT NULL,
    "storageKey" TEXT NOT NULL,
    "originalName" TEXT NOT NULL,
    "mediaType" TEXT NOT NULL,
    "sizeBytes" BIGINT NOT NULL,
    "sha256" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "import_files_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_mappings" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "importJobId" UUID NOT NULL,
    "sourceColumn" TEXT NOT NULL,
    "targetField" TEXT NOT NULL,
    "transform" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "import_mappings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_row_errors" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "importJobId" UUID NOT NULL,
    "rowNumber" INTEGER NOT NULL,
    "field" TEXT,
    "code" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "sourceData" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "import_row_errors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_batches" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "importJobId" UUID NOT NULL,
    "batchNumber" INTEGER NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'PENDING',
    "sourceStartRow" INTEGER NOT NULL,
    "sourceEndRow" INTEGER NOT NULL,
    "checksum" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMPTZ(3),

    CONSTRAINT "import_batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_audits" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "importJobId" UUID NOT NULL,
    "actorId" UUID,
    "action" TEXT NOT NULL,
    "details" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "import_audits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "metric_snapshots" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "metricKey" TEXT NOT NULL,
    "periodStart" TIMESTAMPTZ(3) NOT NULL,
    "periodEnd" TIMESTAMPTZ(3) NOT NULL,
    "value" DECIMAL(19,4) NOT NULL,
    "currency" CHAR(3),
    "unit" TEXT NOT NULL,
    "dataQualityStatus" "DataQualityStatus" NOT NULL,
    "calculationVersion" TEXT NOT NULL,
    "evidence" JSONB NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "metric_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "detected_issues" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "metricSnapshotId" UUID,
    "issueKey" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "estimatedImpact" DECIMAL(19,4),
    "currency" CHAR(3),
    "priority" "RecommendationPriority" NOT NULL,
    "confidence" "RecommendationConfidence" NOT NULL,
    "dataQualityStatus" "DataQualityStatus" NOT NULL,
    "detectedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "detected_issues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recommendations" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "detectedIssueId" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "rationale" TEXT NOT NULL,
    "status" "RecommendationStatus" NOT NULL DEFAULT 'PROPOSED',
    "priority" "RecommendationPriority" NOT NULL,
    "confidence" "RecommendationConfidence" NOT NULL,
    "proposedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "targetDate" TIMESTAMPTZ(3),
    "completedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "recommendations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recommendation_evidence" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "recommendationId" UUID NOT NULL,
    "metricSnapshotId" UUID,
    "label" TEXT NOT NULL,
    "value" DECIMAL(19,4),
    "currency" CHAR(3),
    "unit" TEXT,
    "description" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "recommendation_evidence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recommendation_events" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "recommendationId" UUID NOT NULL,
    "actorId" UUID,
    "fromStatus" "RecommendationStatus",
    "toStatus" "RecommendationStatus" NOT NULL,
    "details" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "recommendation_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recommendation_notes" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "recommendationId" UUID NOT NULL,
    "authorId" UUID NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "recommendation_notes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outcome_reviews" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "recommendationId" UUID NOT NULL,
    "type" "OutcomeReviewType" NOT NULL,
    "scheduledFor" TIMESTAMPTZ(3) NOT NULL,
    "reviewedAt" TIMESTAMPTZ(3),
    "baselineValue" DECIMAL(19,4),
    "resultValue" DECIMAL(19,4),
    "measuredImpact" DECIMAL(19,4),
    "currency" CHAR(3),
    "dataQualityStatus" "DataQualityStatus" NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "outcome_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_conversations" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "userId" UUID NOT NULL,
    "title" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "ai_conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_messages" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "conversationId" UUID NOT NULL,
    "role" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "model" TEXT,
    "promptTokens" INTEGER,
    "completionTokens" INTEGER,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ai_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_tool_executions" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID NOT NULL,
    "branchId" UUID,
    "messageId" UUID NOT NULL,
    "toolName" TEXT NOT NULL,
    "input" JSONB NOT NULL,
    "output" JSONB,
    "succeeded" BOOLEAN NOT NULL,
    "errorCode" TEXT,
    "startedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMPTZ(3),

    CONSTRAINT "ai_tool_executions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "knowledge_documents" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID,
    "branchId" UUID,
    "title" TEXT NOT NULL,
    "storageKey" TEXT NOT NULL,
    "mediaType" TEXT NOT NULL,
    "sha256" TEXT NOT NULL,
    "language" TEXT NOT NULL,
    "consentedAt" TIMESTAMPTZ(3),
    "dataQualityStatus" "DataQualityStatus" NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "knowledge_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "knowledge_chunks" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID,
    "branchId" UUID,
    "documentId" UUID NOT NULL,
    "chunkIndex" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "tokenCount" INTEGER NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "knowledge_chunks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID,
    "branchId" UUID,
    "actorId" UUID,
    "action" "AuditAction" NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" UUID,
    "requestId" TEXT,
    "ipAddress" TEXT,
    "before" JSONB,
    "after" JSONB,
    "metadata" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "data_export_requests" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID,
    "branchId" UUID,
    "requestedById" UUID NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'PENDING',
    "storageKey" TEXT,
    "expiresAt" TIMESTAMPTZ(3),
    "completedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "data_export_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "data_deletion_requests" (
    "id" UUID NOT NULL,
    "organizationId" UUID NOT NULL,
    "restaurantId" UUID,
    "branchId" UUID,
    "requestedById" UUID NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'PENDING',
    "reason" TEXT NOT NULL,
    "approvedById" UUID,
    "approvedAt" TIMESTAMPTZ(3),
    "completedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "data_deletion_requests_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "organizations_slug_key" ON "organizations"("slug");

-- CreateIndex
CREATE INDEX "restaurants_organizationId_idx" ON "restaurants"("organizationId");

-- CreateIndex
CREATE UNIQUE INDEX "restaurants_organizationId_name_key" ON "restaurants"("organizationId", "name");

-- CreateIndex
CREATE INDEX "branches_organizationId_restaurantId_idx" ON "branches"("organizationId", "restaurantId");

-- CreateIndex
CREATE UNIQUE INDEX "branches_organizationId_restaurantId_code_key" ON "branches"("organizationId", "restaurantId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "memberships_userId_idx" ON "memberships"("userId");

-- CreateIndex
CREATE INDEX "memberships_organizationId_restaurantId_branchId_idx" ON "memberships"("organizationId", "restaurantId", "branchId");

-- CreateIndex
CREATE UNIQUE INDEX "memberships_organizationId_restaurantId_branchId_userId_key" ON "memberships"("organizationId", "restaurantId", "branchId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "invitations_tokenHash_key" ON "invitations"("tokenHash");

-- CreateIndex
CREATE INDEX "invitations_organizationId_email_idx" ON "invitations"("organizationId", "email");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_tokenHash_key" ON "sessions"("tokenHash");

-- CreateIndex
CREATE INDEX "sessions_organizationId_userId_idx" ON "sessions"("organizationId", "userId");

-- CreateIndex
CREATE INDEX "sessions_expiresAt_idx" ON "sessions"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "password_reset_tokens_tokenHash_key" ON "password_reset_tokens"("tokenHash");

-- CreateIndex
CREATE INDEX "password_reset_tokens_userId_expiresAt_idx" ON "password_reset_tokens"("userId", "expiresAt");

-- CreateIndex
CREATE INDEX "sales_channels_organizationId_restaurantId_branchId_idx" ON "sales_channels"("organizationId", "restaurantId", "branchId");

-- CreateIndex
CREATE UNIQUE INDEX "sales_channels_organizationId_restaurantId_branchId_externa_key" ON "sales_channels"("organizationId", "restaurantId", "branchId", "externalId");

-- CreateIndex
CREATE INDEX "menu_categories_organizationId_restaurantId_idx" ON "menu_categories"("organizationId", "restaurantId");

-- CreateIndex
CREATE UNIQUE INDEX "menu_categories_organizationId_restaurantId_externalId_key" ON "menu_categories"("organizationId", "restaurantId", "externalId");

-- CreateIndex
CREATE INDEX "menu_items_organizationId_restaurantId_categoryId_idx" ON "menu_items"("organizationId", "restaurantId", "categoryId");

-- CreateIndex
CREATE UNIQUE INDEX "menu_items_organizationId_restaurantId_externalId_key" ON "menu_items"("organizationId", "restaurantId", "externalId");

-- CreateIndex
CREATE UNIQUE INDEX "menu_items_organizationId_restaurantId_sku_key" ON "menu_items"("organizationId", "restaurantId", "sku");

-- CreateIndex
CREATE INDEX "menu_item_costs_organizationId_restaurantId_branchId_menuIt_idx" ON "menu_item_costs"("organizationId", "restaurantId", "branchId", "menuItemId");

-- CreateIndex
CREATE UNIQUE INDEX "menu_item_costs_organizationId_restaurantId_branchId_menuIt_key" ON "menu_item_costs"("organizationId", "restaurantId", "branchId", "menuItemId", "effectiveFrom");

-- CreateIndex
CREATE INDEX "ingredients_organizationId_restaurantId_idx" ON "ingredients"("organizationId", "restaurantId");

-- CreateIndex
CREATE UNIQUE INDEX "ingredients_organizationId_restaurantId_externalId_key" ON "ingredients"("organizationId", "restaurantId", "externalId");

-- CreateIndex
CREATE UNIQUE INDEX "ingredients_organizationId_restaurantId_name_key" ON "ingredients"("organizationId", "restaurantId", "name");

-- CreateIndex
CREATE INDEX "recipes_organizationId_restaurantId_idx" ON "recipes"("organizationId", "restaurantId");

-- CreateIndex
CREATE UNIQUE INDEX "recipes_organizationId_restaurantId_menuItemId_version_key" ON "recipes"("organizationId", "restaurantId", "menuItemId", "version");

-- CreateIndex
CREATE INDEX "recipe_ingredients_organizationId_restaurantId_recipeId_idx" ON "recipe_ingredients"("organizationId", "restaurantId", "recipeId");

-- CreateIndex
CREATE UNIQUE INDEX "recipe_ingredients_organizationId_restaurantId_recipeId_ing_key" ON "recipe_ingredients"("organizationId", "restaurantId", "recipeId", "ingredientId");

-- CreateIndex
CREATE INDEX "orders_organizationId_restaurantId_branchId_orderedAt_idx" ON "orders"("organizationId", "restaurantId", "branchId", "orderedAt");

-- CreateIndex
CREATE UNIQUE INDEX "orders_organizationId_restaurantId_branchId_sourceSystem_ex_key" ON "orders"("organizationId", "restaurantId", "branchId", "sourceSystem", "externalId");

-- CreateIndex
CREATE INDEX "order_items_organizationId_restaurantId_branchId_orderId_idx" ON "order_items"("organizationId", "restaurantId", "branchId", "orderId");

-- CreateIndex
CREATE UNIQUE INDEX "order_items_organizationId_restaurantId_branchId_orderId_ex_key" ON "order_items"("organizationId", "restaurantId", "branchId", "orderId", "externalId");

-- CreateIndex
CREATE INDEX "discounts_organizationId_restaurantId_branchId_occurredAt_idx" ON "discounts"("organizationId", "restaurantId", "branchId", "occurredAt");

-- CreateIndex
CREATE UNIQUE INDEX "discounts_organizationId_restaurantId_branchId_orderId_exte_key" ON "discounts"("organizationId", "restaurantId", "branchId", "orderId", "externalId");

-- CreateIndex
CREATE INDEX "refunds_organizationId_restaurantId_branchId_refundedAt_idx" ON "refunds"("organizationId", "restaurantId", "branchId", "refundedAt");

-- CreateIndex
CREATE UNIQUE INDEX "refunds_organizationId_restaurantId_branchId_externalId_key" ON "refunds"("organizationId", "restaurantId", "branchId", "externalId");

-- CreateIndex
CREATE INDEX "delivery_commissions_organizationId_restaurantId_branchId_c_idx" ON "delivery_commissions"("organizationId", "restaurantId", "branchId", "chargedAt");

-- CreateIndex
CREATE UNIQUE INDEX "delivery_commissions_organizationId_restaurantId_branchId_o_key" ON "delivery_commissions"("organizationId", "restaurantId", "branchId", "orderId", "externalId");

-- CreateIndex
CREATE INDEX "operating_costs_organizationId_restaurantId_branchId_incurr_idx" ON "operating_costs"("organizationId", "restaurantId", "branchId", "incurredAt");

-- CreateIndex
CREATE UNIQUE INDEX "operating_costs_organizationId_restaurantId_branchId_source_key" ON "operating_costs"("organizationId", "restaurantId", "branchId", "sourceSystem", "externalId");

-- CreateIndex
CREATE INDEX "labor_costs_organizationId_restaurantId_branchId_workDate_idx" ON "labor_costs"("organizationId", "restaurantId", "branchId", "workDate");

-- CreateIndex
CREATE UNIQUE INDEX "labor_costs_organizationId_restaurantId_branchId_sourceSyst_key" ON "labor_costs"("organizationId", "restaurantId", "branchId", "sourceSystem", "externalId");

-- CreateIndex
CREATE INDEX "import_jobs_organizationId_restaurantId_branchId_createdAt_idx" ON "import_jobs"("organizationId", "restaurantId", "branchId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "import_files_storageKey_key" ON "import_files"("storageKey");

-- CreateIndex
CREATE INDEX "import_files_organizationId_restaurantId_importJobId_idx" ON "import_files"("organizationId", "restaurantId", "importJobId");

-- CreateIndex
CREATE UNIQUE INDEX "import_files_organizationId_restaurantId_sha256_key" ON "import_files"("organizationId", "restaurantId", "sha256");

-- CreateIndex
CREATE INDEX "import_mappings_organizationId_restaurantId_importJobId_idx" ON "import_mappings"("organizationId", "restaurantId", "importJobId");

-- CreateIndex
CREATE UNIQUE INDEX "import_mappings_organizationId_restaurantId_importJobId_sou_key" ON "import_mappings"("organizationId", "restaurantId", "importJobId", "sourceColumn");

-- CreateIndex
CREATE INDEX "import_row_errors_organizationId_restaurantId_importJobId_r_idx" ON "import_row_errors"("organizationId", "restaurantId", "importJobId", "rowNumber");

-- CreateIndex
CREATE INDEX "import_batches_organizationId_restaurantId_branchId_importJ_idx" ON "import_batches"("organizationId", "restaurantId", "branchId", "importJobId");

-- CreateIndex
CREATE UNIQUE INDEX "import_batches_organizationId_restaurantId_importJobId_batc_key" ON "import_batches"("organizationId", "restaurantId", "importJobId", "batchNumber");

-- CreateIndex
CREATE UNIQUE INDEX "import_batches_organizationId_restaurantId_importJobId_chec_key" ON "import_batches"("organizationId", "restaurantId", "importJobId", "checksum");

-- CreateIndex
CREATE INDEX "import_audits_organizationId_restaurantId_importJobId_creat_idx" ON "import_audits"("organizationId", "restaurantId", "importJobId", "createdAt");

-- CreateIndex
CREATE INDEX "metric_snapshots_organizationId_restaurantId_branchId_perio_idx" ON "metric_snapshots"("organizationId", "restaurantId", "branchId", "periodEnd");

-- CreateIndex
CREATE UNIQUE INDEX "metric_snapshots_organizationId_restaurantId_branchId_metri_key" ON "metric_snapshots"("organizationId", "restaurantId", "branchId", "metricKey", "periodStart", "periodEnd", "calculationVersion");

-- CreateIndex
CREATE INDEX "detected_issues_organizationId_restaurantId_branchId_detect_idx" ON "detected_issues"("organizationId", "restaurantId", "branchId", "detectedAt");

-- CreateIndex
CREATE INDEX "recommendations_organizationId_restaurantId_branchId_status_idx" ON "recommendations"("organizationId", "restaurantId", "branchId", "status", "priority");

-- CreateIndex
CREATE INDEX "recommendation_evidence_organizationId_restaurantId_recomme_idx" ON "recommendation_evidence"("organizationId", "restaurantId", "recommendationId");

-- CreateIndex
CREATE INDEX "recommendation_events_organizationId_restaurantId_recommend_idx" ON "recommendation_events"("organizationId", "restaurantId", "recommendationId", "createdAt");

-- CreateIndex
CREATE INDEX "recommendation_notes_organizationId_restaurantId_recommenda_idx" ON "recommendation_notes"("organizationId", "restaurantId", "recommendationId", "createdAt");

-- CreateIndex
CREATE INDEX "outcome_reviews_organizationId_restaurantId_branchId_schedu_idx" ON "outcome_reviews"("organizationId", "restaurantId", "branchId", "scheduledFor");

-- CreateIndex
CREATE UNIQUE INDEX "outcome_reviews_organizationId_restaurantId_recommendationI_key" ON "outcome_reviews"("organizationId", "restaurantId", "recommendationId", "type");

-- CreateIndex
CREATE INDEX "ai_conversations_organizationId_restaurantId_branchId_userI_idx" ON "ai_conversations"("organizationId", "restaurantId", "branchId", "userId", "createdAt");

-- CreateIndex
CREATE INDEX "ai_messages_organizationId_restaurantId_conversationId_crea_idx" ON "ai_messages"("organizationId", "restaurantId", "conversationId", "createdAt");

-- CreateIndex
CREATE INDEX "ai_tool_executions_organizationId_restaurantId_messageId_idx" ON "ai_tool_executions"("organizationId", "restaurantId", "messageId");

-- CreateIndex
CREATE INDEX "knowledge_documents_organizationId_restaurantId_branchId_idx" ON "knowledge_documents"("organizationId", "restaurantId", "branchId");

-- CreateIndex
CREATE UNIQUE INDEX "knowledge_documents_organizationId_storageKey_key" ON "knowledge_documents"("organizationId", "storageKey");

-- CreateIndex
CREATE UNIQUE INDEX "knowledge_documents_organizationId_sha256_key" ON "knowledge_documents"("organizationId", "sha256");

-- CreateIndex
CREATE INDEX "knowledge_chunks_organizationId_restaurantId_branchId_docum_idx" ON "knowledge_chunks"("organizationId", "restaurantId", "branchId", "documentId");

-- CreateIndex
CREATE UNIQUE INDEX "knowledge_chunks_organizationId_documentId_chunkIndex_key" ON "knowledge_chunks"("organizationId", "documentId", "chunkIndex");

-- CreateIndex
CREATE INDEX "audit_logs_organizationId_restaurantId_branchId_createdAt_idx" ON "audit_logs"("organizationId", "restaurantId", "branchId", "createdAt");

-- CreateIndex
CREATE INDEX "audit_logs_entityType_entityId_idx" ON "audit_logs"("entityType", "entityId");

-- CreateIndex
CREATE INDEX "data_export_requests_organizationId_restaurantId_branchId_c_idx" ON "data_export_requests"("organizationId", "restaurantId", "branchId", "createdAt");

-- CreateIndex
CREATE INDEX "data_deletion_requests_organizationId_restaurantId_branchId_idx" ON "data_deletion_requests"("organizationId", "restaurantId", "branchId", "createdAt");

-- Composite candidate keys make tenant identity part of every dependent FK.
CREATE UNIQUE INDEX "restaurants_tenant_identity_key" ON "restaurants"("organizationId", "id");
CREATE UNIQUE INDEX "branches_tenant_identity_key" ON "branches"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "menu_categories_tenant_identity_key" ON "menu_categories"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "menu_items_tenant_identity_key" ON "menu_items"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "ingredients_tenant_identity_key" ON "ingredients"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "recipes_tenant_identity_key" ON "recipes"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "sales_channels_tenant_identity_key" ON "sales_channels"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "orders_tenant_identity_key" ON "orders"("organizationId", "restaurantId", "branchId", "id");
CREATE UNIQUE INDEX "order_items_tenant_identity_key" ON "order_items"("organizationId", "restaurantId", "branchId", "id");
CREATE UNIQUE INDEX "import_jobs_tenant_identity_key" ON "import_jobs"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "import_batches_tenant_identity_key" ON "import_batches"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "metric_snapshots_tenant_identity_key" ON "metric_snapshots"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "detected_issues_tenant_identity_key" ON "detected_issues"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "recommendations_tenant_identity_key" ON "recommendations"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "ai_conversations_tenant_identity_key" ON "ai_conversations"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "ai_messages_tenant_identity_key" ON "ai_messages"("organizationId", "restaurantId", "id");
CREATE UNIQUE INDEX "knowledge_documents_tenant_identity_key" ON "knowledge_documents"("organizationId", "id");

-- Identity and tenant hierarchy.
ALTER TABLE "restaurants" ADD CONSTRAINT "restaurants_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;
ALTER TABLE "branches" ADD CONSTRAINT "branches_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_user_fk" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "invitations" ADD CONSTRAINT "invitations_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;
ALTER TABLE "invitations" ADD CONSTRAINT "invitations_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "invitations" ADD CONSTRAINT "invitations_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "invitations" ADD CONSTRAINT "invitations_invited_by_fk" FOREIGN KEY ("invitedById") REFERENCES "users"("id") ON DELETE RESTRICT;
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_fk" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "password_reset_tokens" ADD CONSTRAINT "password_reset_tokens_user_fk" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE;

-- Restaurant operational data.
ALTER TABLE "sales_channels" ADD CONSTRAINT "sales_channels_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "sales_channels" ADD CONSTRAINT "sales_channels_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "menu_categories" ADD CONSTRAINT "menu_categories_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "menu_items" ADD CONSTRAINT "menu_items_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "menu_items" ADD CONSTRAINT "menu_items_category_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "categoryId") REFERENCES "menu_categories"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "menu_item_costs" ADD CONSTRAINT "menu_item_costs_menu_item_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "menuItemId") REFERENCES "menu_items"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "menu_item_costs" ADD CONSTRAINT "menu_item_costs_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "ingredients" ADD CONSTRAINT "ingredients_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "recipes" ADD CONSTRAINT "recipes_menu_item_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "menuItemId") REFERENCES "menu_items"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "recipe_ingredients" ADD CONSTRAINT "recipe_ingredients_recipe_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "recipeId") REFERENCES "recipes"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "recipe_ingredients" ADD CONSTRAINT "recipe_ingredients_ingredient_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "ingredientId") REFERENCES "ingredients"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "orders" ADD CONSTRAINT "orders_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "orders" ADD CONSTRAINT "orders_sales_channel_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "salesChannelId") REFERENCES "sales_channels"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_order_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId", "orderId") REFERENCES "orders"("organizationId", "restaurantId", "branchId", "id") ON DELETE CASCADE;
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_menu_item_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "menuItemId") REFERENCES "menu_items"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "discounts" ADD CONSTRAINT "discounts_order_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId", "orderId") REFERENCES "orders"("organizationId", "restaurantId", "branchId", "id") ON DELETE CASCADE;
ALTER TABLE "discounts" ADD CONSTRAINT "discounts_order_item_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId", "orderItemId") REFERENCES "order_items"("organizationId", "restaurantId", "branchId", "id") ON DELETE CASCADE;
ALTER TABLE "refunds" ADD CONSTRAINT "refunds_order_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId", "orderId") REFERENCES "orders"("organizationId", "restaurantId", "branchId", "id") ON DELETE CASCADE;
ALTER TABLE "delivery_commissions" ADD CONSTRAINT "delivery_commissions_order_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId", "orderId") REFERENCES "orders"("organizationId", "restaurantId", "branchId", "id") ON DELETE CASCADE;
ALTER TABLE "delivery_commissions" ADD CONSTRAINT "delivery_commissions_channel_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "salesChannelId") REFERENCES "sales_channels"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "operating_costs" ADD CONSTRAINT "operating_costs_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "operating_costs" ADD CONSTRAINT "operating_costs_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "labor_costs" ADD CONSTRAINT "labor_costs_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;

-- Imports and deterministic source deduplication.
ALTER TABLE "import_jobs" ADD CONSTRAINT "import_jobs_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "import_jobs" ADD CONSTRAINT "import_jobs_branch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "branchId") REFERENCES "branches"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "import_jobs" ADD CONSTRAINT "import_jobs_requested_by_fk" FOREIGN KEY ("requestedById") REFERENCES "users"("id") ON DELETE RESTRICT;
ALTER TABLE "import_files" ADD CONSTRAINT "import_files_job_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importJobId") REFERENCES "import_jobs"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "import_mappings" ADD CONSTRAINT "import_mappings_job_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importJobId") REFERENCES "import_jobs"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "import_row_errors" ADD CONSTRAINT "import_row_errors_job_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importJobId") REFERENCES "import_jobs"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "import_batches" ADD CONSTRAINT "import_batches_job_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importJobId") REFERENCES "import_jobs"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "import_audits" ADD CONSTRAINT "import_audits_job_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importJobId") REFERENCES "import_jobs"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "orders" ADD CONSTRAINT "orders_import_batch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importBatchId") REFERENCES "import_batches"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "operating_costs" ADD CONSTRAINT "operating_costs_import_batch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importBatchId") REFERENCES "import_batches"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "labor_costs" ADD CONSTRAINT "labor_costs_import_batch_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "importBatchId") REFERENCES "import_batches"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;

-- Decisions, AI, knowledge, and governance.
ALTER TABLE "metric_snapshots" ADD CONSTRAINT "metric_snapshots_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "detected_issues" ADD CONSTRAINT "detected_issues_metric_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "metricSnapshotId") REFERENCES "metric_snapshots"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "recommendations" ADD CONSTRAINT "recommendations_issue_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "detectedIssueId") REFERENCES "detected_issues"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "recommendation_evidence" ADD CONSTRAINT "recommendation_evidence_recommendation_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "recommendationId") REFERENCES "recommendations"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "recommendation_evidence" ADD CONSTRAINT "recommendation_evidence_metric_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "metricSnapshotId") REFERENCES "metric_snapshots"("organizationId", "restaurantId", "id") ON DELETE RESTRICT;
ALTER TABLE "recommendation_events" ADD CONSTRAINT "recommendation_events_recommendation_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "recommendationId") REFERENCES "recommendations"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "recommendation_notes" ADD CONSTRAINT "recommendation_notes_recommendation_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "recommendationId") REFERENCES "recommendations"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "outcome_reviews" ADD CONSTRAINT "outcome_reviews_recommendation_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "recommendationId") REFERENCES "recommendations"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "ai_conversations" ADD CONSTRAINT "ai_conversations_restaurant_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId") REFERENCES "restaurants"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "ai_messages" ADD CONSTRAINT "ai_messages_conversation_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "conversationId") REFERENCES "ai_conversations"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "ai_tool_executions" ADD CONSTRAINT "ai_tool_executions_message_tenant_fk" FOREIGN KEY ("organizationId", "restaurantId", "messageId") REFERENCES "ai_messages"("organizationId", "restaurantId", "id") ON DELETE CASCADE;
ALTER TABLE "knowledge_documents" ADD CONSTRAINT "knowledge_documents_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;
ALTER TABLE "knowledge_chunks" ADD CONSTRAINT "knowledge_chunks_document_tenant_fk" FOREIGN KEY ("organizationId", "documentId") REFERENCES "knowledge_documents"("organizationId", "id") ON DELETE CASCADE;
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;
ALTER TABLE "data_export_requests" ADD CONSTRAINT "data_export_requests_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;
ALTER TABLE "data_deletion_requests" ADD CONSTRAINT "data_deletion_requests_organization_fk" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE;

-- Domain integrity checks.
ALTER TABLE "restaurants" ADD CONSTRAINT "restaurants_currency_check" CHECK ("currency" ~ '^[A-Z]{3}$');
ALTER TABLE "menu_items" ADD CONSTRAINT "menu_items_currency_check" CHECK ("currency" ~ '^[A-Z]{3}$');
ALTER TABLE "orders" ADD CONSTRAINT "orders_currency_check" CHECK ("currency" ~ '^[A-Z]{3}$');
ALTER TABLE "orders" ADD CONSTRAINT "orders_amounts_nonnegative_check" CHECK ("subtotal" >= 0 AND "discountTotal" >= 0 AND "refundTotal" >= 0 AND "taxTotal" >= 0 AND "total" >= 0);
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_quantity_positive_check" CHECK ("quantity" > 0);
ALTER TABLE "import_batches" ADD CONSTRAINT "import_batches_row_range_check" CHECK ("sourceStartRow" > 0 AND "sourceEndRow" >= "sourceStartRow");

-- RLS is defense in depth. The API role sets app.organization_id per transaction.
DO $$
DECLARE tenant_table text;
BEGIN
  FOREACH tenant_table IN ARRAY ARRAY[
    'restaurants', 'branches', 'memberships', 'invitations', 'sessions',
    'sales_channels', 'menu_categories', 'menu_items', 'menu_item_costs',
    'ingredients', 'recipes', 'recipe_ingredients', 'orders', 'order_items',
    'discounts', 'refunds', 'delivery_commissions', 'operating_costs',
    'labor_costs', 'import_jobs', 'import_files', 'import_mappings',
    'import_row_errors', 'import_batches', 'import_audits', 'metric_snapshots',
    'detected_issues', 'recommendations', 'recommendation_evidence',
    'recommendation_events', 'recommendation_notes', 'outcome_reviews',
    'ai_conversations', 'ai_messages', 'ai_tool_executions',
    'knowledge_documents', 'knowledge_chunks', 'audit_logs',
    'data_export_requests', 'data_deletion_requests'
  ]
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tenant_table);
    EXECUTE format(
      'CREATE POLICY tenant_isolation ON %I USING ("organizationId" = NULLIF(current_setting(''app.organization_id'', true), '''')::uuid) WITH CHECK ("organizationId" = NULLIF(current_setting(''app.organization_id'', true), '''')::uuid)',
      tenant_table
    );
  END LOOP;
END
$$;
