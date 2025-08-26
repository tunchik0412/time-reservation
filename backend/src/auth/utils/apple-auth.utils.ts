import { Injectable } from '@nestjs/common';
import { AppleAuthDto } from '../dto/apple-auth.dto';

@Injectable()
export class AppleAuthUtils {
  /**
   * Verify Apple identity token
   * In production, you should verify the JWT token with Apple's public keys
   */
  async verifyAppleToken(dto: AppleAuthDto): Promise<{
    isValid: boolean;
    appleId?: string;
    email?: string;
    name?: string;
  }> {
    try {
      // For development, we'll accept any token
      // In production, implement proper JWT verification with Apple's public keys
      console.log('Verifying Apple token for:', dto.appleId);

      // Simulate token verification
      const isValid = dto.identityToken && dto.appleId;
      
      if (isValid) {
        const name = dto.givenName && dto.familyName 
          ? `${dto.givenName} ${dto.familyName}`
          : dto.givenName || dto.familyName || 'Apple User';

        return {
          isValid: true,
          appleId: dto.appleId,
          email: dto.email,
          name: name,
        };
      }

      return { isValid: false };
    } catch (error) {
      console.error('Apple token verification error:', error);
      return { isValid: false };
    }
  }

  /**
   * Extract user info from Apple authentication data
   */
  extractUserInfo(dto: AppleAuthDto): {
    appleId: string;
    email?: string;
    name: string;
  } {
    const name = dto.givenName && dto.familyName 
      ? `${dto.givenName} ${dto.familyName}`
      : dto.givenName || dto.familyName || 'Apple User';

    return {
      appleId: dto.appleId,
      email: dto.email,
      name: name,
    };
  }
}
