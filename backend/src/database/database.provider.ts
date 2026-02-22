import { pool } from './pool';

export const DatabaseProvider = {
  provide: 'PG_POOL',
  useValue: pool,
};
