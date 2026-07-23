import { Router } from 'express';
import { healthResponseSchema } from '@rda/shared';

export const healthRouter = Router();

healthRouter.get('/', (_request, response) => {
  response.json(
    healthResponseSchema.parse({
      status: 'ok',
      service: 'restaurant-decision-api',
      timestamp: new Date().toISOString(),
    }),
  );
});
