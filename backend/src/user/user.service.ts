import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CreateUserDto } from "./dto/create-user.dto";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { User } from "./entities/user.entity";
import { UpdateUserDto } from "./dto/update-user.dto";

@Injectable()
export class UserService {

  constructor(@InjectRepository(User) private readonly userRepository: Repository<User>) {
  }

  async createUser(userDTO: CreateUserDto) {
    const hashedPassword = await this.hashPassword(userDTO.password)
    const user: User = new User();
    user.name = userDTO.name;
    user.email = userDTO.email;
    user.password = hashedPassword;
    return this.userRepository.save(user);
  }

  hashPassword(password: string) {
    const salt = bcrypt.genSaltSync(10);
    return bcrypt.hash(password, salt);
  }

  validatePassword(password: string, hash: string) {
    return bcrypt.compareSync(password, hash);
  }

  getUsers() {
    return this.userRepository.find()
  }

  findUserById(id: User['id']) {
    return this.userRepository.findOneBy({ id })
  }

  updateUser(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    const user: User = new User();
    user.name = updateUserDto.name;
    user.email = updateUserDto.email;
    user.password = updateUserDto.password;
    user.id = id;
    return this.userRepository.save(user);
  }

  removeUser(id: number): Promise<{affected?: number}> {
    return this.userRepository.delete(id)
  }
}
