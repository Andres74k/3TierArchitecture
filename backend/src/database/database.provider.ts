import { Pool } from 'pg';

export const DatabaseProvider = {
  provide: 'PG_POOL',
  useFactory: () => {
    return new Pool({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME,
      port: 5432,
    });
  },
};
