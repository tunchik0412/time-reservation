import { Injectable, UnauthorizedException, HttpStatus } from '@nestjs/common';
import { UserService } from '../user/user.service';
import { TokensService } from '../tokens/tokens.service';
import { SignInDto } from './dto/sign-in-dto';
import { SignUpDto } from './dto/sign-up-dto';
import { GoogleAuthDto } from './dto/google-auth-dto';
import { AppleAuthDto } from './dto/apple-auth.dto';
import { JwtService } from '@nestjs/jwt';
import { GoogleAuthUtils } from './utils/google-auth.utils';
import { AppleAuthUtils } from './utils/apple-auth.utils';

@Injectable()
export class AuthService {
  constructor(
    private userService: UserService,
    private jwtService: JwtService,
    private tokensService: TokensService,
    private googleAuthUtils: GoogleAuthUtils,
    private appleAuthUtils: AppleAuthUtils,
  ) {}

  async signUp(user: SignUpDto) {
    return this.userService.createUser(user);
  }

  async signIn(signInDto: SignInDto) {
    const user = await this.userService.findUserByEmail(signInDto.email);
    if (!user) {
      throw new UnauthorizedException({
        status: HttpStatus.UNAUTHORIZED,
        error: 'No user found with this email',
      });
    }
    const isPasswordValid = this.userService.validatePassword(
      signInDto.password,
      user.password,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException({
        status: HttpStatus.UNAUTHORIZED,
        error: 'Invalid email or password',
      });
    }
    const payload = { userId: user.id };
    const token = await this.jwtService.signAsync(payload);
    await this.tokensService.createToken({
      access_token: token,
      user_id: user.id,
    });
    return {
      access_token: token,
    };
  }

  async signOut(access_token: string) {
    const { userId } = await this.jwtService.decode(access_token);
    try {
      await this.tokensService.removeToken({
        access_token,
        user_id: userId,
      });
    } catch {
      throw new UnauthorizedException({
        status: HttpStatus.UNAUTHORIZED,
        error: 'Invalid token',
      });
    }
  }

  async googleLogin(user: any) {
    try {
      let googleUser = user;

      // If user object contains accessToken, verify it with Google
      if (user.accessToken && !user.googleId) {
        googleUser = await this.googleAuthUtils.verifyGoogleToken(user.accessToken);
      }

      // Check if user exists by email
      let existingUser = await this.userService.findUserByEmail(googleUser.email);
      
      // If user doesn't exist, create a new one
      if (!existingUser) {
        const newUser = {
          name: googleUser.name,
          email: googleUser.email,
          password: null, // Google users don't have password
          googleId: googleUser.googleId,
          picture: googleUser.picture,
        };
        existingUser = await this.userService.createGoogleUser(newUser);
      } else {
        // Update existing user with Google ID if not set
        if (!existingUser.googleId) {
          await this.userService.updateUserGoogleId(existingUser.id, googleUser.googleId);
        }
      }

      // Generate JWT token
      const payload = { userId: existingUser.id };
      const token = await this.jwtService.signAsync(payload);
      
      // Store token
      await this.tokensService.createToken({
        access_token: token,
        user_id: existingUser.id,
      });

      return {
        access_token: token,
        user: {
          id: existingUser.id,
          email: existingUser.email,
          name: existingUser.name,
          picture: existingUser.picture || googleUser.picture,
        },
      };
    } catch (e) {
      throw new UnauthorizedException({
        status: e.status || HttpStatus.UNAUTHORIZED,
        error: e.error || 'Google authentication failed',
      });
    }
  }

  async appleLogin(appleAuthDto: AppleAuthDto) {
    try {
      // Verify Apple token
      const verificationResult = await this.appleAuthUtils.verifyAppleToken(appleAuthDto);
      
      if (!verificationResult.isValid) {
        throw new UnauthorizedException('Invalid Apple token');
      }

      // Extract user info
      const userInfo = this.appleAuthUtils.extractUserInfo(appleAuthDto);

      // Check if user exists by Apple ID
      let existingUser = await this.userService.findUserByAppleId(userInfo.appleId);
      
      // If user doesn't exist, check by email
      if (!existingUser && userInfo.email) {
        existingUser = await this.userService.findUserByEmail(userInfo.email);
      }

      // If user still doesn't exist, create a new one
      if (!existingUser) {
        const newUser = {
          name: userInfo.name,
          email: userInfo.email,
          appleId: userInfo.appleId,
        };
        existingUser = await this.userService.createAppleUser(newUser);
      } else {
        // Update existing user with Apple ID if not set
        if (!existingUser.appleId) {
          await this.userService.updateUserAppleId(existingUser.id, userInfo.appleId);
        }
      }

      // Generate JWT token
      const payload = { userId: existingUser.id };
      const token = await this.jwtService.signAsync(payload);
      
      // Store token
      await this.tokensService.createToken({
        access_token: token,
        user_id: existingUser.id,
      });

      return {
        access_token: token,
        user: {
          id: existingUser.id,
          email: existingUser.email,
          name: existingUser.name,
        },
      };
    } catch (e) {
      throw new UnauthorizedException({
        status: e.status || HttpStatus.UNAUTHORIZED,
        error: e.error || 'Apple authentication failed',
      });
    }
  }
}
