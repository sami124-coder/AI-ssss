import type { ErrorRequestHandler, RequestHandler } from 'express';
import { HttpError, isHttpError } from '@rda/shared';
import type { Logger } from 'pino';

export const notFoundHandler: RequestHandler = (_request, _response, next) => {
  next(new HttpError(404, 'not_found', 'Route not found'));
};

export function errorHandler(logger: Logger): ErrorRequestHandler {
  return (error, request, response, next) => {
    void next;
    const httpError = isHttpError(error)
      ? error
      : new HttpError(500, 'internal_error', 'An unexpected error occurred');

    if (httpError.statusCode >= 500) {
      logger.error({ err: error, requestId: request.id }, 'Request failed');
    }

    response.status(httpError.statusCode).json({
      error: {
        code: httpError.code,
        message: httpError.message,
        requestId: request.id,
      },
    });
  };
}
