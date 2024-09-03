import { Injectable } from '@nestjs/common';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';
import { InjectRepository } from "@nestjs/typeorm";
import { Record } from "./entities/record.entity";
import { Repository } from "typeorm";
import { User } from "../user/entities/user.entity";

@Injectable()
export class RecordsService {
  constructor(
    @InjectRepository(Record) private recordRepository: Repository<Record>,
    @InjectRepository(User) private userRepository: Repository<User>,
  ) {
  }

  async create(createRecordDto: CreateRecordDto) {
    const record = new Record();
    record.creator = createRecordDto.creator;
    record.from = createRecordDto.from;
    record.to = createRecordDto.to;
    record.title = createRecordDto.title;
    record.description = createRecordDto.description;
    record.users = [];
    const user = await this.userRepository.findOneBy({
      id: createRecordDto.creator
    });
    record.users.push(user);
    return this.recordRepository.save(createRecordDto);
  }

  findAll() {
    return `This action returns all records`;
  }

  findOne(id: number) {
    return `This action returns a #${id} record`;
  }

  update(id: number, updateRecordDto: UpdateRecordDto) {
    return this.recordRepository.update(id, updateRecordDto);
  }

  remove(id: number) {
    return this.recordRepository.delete(id);
  }

  async findExistingRecordByDateRange(from: Date, to: Date) {
    return this.recordRepository.find({
      where: {
        from: from,
        to: to
      }
    });
  }

  async insertNewRecordToExistingRecord() {

  }
}
