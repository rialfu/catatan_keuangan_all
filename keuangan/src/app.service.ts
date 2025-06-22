import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Injectable()
export class AppService {
  constructor(
    @InjectDataSource() private dataSource: DataSource
      
  ) { 
  }
  getHello(): any {
    const option = this.dataSource.options
    return option;
    return 'Hello World!';
  }
}
