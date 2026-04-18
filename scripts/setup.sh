#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────
#  LinkUp — full project scaffold
#  Run from your HOST machine (not inside a container)
#  Usage: bash setup-linkup.sh
# ─────────────────────────────────────────────

PROJECT="LinkUp"
echo "🚀 Scaffolding $PROJECT..."

mkdir -p "$PROJECT"
cd "$PROJECT"

# ── Git init ────────────────────────────────
git init
echo "✔ git init"

# ── Root files ──────────────────────────────
cat >.gitattributes <<'EOF'
* text=auto eol=lf
*.png binary
*.jpg binary
*.gif binary
*.ico binary
*.zip binary
*.gz binary
EOF

cat >.gitignore <<'EOF'
node_modules/
dist/
.turbo/
coverage/
.env
.env.local
.env.*.local
*.tsbuildinfo
EOF

cat >.prettierrc <<'EOF'
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "tabWidth": 2,
  "printWidth": 100,
  "arrowParens": "always"
}
EOF

cat >eslint.config.js <<'EOF'
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import reactHooks from 'eslint-plugin-react-hooks';

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: { 'react-hooks': reactHooks },
    rules: {
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'error',
    },
  },
  { ignores: ['node_modules/**', 'dist/**', '.turbo/**'] }
);
EOF

cat >.env.example <<'EOF'
NODE_ENV=development
DATABASE_URL=postgresql://postgres:postgres@db:5432/appdb
REDIS_URL=redis://cache:6379
JWT_SECRET=changeme_generate_a_real_secret_minimum_32_chars
PORT=4000
VITE_API_BASE_URL=http://localhost:4000
EOF

cat >docker-compose.yml <<'EOF'
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/workspaces/LinkUp:cached
      - node_modules:/workspaces/LinkUp/node_modules
    ports:
      - "3000:3000"
      - "4000:4000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/appdb
      - REDIS_URL=redis://cache:6379
      - JWT_SECRET=dev_secret_minimum_32_characters_long_ok
      - PORT=4000
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    command: sleep infinity

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: appdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  cache:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  node_modules:
  postgres_data:
  redis_data:
EOF

cat >Dockerfile.dev <<'EOF'
FROM node:20-alpine
RUN apk add --no-cache git curl bash
WORKDIR /workspaces/LinkUp
USER root
EOF

cat >turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": { "dependsOn": ["^build"] },
    "typecheck": { "dependsOn": ["^build"] },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    }
  }
}
EOF

cat >package.json <<'EOF'
{
  "name": "linkup",
  "private": true,
  "packageManager": "npm@10.8.2",
  "workspaces": ["packages/*"],
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "typecheck": "turbo run typecheck",
    "format": "prettier --write \"**/*.{ts,tsx,js,json,md}\"",
    "db:generate": "npm run generate --workspace=packages/api",
    "db:migrate": "npm run migrate --workspace=packages/api",
    "db:seed": "npm run seed --workspace=packages/api"
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "eslint": "^9.0.0",
    "eslint-plugin-react-hooks": "^5.0.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.0.0",
    "prettier": "^3.0.0",
    "turbo": "^2.0.0",
    "typescript": "^5.5.0",
    "typescript-eslint": "^8.0.0"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{js,json,md}": ["prettier --write"]
  },
  "engines": {
    "node": ">=20.0.0",
    "npm": ">=10.0.0"
  }
}
EOF

echo "✔ root files"

# ── .devcontainer ────────────────────────────
mkdir -p .devcontainer

cat >.devcontainer/devcontainer.json <<'EOF'
{
  "name": "LinkUp Dev",
  "dockerComposeFile": [
    "../docker-compose.yml",
    "docker-compose.yml"
  ],
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "features": {
    "ghcr.io/devcontainers/features/git:1": {}
  },
  "forwardPorts": [3000, 4000, 5432, 6379],
  "portsAttributes": {
    "3000": { "label": "Web (Vite)" },
    "4000": { "label": "API (Fastify)" },
    "5432": { "label": "PostgreSQL" },
    "6379": { "label": "Redis" }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "ms-azuretools.vscode-docker",
        "eamodio.gitlens",
        "vitest.explorer"
      ],
      "settings": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.codeActionsOnSave": {
          "source.fixAll.eslint": "explicit"
        },
        "typescript.tsdk": "node_modules/typescript/lib"
      }
    }
  },
  "postCreateCommand": "npm install && node scripts/wait-for-db.mjs && npm run db:migrate && npm run db:seed",
  "remoteUser": "root"
}
EOF

