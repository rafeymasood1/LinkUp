# LinkUp

A full-stack social platform built with a **Turborepo** monorepo, featuring a **React** frontend, **Fastify** API, and **PostgreSQL** database.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Monorepo** | Turborepo + npm workspaces |
| **Frontend** | React 19, Vite, React Router, TanStack Query, Zustand, React Hook Form |
| **Backend** | Fastify, Drizzle ORM, Zod validation |
| **Database** | PostgreSQL 16 |
| **Cache** | Redis 7 |
| **Auth** | JWT (`@fastify/jwt`) |
| **Language** | TypeScript 5 |
| **Testing** | Vitest, React Testing Library |
| **Linting** | ESLint 9, Prettier |

## Project Structure

```
LinkUp/
├── packages/
│   ├── api/            # Fastify REST API (port 4000)
│   ├── web/            # React + Vite SPA (port 3000)
│   └── shared/         # Shared types, schemas & utilities
├── scripts/            # Helper scripts (DB readiness check)
├── docker-compose.yml  # PostgreSQL, Redis & app services
├── turbo.json          # Turborepo task configuration
└── package.json        # Root workspace config
```

## Prerequisites

- [Node.js](https://nodejs.org/) **≥ 20**
- [npm](https://www.npmjs.com/) **≥ 10**
- [Docker](https://www.docker.com/) & Docker Compose (for PostgreSQL and Redis)
- [VS Code](https://code.visualstudio.com/) (recommended)

## Getting Started in VS Code

### Option A — Dev Containers (Recommended)

This is the easiest way to get a fully working environment with zero local setup.

1. Install the **[Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)** VS Code extension.
2. Open the project folder in VS Code.
3. When prompted, click **"Reopen in Container"** (or run the command `Dev Containers: Reopen in Container` from the Command Palette).
4. The container will automatically:
   - Install all npm dependencies
   - Wait for the database to be ready
   - Run database migrations and seed data
5. Start the development servers:
   ```bash
   npm run dev
   ```
6. Open the app:
   - **Frontend:** <http://localhost:3000>
   - **API:** <http://localhost:4000>
   - **Health check:** <http://localhost:4000/health>

### Option B — Local Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/rafeymasood1/LinkUp.git
   cd LinkUp
   ```

2. **Start PostgreSQL and Redis with Docker**
   ```bash
   docker compose up -d db cache
   ```

3. **Create your environment file**
   ```bash
   cp .env.example packages/api/.env
   ```
   Update `DATABASE_URL` to point to localhost if running outside Docker:
   ```
   DATABASE_URL=postgresql://postgres:postgres@localhost:5432/appdb
   REDIS_URL=redis://localhost:6379
   JWT_SECRET=changeme_generate_a_real_secret_minimum_32_chars
   PORT=4000
   ```

4. **Install dependencies**
   ```bash
   npm install
   ```

5. **Set up the database**
   ```bash
   npm run db:generate   # Generate migration files from the schema
   npm run db:migrate    # Apply migrations to PostgreSQL
   npm run db:seed       # Seed the database with sample data
   ```

6. **Start the development servers**
   ```bash
   npm run dev
   ```
   This runs both the API and web app concurrently via Turborepo.

7. **Open the app:**
   - **Frontend:** <http://localhost:3000>
   - **API:** <http://localhost:4000>
   - **Health check:** <http://localhost:4000/health>

## Available Scripts

Run these from the **project root**:

| Command | Description |
|---------|-------------|
| `npm run dev` | Start all packages in development mode |
| `npm run build` | Build all packages |
| `npm run lint` | Lint all packages |
| `npm run test` | Run tests across all packages |
| `npm run typecheck` | Type-check all packages |
| `npm run format` | Format code with Prettier |
| `npm run db:generate` | Generate Drizzle migration files |
| `npm run db:migrate` | Apply database migrations |
| `npm run db:seed` | Seed the database |

## Recommended VS Code Extensions

These are auto-installed when using Dev Containers. Install them manually for local development:

- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) — Linting
- [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) — Code formatting
- [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) — Docker support
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) — Git history & blame
- [Vitest](https://marketplace.visualstudio.com/items?itemName=vitest.explorer) — Test runner integration

## API Routes

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `*` | `/api/auth/*` | Authentication (register, login) |
| `*` | `/api/users/*` | User profiles & follows |
| `*` | `/api/posts/*` | Posts CRUD & likes |

## License

This project is private.
