import { Body, Controller, HttpCode, HttpStatus, Post } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { User } from "../common/types/user";

@Controller()
export class AuthController {
  constructor(private authService: AuthService) {}

  @HttpCode(HttpStatus.CREATED)
  @Post('sign_up')
  async signUp(@Body() user: Partial<User>){
    return this.authService.signUp(user)
  }

  @HttpCode(HttpStatus.OK)
  @Post('sign_in')
  async signIn(@Body() user: Partial<User>){
    return this.authService.signIn(user)
  }
}
