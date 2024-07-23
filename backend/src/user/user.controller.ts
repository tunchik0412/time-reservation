import { Controller, Get, Post } from "@nestjs/common";
import { UserService } from "./user.service";

@Controller('user')
export class UserController {
    constructor(private userService: UserService) {
    }
    @Get()
    getUser() {
        return this.userService.getUsers()
    }

    @Post()
    postUser() {
        return 'User added';
    }
}
