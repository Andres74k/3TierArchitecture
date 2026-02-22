import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import * as os from 'os';
import { pool } from './pool';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return `Hello from backend: ${os.hostname()}`;
  }

  @Get('users')
  async getUsers() {
    try {
      const res = await this.pool.query('SELECT id, name FROM users');
      return res.rows;
    } catch (err) {
      throw new InternalServerErrorException('Database connection failed');
    }
  }
}
