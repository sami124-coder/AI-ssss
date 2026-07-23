import type { RequestHandler } from 'express';
import type { Logger } from 'pino';

export function requestLoggerMiddleware(logger: Logger): RequestHandler {
  return (request, response, next) => {
    const startedAt = performance.now();
    response.on('finish', () => {
      logger.info(
        {
          requestId: request.id,
          method: request.method,
          path: request.path,
          statusCode: response.statusCode,
          durationMs: Math.round(performance.now() - startedAt),
        },
        'Request completed',
      );
    });
    next();
  };
}
