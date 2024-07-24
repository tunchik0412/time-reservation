import { Injectable, UnauthorizedException, HttpStatus } from '@nestjs/common';
import { UserService } from '../user/user.service';
import { SignInDto } from "./dto/sign-in-dto";
import { SignUpDto } from "./dto/sign-up-dto";

@Injectable()
export class AuthService {
  constructor(private userService: UserService) {}

  async signUp(user: SignUpDto) {
    return this.userService.createUser(user);
  }

  async signIn(user: SignInDto) {
    const users =  await this.userService.getUsers();
    const foundUser = users.find((u) => u.email === user.email);
    if (!foundUser) {
      throw new UnauthorizedException({
        status: HttpStatus.UNAUTHORIZED,
        error: 'Invalid email or password',
      });
    }
    const isPasswordValid = this.userService.validatePassword(user.password, foundUser.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException({
        status: HttpStatus.UNAUTHORIZED,
        error: 'Invalid email or password',
      });
    }
    return foundUser;
  }
}
