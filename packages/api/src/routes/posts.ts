import type { FastifyPluginAsync } from 'fastify';

export const postRoutes: FastifyPluginAsync = async (app) => {
  app.get('/', async () => {
    return { message: 'posts route placeholder' };
  });
};
