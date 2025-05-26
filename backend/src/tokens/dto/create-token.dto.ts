import { IsNumber, IsString } from 'class-validator';

export class CreateTokenDto {
  @IsString()
  access_token: string;

  @IsNumber()
  user_id: number;
}
