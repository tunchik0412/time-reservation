import { Injectable, UnauthorizedException, HttpStatus } from '@nestjs/common';
import { UserService } from '../user/user.service';

@Injectable()
export class AuthService {
  constructor(private userService: UserService) {}

  async signUp(user: any) {
    return this.userService.createUser(user);
  }

  async signIn(user: any) {
    const users = this.userService.getUsers();
    const foundUser = users.find((u) => u.email === user.email && u.password === user.password);
    if (foundUser) {
      return HttpStatus.OK;
    }
    return new UnauthorizedException();
  }

  async validateUser(email: string, password: string): Promise<any> {

  }
}
