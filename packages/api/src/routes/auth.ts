import type { FastifyPluginAsync } from 'fastify';

export const authRoutes: FastifyPluginAsync = async (app) => {
  app.get('/me', async () => {
    return { message: 'auth route placeholder' };
  });
};