cat >.devcontainer/docker-compose.yml <<'EOF'
version: '3.9'
services:
  app:
    volumes:
      - /workspaces/LinkUp/node_modules
EOF

echo "✔ .devcontainer"

# ── scripts ──────────────────────────────────
mkdir -p scripts

cat >scripts/wait-for-db.mjs <<'EOF'
import { Client } from 'pg';

const url = process.env.DATABASE_URL ?? 'postgresql://postgres:postgres@db:5432/appdb';
const maxAttempts = 30;

for (let i = 1; i <= maxAttempts; i++) {
  try {
    const client = new Client({ connectionString: url });
    await client.connect();
    await client.end();
    console.log('✅ Database is ready');
    process.exit(0);
  } catch {
    console.log(`⏳ Waiting for database... (attempt ${i}/${maxAttempts})`);
    await new Promise(r => setTimeout(r, 2000));
  }
}

console.error('❌ Database never became ready');
process.exit(1);
EOF

echo "✔ scripts"

# ── packages/shared ──────────────────────────
mkdir -p packages/shared/src/{schemas,types}

cat >packages/shared/package.json <<'EOF'
{
  "name": "@myapp/shared",
  "version": "0.0.1",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0"
  }
}
EOF

cat >packages/shared/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "declaration": true,
    "outDir": "./dist"
  },
  "include": ["src"]
}
EOF

cat >packages/shared/src/schemas/user.schema.ts <<'EOF'
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email('Invalid email format'),
  username: z.string().min(3).max(30).regex(/^[a-zA-Z0-9_]+$/),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

export const UserResponseSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  username: z.string(),
  createdAt: z.string().datetime(),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type UserResponse = z.infer<typeof UserResponseSchema>;
EOF

cat >packages/shared/src/schemas/post.schema.ts <<'EOF'
import { z } from 'zod';

export const CreatePostSchema = z.object({
  content: z.string().min(1).max(500),
  mediaUrl: z.string().url().optional(),
});

export const PostResponseSchema = z.object({
  id: z.string().uuid(),
  content: z.string(),
  authorId: z.string().uuid(),
  createdAt: z.string().datetime(),
  likesCount: z.number().int().nonnegative(),
});

export type CreatePostInput = z.infer<typeof CreatePostSchema>;
export type PostResponse = z.infer<typeof PostResponseSchema>;
EOF

cat >packages/shared/src/types/api.types.ts <<'EOF'
export type ApiSuccess<T> = {
  success: true;
  data: T;
};

export type ApiError = {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, string[]>;
  };
};

export type ApiResponse<T> = ApiSuccess<T> | ApiError;
EOF

cat >packages/shared/src/index.ts <<'EOF'
export * from './schemas/user.schema';
export * from './schemas/post.schema';
export * from './types/api.types';
EOF

echo "✔ packages/shared"

# ── packages/api ─────────────────────────────
mkdir -p packages/api/src/{routes,services,plugins,db/migrations}

cat >packages/api/package.json <<'EOF'
{
  "name": "@myapp/api",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "dev": "tsx watch --env-file=.env src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "generate": "drizzle-kit generate",
    "migrate": "drizzle-kit migrate",
    "seed": "tsx src/db/seed.ts",
    "test": "vitest run",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src --ext .ts"
  },
  "dependencies": {
    "@myapp/shared": "*",
    "@fastify/cors": "^9.0.0",
    "@fastify/jwt": "^8.0.0",
    "@fastify/rate-limit": "^9.0.0",
    "drizzle-orm": "^0.31.0",
    "fastify": "^4.28.0",
    "fastify-type-provider-zod": "^2.0.0",
    "pg": "^8.12.0",
    "redis": "^4.6.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/pg": "^8.11.0",
    "drizzle-kit": "^0.22.0",
    "tsx": "^4.15.0",
    "typescript": "^5.5.0",
    "vitest": "^2.0.0"
  }
}
EOF

