import { IsDate, IsNotEmpty, IsNumber, IsString } from "class-validator";

export class CreateRecordDto {
  @IsNumber()
  @IsNotEmpty()
  creator: number;

  @IsNotEmpty()
  @IsString()
  title: string;

  @IsNotEmpty()
  @IsDate()
  from: Date;

  @IsNotEmpty()
  @IsDate()
  to: Date;

  @IsString()
  description: string;
}
