import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { TypeOrmModule } from "@nestjs/typeorm";
import { User } from "./user/entities/user.entity";
import { TokensEntity } from "./tokens/entities/tokens.entity";
import { TokensModule } from "./tokens/tokens.module";

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      password: 'test1234',
      username: 'postgres',
      entities: [User, TokensEntity], // here we have added user enitity in entities array
      database: 'tickets',
      synchronize: true,
      logging: true,
    }),
    UserModule,
    AuthModule,
    TokensModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
