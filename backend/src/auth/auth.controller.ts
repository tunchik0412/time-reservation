import { Body, Controller, HttpCode, HttpStatus, Post } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { SignInDto } from "./dto/sign-in-dto";
import { SignUpDto } from "./dto/sign-up-dto";

@Controller()
export class AuthController {
  constructor(private authService: AuthService) {}

  @HttpCode(HttpStatus.CREATED)
  @Post('sign_up')
  async signUp(@Body() user: SignUpDto){
    return this.authService.signUp(user)
  }

  @HttpCode(HttpStatus.OK)
  @Post('sign_in')
  async signIn(@Body() user: SignInDto){
    return this.authService.signIn(user)
  }
}
