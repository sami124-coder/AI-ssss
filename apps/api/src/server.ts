import 'dotenv/config';
import { createLogger } from '@rda/config';
import { createApp } from './app.js';
import { readApiEnvironment } from './config.js';

const config = readApiEnvironment();
const logger = createLogger(config);
const app = createApp({ config, logger });
const server = app.listen(config.PORT, () => {
  logger.info({ port: config.PORT }, 'API listening');
});
const shutdown = () => {
  server.close(() => {
    logger.info('API stopped');
    process.exit(0);
  });
};
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
