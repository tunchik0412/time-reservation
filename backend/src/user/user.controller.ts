import { Body, Controller, Delete, Get, Req, Request } from "@nestjs/common";
import { UserService } from "./user.service";
import { UserJWTPayload } from "../common/types/tokens";
import { User } from "./user.decorator";

@Controller('user')
export class UserController {
    constructor(private userService: UserService) {
    }

    @Get()
    getUser() {
        return this.userService.getUsers()
    }

    @Delete()
    deleteUser(@User() user: UserJWTPayload, @Body() body: { password: string }) {
        return this.userService.removeUser({
            id: user.userId,
            password: body.password
        })
    }
}
