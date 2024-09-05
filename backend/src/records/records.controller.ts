import { Controller, Get, Post, Body, Patch, Param, Delete, Req } from "@nestjs/common";
import { RecordsService } from './records.service';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';
import { User } from "../user/user.decorator";
import { UserJWTPayload } from "../common/types/tokens";

@Controller('records')
export class RecordsController {
  constructor(private readonly recordsService: RecordsService) {}

  @Post()
  create(@Body() createRecordDto: CreateRecordDto, @User() user: UserJWTPayload) {
    return this.recordsService.create({
      ...createRecordDto,
      creator: user.userId
    });
  }

  @Get()
  findAll() {
    return this.recordsService.findAll();
  }

  @Get('my')
  findUserRecords(@User() user: UserJWTPayload) {
    return this.recordsService.findUserRecords(user.userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.recordsService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateRecordDto: UpdateRecordDto) {
    return this.recordsService.update(+id, updateRecordDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @User() user: UserJWTPayload) {
    return this.recordsService.remove(+id, user.userId);
  }
}
