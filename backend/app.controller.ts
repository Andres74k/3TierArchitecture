import { Controller, Get } from '@nestjs/common';
import * as os from 'os';

@Controller()
export class AppController {
  @Get()
  getHello(): string {
    return `Hello from backend: ${os.hostname()}`;
  }
}
