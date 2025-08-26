import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class GoogleAuthUtils {
  constructor(private configService: ConfigService) {}

  async verifyGoogleToken(accessToken: string): Promise<any> {
    try {
      // Using a more Node.js compatible approach
      const https = require('https');
      const url = `https://www.googleapis.com/oauth2/v1/userinfo?access_token=${accessToken}`;
      
      return new Promise((resolve, reject) => {
        https.get(url, (res: any) => {
          let data = '';
          
          res.on('data', (chunk: any) => {
            data += chunk;
          });
          
          res.on('end', () => {
            if (res.statusCode !== 200) {
              reject(new Error('Invalid Google token'));
              return;
            }
            
            try {
              const userInfo = JSON.parse(data);
              resolve({
                googleId: userInfo.id,
                email: userInfo.email,
                name: userInfo.name,
                picture: userInfo.picture,
                accessToken,
              });
            } catch (parseError) {
              reject(new Error('Failed to parse Google response'));
            }
          });
        }).on('error', (error: any) => {
          reject(new Error(`Google token verification failed: ${error.message}`));
        });
      });
    } catch (error) {
      throw new HttpException(
        `Google token verification failed: ${error.message}`,
        HttpStatus.UNAUTHORIZED,
      );
    }
  }
}
