import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class AppleAuthDto {
  @IsString()
  @IsNotEmpty()
  appleId: string;

  @IsString()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  givenName?: string;

  @IsString()
  @IsOptional()
  familyName?: string;

  @IsString()
  @IsNotEmpty()
  identityToken: string;

  @IsString()
  @IsOptional()
  authorizationCode?: string;
}
