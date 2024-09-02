import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UserModule } from "../user/user.module";
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from '@nestjs/passport';
import { jwtConstants } from "./constants";
import { AuthGuard } from "./auth.guard";
import { TokensModule } from "../tokens/tokens.module";
import { TokensService } from "../tokens/tokens.service";


@Module({
  imports: [
    TokensModule,
    UserModule,
    JwtModule.register({
      global: true,
      ...jwtConstants
    }),
    PassportModule
  ],
  controllers: [AuthController],
  providers: [AuthService, AuthGuard]
})
export class AuthModule {}
