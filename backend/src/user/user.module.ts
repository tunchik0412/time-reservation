import { Module } from '@nestjs/common';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { TypeOrmModule } from "@nestjs/typeorm";
import { User } from "./entities/user.entity";
import { AuthGuard } from "../auth/auth.guard";
import { APP_GUARD } from "@nestjs/core";
import { TokensEntity } from "../tokens/entities/tokens.entity";
import { Record } from "../records/entities/record.entity";
import { RecordsService } from "../records/records.service";
import { TokensService } from "../tokens/tokens.service";

@Module({
  imports: [TypeOrmModule.forFeature([User, TokensEntity, Record])],
  controllers: [UserController],
  providers: [
    UserService,
    RecordsService,
    TokensService,
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    }
  ],
  exports: [UserService]
})
export class UserModule {}
