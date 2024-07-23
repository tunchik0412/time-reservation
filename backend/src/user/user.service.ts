import { Injectable } from '@nestjs/common';
import { User } from "../common/types/user";
import { v4 as uuidv4 } from 'uuid';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UserService {
  users = []

  createUser(userDTO: Partial<User>) {
    const hashedPassword = this.hashPassword(userDTO.password)
    const UserDTO: User = {
      name: userDTO.name,
      email: userDTO.email,
      password: hashedPassword,
      id: uuidv4()
    }
    this.users.push(UserDTO)
    return UserDTO
  }

  hashPassword(password: string) {
    const salt = bcrypt.genSaltSync(10);
    return bcrypt.hash(password, salt);
  }

  validatePassword(password: string, hash: string) {
    return bcrypt.compareSync(password, hash);
  }

  getUsers() {
    return this.users
  }
}
