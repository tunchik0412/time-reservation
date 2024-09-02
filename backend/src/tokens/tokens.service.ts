import { Injectable, UnauthorizedException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { TokensEntity } from "./entities/tokens.entity";
import { Repository } from "typeorm";
import { CreateTokenDto } from "./dto/create-token.dto";
import { DeleteTokenDto } from "./dto/delete-token.dto";
import { jwtConstants } from "../auth/constants";
import { JwtService } from "@nestjs/jwt";

@Injectable()
export class TokensService {
  constructor(
    @InjectRepository(TokensEntity) private readonly tokensRepository: Repository<TokensEntity>,
    private jwtService: JwtService,
  ) {
  }

  async createToken(tokenDTO: CreateTokenDto) {
    const newToken: TokensEntity = new TokensEntity();
    newToken.access_token = tokenDTO.access_token;
    newToken.user_id = tokenDTO.user_id;
    return this.tokensRepository.save(newToken);
  }

  async removeToken(tokenDTO: DeleteTokenDto) {
    return this.tokensRepository.delete({
      user_id: tokenDTO.user_id,
      access_token: tokenDTO.access_token
    });
  }

  async checkIsValidToken(token: string) {
    try {
      const tokenEntity = await this.tokensRepository.findOneBy({ access_token: token });
      if (!tokenEntity) {
        throw UnauthorizedException;
      }
      const res = await this.jwtService.verifyAsync(
        token,
        {
          secret: jwtConstants.secret
        }
      );
      return res
    } catch (e) {
      throw UnauthorizedException;
    }
  }

  async removeTokensByUserId(user_id: number) {
    return this.tokensRepository.delete({ user_id });
  }
}
