import {
  IsNotEmpty,
  IsNumber,
  IsString,
} from "class-validator";

export class DeleteTokenDto {
  @IsNotEmpty()
  @IsNumber()
  user_id: number;

  @IsNotEmpty()
  @IsString()
  access_token: string;
}