cat >packages/api/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "outDir": "./dist",
    "paths": {
      "@myapp/shared": ["../shared/src/index.ts"]
    }
  },
  "include": ["src"]
}
EOF

cat >packages/api/drizzle.config.ts <<'EOF'
import type { Config } from 'drizzle-kit';

export default {
  schema: './src/db/schema.ts',
  out: './src/db/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL ?? 'postgresql://postgres:postgres@db:5432/appdb',
  },
} satisfies Config;
EOF

cat >packages/api/.env <<'EOF'
DATABASE_URL=postgresql://postgres:postgres@db:5432/appdb
REDIS_URL=redis://cache:6379
JWT_SECRET=dev_secret_minimum_32_characters_long_ok
NODE_ENV=development
PORT=4000
EOF

cat >packages/api/src/env.ts <<'EOF'
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  PORT: z.coerce.number().default(4000),
});

const parsed = EnvSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
EOF

cat >packages/api/src/db/schema.ts <<'EOF'
import { pgTable, uuid, varchar, text, timestamp, integer } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  username: varchar('username', { length: 30 }).notNull().unique(),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export const posts = pgTable('posts', {
  id: uuid('id').defaultRandom().primaryKey(),
  content: text('content').notNull(),
  authorId: uuid('author_id').references(() => users.id).notNull(),
  mediaUrl: varchar('media_url', { length: 500 }),
  likesCount: integer('likes_count').default(0).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const follows = pgTable('follows', {
  followerId: uuid('follower_id').references(() => users.id).notNull(),
  followingId: uuid('following_id').references(() => users.id).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});
EOF

cat >packages/api/src/db/seed.ts <<'EOF'
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import { users, posts, follows } from './schema';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const db = drizzle(pool);

async function seed() {
  console.log('🌱 Seeding database...');
  await db.delete(follows);
  await db.delete(posts);
  await db.delete(users);

  const [alice, bob, carol] = await db.insert(users).values([
    { email: 'alice@example.com', username: 'alice', passwordHash: 'hashed' },
    { email: 'bob@example.com', username: 'bob', passwordHash: 'hashed' },
    { email: 'carol@example.com', username: 'carol', passwordHash: 'hashed' },
  ]).returning();

  await db.insert(posts).values([
    { content: 'Hello from Alice!', authorId: alice.id },
    { content: 'Bob here, just joined!', authorId: bob.id },
    { content: 'Carol checking in', authorId: carol.id },
  ]);

  await db.insert(follows).values([
    { followerId: alice.id, followingId: bob.id },
    { followerId: bob.id, followingId: carol.id },
  ]);

  console.log('✅ Seed complete');
  await pool.end();
}

seed().catch(console.error);
EOF

cat >packages/api/src/routes/auth.ts <<'EOF'
import type { FastifyPluginAsync } from 'fastify';

export const authRoutes: FastifyPluginAsync = async (app) => {
  app.get('/me', async () => {
    return { message: 'auth route placeholder' };
  });
};
EOF

cat >packages/api/src/routes/users.ts <<'EOF'
import type { FastifyPluginAsync } from 'fastify';

export const userRoutes: FastifyPluginAsync = async (app) => {
  app.get('/', async () => {
    return { message: 'users route placeholder' };
  });
};
EOF

cat >packages/api/src/routes/posts.ts <<'EOF'
import type { FastifyPluginAsync } from 'fastify';

export const postRoutes: FastifyPluginAsync = async (app) => {
  app.get('/', async () => {
    return { message: 'posts route placeholder' };
  });
};
EOF

cat >packages/api/src/index.ts <<'EOF'
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
EOF

echo "✔ packages/api"

# ── packages/web ─────────────────────────────
mkdir -p packages/web/src/{components,features/auth/hooks,hooks,pages,lib}

cat >packages/web/package.json <<'EOF'
{
  "name": "@myapp/web",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src --ext .ts,.tsx"
  },
  "dependencies": {
    "@myapp/shared": "*",
    "@tanstack/react-query": "^5.0.0",
    "@hookform/resolvers": "^3.9.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-hook-form": "^7.52.0",
    "react-router-dom": "^6.26.0",
    "zod": "^3.23.0",
    "zustand": "^4.5.0"
  },
  "devDependencies": {
    "@testing-library/react": "^16.0.0",
    "@testing-library/user-event": "^14.5.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "@vitejs/plugin-react": "^4.3.0",
    "typescript": "^5.5.0",
    "vite": "^5.3.0",
    "vitest": "^2.0.0"
  }
}
EOF

cat >packages/web/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@myapp/shared": ["../shared/src/index.ts"]
    }
  },
  "include": ["src"]
}
EOF

