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
