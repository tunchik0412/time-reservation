import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UserModule } from '../user/user.module';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { jwtConstants } from './constants';
import { AuthGuard } from './auth.guard';
import { TokensModule } from '../tokens/tokens.module';
import { TokensService } from '../tokens/tokens.service';
import { GoogleStrategy } from './strategies/google.strategy';
import { GoogleOAuthGuard } from './guards/google-oauth.guard';
import { GoogleAuthUtils } from './utils/google-auth.utils';
import { AppleAuthUtils } from './utils/apple-auth.utils';

@Module({
  imports: [
    ConfigModule,
    TokensModule,
    UserModule,
    JwtModule.register({
      global: true,
      ...jwtConstants,
    }),
    PassportModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, AuthGuard, GoogleStrategy, GoogleOAuthGuard, GoogleAuthUtils, AppleAuthUtils],
})
export class AuthModule {}
