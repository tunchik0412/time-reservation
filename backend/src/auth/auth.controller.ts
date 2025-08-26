import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import { Response, Request } from 'express';
import { AuthService } from './auth.service';
import { SignInDto } from './dto/sign-in-dto';
import { SignUpDto } from './dto/sign-up-dto';
import { GoogleAuthDto } from './dto/google-auth-dto';
import { AppleAuthDto } from './dto/apple-auth.dto';
import { Public } from '../common/enums';
import { GoogleOAuthGuard } from './guards/google-oauth.guard';

@Controller()
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @HttpCode(HttpStatus.CREATED)
  @Post('sign_up')
  async signUp(@Body() user: SignUpDto, @Res() res: Response) {
    try {
      await this.authService.signUp(user);
      res.status(HttpStatus.CREATED).send('User created');
    } catch (e) {
      res.status(e.code).send(e.message);
    }
  }

  @Public()
  @HttpCode(HttpStatus.OK)
  @Post('sign_in')
  async signIn(@Body() user: SignInDto) {
    return this.authService.signIn(user);
  }

  @HttpCode(HttpStatus.OK)
  @Post('sign_out')
  async signOut(@Headers('authorization') auth: string) {
    const access_token = auth.split(' ')[1];
    return this.authService.signOut(access_token);
  }

  // Google OAuth endpoints
  @Public()
  @Get('google')
  @UseGuards(GoogleOAuthGuard)
  async googleAuth(@Req() req: any) {
    // Guard redirects to Google
  }

  @Public()
  @Get('google/callback')
  @UseGuards(GoogleOAuthGuard)
  async googleAuthRedirect(@Req() req: any, @Res() res: Response) {
    const result = await this.authService.googleLogin(req.user);
    
    // You can customize this redirect URL based on your frontend
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3001';
    const redirectUrl = `${frontendUrl}/auth/google/success?token=${result.access_token}`;
    
    res.redirect(redirectUrl);
  }

  // Alternative endpoint for mobile/direct Google token validation
  @Public()
  @HttpCode(HttpStatus.OK)
  @Post('google/token')
  async googleTokenAuth(@Body() googleAuthDto: GoogleAuthDto) {
    return this.authService.googleLogin(googleAuthDto);
  }

  // Apple Sign-In endpoint for mobile
  @Public()
  @HttpCode(HttpStatus.OK)
  @Post('apple/token')
  async appleTokenAuth(@Body() appleAuthDto: AppleAuthDto) {
    return this.authService.appleLogin(appleAuthDto);
  }
}
