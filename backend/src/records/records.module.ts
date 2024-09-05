import { Module } from '@nestjs/common';
import { RecordsService } from './records.service';
import { RecordsController } from './records.controller';
import { TypeOrmModule } from "@nestjs/typeorm";
import { Record } from "./entities/record.entity";
import { User } from "../user/entities/user.entity";
import { UserService } from "../user/user.service";
import { TokensEntity } from "../tokens/entities/tokens.entity";
import { APP_GUARD } from "@nestjs/core";
import { AuthGuard } from "../auth/auth.guard";
import { TokensService } from "../tokens/tokens.service";

@Module({
  imports: [TypeOrmModule.forFeature([Record, User, TokensEntity])],
  controllers: [RecordsController],
  providers: [
    RecordsService,
    UserService,
    TokensService,
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    }],
  exports: [RecordsService]
})
export class RecordsModule {}
