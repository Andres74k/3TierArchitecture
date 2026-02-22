import { pool } from './pool';

async function seed() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name TEXT UNIQUE
      )
    `);

    await pool.query(`
      INSERT INTO users (name)
      VALUES ('Alice'), ('Pedro'), ('Diego'), ('Angelica'), ('Juan')
      ON CONFLICT (name) DO NOTHING
    `);

    console.log('Seed completed');
  } catch (err) {
    console.error('Seed failed:', err);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

seed();
