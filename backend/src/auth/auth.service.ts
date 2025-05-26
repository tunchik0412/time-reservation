import { Injectable, UnauthorizedException, HttpStatus } from '@nestjs/common';
import { UserService } from '../user/user.service';
import { TokensService } from '../tokens/tokens.service';
import { SignInDto } from './dto/sign-in-dto';
import { SignUpDto } from './dto/sign-up-dto';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    private userService: UserService,
    private jwtService: JwtService,
    private tokensService: TokensService,
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
}