cat >packages/web/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    host: '0.0.0.0',
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true,
      },
    },
  },
});
EOF

cat >packages/web/index.html <<'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>LinkUp</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat >packages/web/src/main.tsx <<'EOF'
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import App from './App';

const queryClient = new QueryClient();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  </StrictMode>
);
EOF

cat >packages/web/src/App.tsx <<'EOF'
export default function App() {
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>LinkUp</h1>
      <p>App is running. Start building your features in <code>packages/web/src/features/</code></p>
    </div>
  );
}
EOF

cat >packages/web/src/lib/api-client.ts <<'EOF'
import type { ApiResponse } from '@myapp/shared';

const BASE_URL = '/api';

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  const body: ApiResponse<T> = await res.json();
  if (!body.success) throw new Error(body.error.message);
  return body.data;
}

export const apiClient = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, data: unknown) =>
    request<T>(path, { method: 'POST', body: JSON.stringify(data) }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};
EOF

cat >packages/web/src/features/auth/hooks/use-register.ts <<'EOF'
import { useMutation } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import type { CreateUserInput, UserResponse } from '@myapp/shared';

export function useRegister() {
  return useMutation({
    mutationFn: (data: CreateUserInput) =>
      apiClient.post<UserResponse>('/auth/register', data),
  });
}
EOF

echo "✔ packages/web"

# ── Husky ────────────────────────────────────
mkdir -p .husky
cat >.husky/pre-commit <<'EOF'
npx lint-staged
EOF
chmod +x .husky/pre-commit

echo "✔ .husky"

# ── GitHub ───────────────────────────────────
mkdir -p .github/workflows

cat >.github/PULL_REQUEST_TEMPLATE.md <<'EOF'
## What does this PR do?

## Jira ticket
<!-- https://yourcompany.atlassian.net/browse/PROJ-XXX -->

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactor
- [ ] Tests

## Testing done
- [ ] Unit tests added/updated
- [ ] Manually tested in dev container
EOF

cat >.github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
    branches: ['**']
  pull_request:
    branches: [main]

jobs:
  lint-and-typecheck:
    name: Lint & Typecheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck

  unit-tests:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run test

  integration-tests:
    name: Integration Tests
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7-alpine
        ports: ['6379:6379']
    env:
      DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
      REDIS_URL: redis://localhost:6379
      JWT_SECRET: test_secret_at_least_32_chars_long_ok
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run db:migrate
      - run: npm run test --workspace=packages/api
EOF

echo "✔ .github"

# ── Done ─────────────────────────────────────
echo ""
echo "✅ LinkUp scaffolded successfully!"
echo ""
echo "Next steps:"
echo "  1. cd LinkUp"
echo "  2. Open in VS Code: code ."
echo "  3. When prompted, click 'Reopen in Container'"
echo "  4. Wait for postCreateCommand to finish"
echo "  5. In the container terminal run: npm run db:generate"
echo "  6. Commit migrations: git add . && git commit -m 'chore: initial scaffold'"
echo "  7. Push to GitHub: git push origin main"
echo "  8. Start dev servers: npm run dev"
echo "  9. Visit http://localhost:4000/health and http://localhost:3000"
