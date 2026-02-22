import { pool } from './pool';

async function seed() {
  try {
    await pool.query(`CREATE TABLE IF NOT EXISTS users (...)`);
    await pool.query(`INSERT INTO users (name) VALUES ('Alice')`);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

seed();
