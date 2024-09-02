import { Body, Controller, Headers, HttpCode, HttpStatus, Post, Res } from "@nestjs/common";
import { Response } from 'express';
import { AuthService } from "./auth.service";
import { SignInDto } from "./dto/sign-in-dto";
import { SignUpDto } from "./dto/sign-up-dto";
import { Public } from "../common/enums";

@Controller()
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @HttpCode(HttpStatus.CREATED)
  @Post('sign_up')
  async signUp(@Body() user: SignUpDto, @Res() res: Response){
    try {
      await this.authService.signUp(user)
      res.status(HttpStatus.CREATED).send('User created')
    } catch (e) {
      res.status(e.code).send(e.message)
    }
  }

  @Public()
  @HttpCode(HttpStatus.OK)
  @Post('sign_in')
  async signIn(@Body() user: SignInDto){
    return this.authService.signIn(user)
  }

  @HttpCode(HttpStatus.OK)
  @Post('sign_out')
  async signOut(@Headers('authorization') auth: string){
    const access_token = auth.split(' ')[1]
    return this.authService.signOut(access_token)
  }
}
