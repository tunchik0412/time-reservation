import { Module } from '@nestjs/common';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { TypeOrmModule } from "@nestjs/typeorm";
import { User } from "./entities/user.entity";
import { AuthGuard } from "../auth/auth.guard";
import { APP_GUARD } from "@nestjs/core";
import { TokensEntity } from "../tokens/entities/tokens.entity";
import { TokensModule } from "../tokens/tokens.module";

@Module({
  imports: [TypeOrmModule.forFeature([User, TokensEntity]), TokensModule],
  controllers: [UserController],
  providers: [
    UserService,
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    }
  ],
  exports: [UserService]
})
export class UserModule {}
