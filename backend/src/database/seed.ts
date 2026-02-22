import { pool } from './pool';

async function seed() {
  try {
    await pool.query(`CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name TEXT)`);
    await pool.query(`INSERT INTO users (name) VALUES ('Alice') WHERE NOT EXISTS`);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

seed();
