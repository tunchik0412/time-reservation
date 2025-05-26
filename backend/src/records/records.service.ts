import { Injectable } from '@nestjs/common';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Record } from './entities/record.entity';
import { Repository } from 'typeorm';
import { User } from '../user/entities/user.entity';

@Injectable()
export class RecordsService {
  constructor(
    @InjectRepository(Record) private recordRepository: Repository<Record>,
    @InjectRepository(User) private userRepository: Repository<User>,
  ) {}

  async create(createRecordDto: CreateRecordDto & { creator: number }) {
    const record = new Record();
    record.creator = createRecordDto.creator;
    record.from = createRecordDto.from;
    record.to = createRecordDto.to;
    record.title = createRecordDto.title;
    record.description = createRecordDto?.description || '';
    this.recordRepository.create(createRecordDto);
    const user = await this.userRepository.findOne({
      where: {
        id: createRecordDto.creator,
      },
    });
    record.participants = [user];
    return this.recordRepository.save(record);
  }

  findAll() {
    return `This action returns all records`;
  }

  findOne(id: number) {
    return `This action returns a #${id} record`;
  }

  async findUserRecords(userId: number) {
    return this.recordRepository.find({
      where: {
        creator: userId,
      },
      relations: {
        participants: true,
      },
    });
  }

  update(id: number, updateRecordDto: UpdateRecordDto) {
    return this.recordRepository.update(id, updateRecordDto);
  }

  async remove(id: number, userId: number) {
    const record = await this.recordRepository.findOne({
      where: {
        id: id,
      },
      relations: {
        participants: true,
      },
    });
    if (record.creator !== userId) {
      throw new Error('You are not allowed to delete this record');
    }
    return this.recordRepository.delete(id);
  }

  async findExistingRecordByDateRange(from: Date, to: Date) {
    return this.recordRepository.find({
      where: {
        from: from,
        to: to,
      },
    });
  }

  async insertNewRecordToExistingRecord() {}
}
