import Fastify from 'fastify';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import rateLimit from '@fastify/rate-limit';
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod';
import { env } from './env';
import { authRoutes } from './routes/auth';
import { userRoutes } from './routes/users';
import { postRoutes } from './routes/posts';

const app = Fastify({ logger: true });

app.setValidatorCompiler(validatorCompiler);
app.setSerializerCompiler(serializerCompiler);

async function start() {
  await app.register(cors, {
    origin: env.NODE_ENV === 'development' ? true : 'https://yourapp.com',
  });
  await app.register(jwt, { secret: env.JWT_SECRET });
  await app.register(rateLimit, { max: 100, timeWindow: '1 minute' });

  await app.register(authRoutes, { prefix: '/api/auth' });
  await app.register(userRoutes, { prefix: '/api/users' });
  await app.register(postRoutes, { prefix: '/api/posts' });

  app.get('/health', () => ({ status: 'ok' }));

  await app.listen({ port: env.PORT, host: '0.0.0.0' });
}

start().catch((err) => {
  console.error(err);
  process.exit(1);
});
