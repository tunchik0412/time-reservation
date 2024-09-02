import { Module } from '@nestjs/common';
import { TokensService } from './tokens.service';
import { TypeOrmModule } from "@nestjs/typeorm";
import { TokensEntity } from "./entities/tokens.entity";

@Module({
  imports: [TypeOrmModule.forFeature([TokensEntity])],
  providers: [TokensService],
  exports: [TokensService]
})
export class TokensModule {}
