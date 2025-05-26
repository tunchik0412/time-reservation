import { HttpStatus, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CreateUserDto } from './dto/create-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { UpdateUserDto } from './dto/update-user.dto';
import { DeleteUserDto } from './dto/delete-user.dto';
import { TokensEntity } from '../tokens/entities/tokens.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User) private readonly userRepository: Repository<User>,
    @InjectRepository(TokensEntity)
    private readonly tokensRepository: Repository<TokensEntity>,
  ) {}

  async createUser(userDTO: CreateUserDto) {
    const isExist = await this.checkIsUserExist(userDTO.email);
    if (isExist) {
      throw {
        code: HttpStatus.CONFLICT,
        message: 'User with this email already exists',
      };
    }
    const hashedPassword = await this.hashPassword(userDTO.password);
    const user: User = new User();
    user.name = userDTO.name;
    user.email = userDTO.email;
    user.password = hashedPassword;
    return this.userRepository.save(user);
  }

  async checkIsUserExist(email: string) {
    return await this.userRepository.findOneBy({ email });
  }

  hashPassword(password: string) {
    const salt = bcrypt.genSaltSync(10);
    return bcrypt.hash(password, salt);
  }

  validatePassword(password: string, hash: string) {
    console.log(password, hash);
    return bcrypt.compareSync(password, hash);
  }

  getUsers() {
    return this.userRepository.find();
  }

  findUserById(id: User['id']) {
    return this.userRepository.findOneBy({ id });
  }

  findUserByEmail(email: User['email']) {
    return this.userRepository.findOneBy({ email });
  }

  updateUser(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    const user: User = new User();
    user.name = updateUserDto.name;
    user.email = updateUserDto.email;
    return this.userRepository.save(user);
  }

  async removeUser(
    deleteUserDto: DeleteUserDto,
  ): Promise<{ affected?: number }> {
    const user = await this.userRepository.findOneBy({ id: deleteUserDto.id });
    if (!user) {
      return Promise.resolve({ affected: 0 });
    }
    if (!deleteUserDto.password) {
      return Promise.resolve({ affected: 0, message: 'Password is required' });
    }
    if (!this.validatePassword(deleteUserDto.password, user.password)) {
      return Promise.resolve({ affected: 0, message: 'Password is incorrect' });
    }
    await this.tokensRepository.delete({ user_id: user.id });
    return this.userRepository.delete(user.id);
  }
}
