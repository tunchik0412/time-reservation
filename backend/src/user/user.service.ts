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
    try {
      const isExist = await this.checkIsUserExist(userDTO.email);
      if (isExist) {
        throw {
          code: HttpStatus.CONFLICT,
          message: 'User with this email already exists',
        };
      }
      const hashedPassword = await this.hashPassword(userDTO.password);
      if (!hashedPassword) {
        throw {
          code: HttpStatus.INTERNAL_SERVER_ERROR,
          message: 'Error hashing password',
        };
      }
      const user: User = new User();
      user.name = userDTO.name;
      user.email = userDTO.email;
      user.password = hashedPassword;
      return this.userRepository.save(user);
    } catch (e) {
      throw {
        code: e.code || HttpStatus.INTERNAL_SERVER_ERROR,
        message: e.message || 'Internal server error',
      };
    }
  }

  async checkIsUserExist(email: string) {
    return await this.userRepository.findOneBy({ email });
  }

  hashPassword(password: string) {
    const salt = bcrypt.genSaltSync(10);
    return bcrypt.hash(password, salt);
  }

  validatePassword(password: string, hash: string) {
    return bcrypt.compareSync(password, hash);
  }

  getUsers() {
    return this.userRepository.find();
  }

  findUserById(id: User['id']) {
    return this.userRepository.findOneBy({ id });
  }

  findUserByEmail(email: User['email']) {
    return this.userRepository
      .createQueryBuilder('user')
      .addSelect('user.password') // ✅ explicitly select hidden field
      .where('user.email = :email', { email })
      .getOne();
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

  async createGoogleUser(userData: {
    name: string;
    email: string;
    password?: string;
    googleId: string;
    picture?: string;
  }) {
    try {
      const user: User = new User();
      user.name = userData.name;
      user.email = userData.email;
      user.password = userData.password || null;
      user.googleId = userData.googleId;
      user.picture = userData.picture;
      
      return this.userRepository.save(user);
    } catch (e) {
      throw {
        code: e.code || HttpStatus.INTERNAL_SERVER_ERROR,
        message: e.message || 'Error creating Google user',
      };
    }
  }

  async updateUserGoogleId(userId: number, googleId: string) {
    try {
      return this.userRepository.update(userId, { googleId });
    } catch (e) {
      throw {
        code: e.code || HttpStatus.INTERNAL_SERVER_ERROR,
        message: e.message || 'Error updating user Google ID',
      };
    }
  }

  async findUserByGoogleId(googleId: string) {
    return this.userRepository.findOneBy({ googleId });
  }

  async createAppleUser(userData: {
    name: string;
    email?: string;
    appleId: string;
  }) {
    try {
      const user: User = new User();
      user.name = userData.name;
      user.email = userData.email || `${userData.appleId}@apple.signin`;
      user.password = null; // Apple users don't have passwords
      user.appleId = userData.appleId;
      
      return this.userRepository.save(user);
    } catch (e) {
      throw {
        code: e.code || HttpStatus.INTERNAL_SERVER_ERROR,
        message: e.message || 'Error creating Apple user',
      };
    }
  }

  async updateUserAppleId(userId: number, appleId: string) {
    try {
      return this.userRepository.update(userId, { appleId });
    } catch (e) {
      throw {
        code: e.code || HttpStatus.INTERNAL_SERVER_ERROR,
        message: e.message || 'Error updating user Apple ID',
      };
    }
  }

  async findUserByAppleId(appleId: string) {
    return this.userRepository.findOneBy({ appleId });
  }
}
