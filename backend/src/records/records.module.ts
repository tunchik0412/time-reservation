import { Module } from '@nestjs/common';
import { RecordsService } from './records.service';
import { RecordsController } from './records.controller';
import { TypeOrmModule } from "@nestjs/typeorm";
import { Record } from "./entities/record.entity";
import { User } from "../user/entities/user.entity";
import { UserService } from "../user/user.service";
import { TokensEntity } from "../tokens/entities/tokens.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Record, User, TokensEntity])],
  controllers: [RecordsController],
  providers: [RecordsService, UserService],
  exports: [RecordsService]
})
export class RecordsModule {}
