CREATE TABLE "service_metadata" (
    "id" UUID NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "service_metadata_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "service_metadata_key_key" ON "service_metadata"("key");
