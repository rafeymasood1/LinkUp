import type { FastifyPluginAsync } from 'fastify';

export const userRoutes: FastifyPluginAsync = async (app) => {
  app.get('/', async () => {
    return { message: 'users route placeholder' };
  });
};
