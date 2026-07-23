import { randomUUID } from 'node:crypto';
import type { RequestHandler } from 'express';

export const requestIdMiddleware: RequestHandler = (request, response, next) => {
  request.id = randomUUID();
  response.setHeader('x-request-id', request.id);
  next();
};
