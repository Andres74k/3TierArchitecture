import { Client } from 'pg';

const client = new Client({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

async function seed() {
  await client.connect();

  await client.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name TEXT
    );
  `);

  await client.query(`
    INSERT INTO users (name) VALUES ('Alice'), ('Bob') WHERE NOT EXISTS;
  `);

  await client.end();
}

seed();
