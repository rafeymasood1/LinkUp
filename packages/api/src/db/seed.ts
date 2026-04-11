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
