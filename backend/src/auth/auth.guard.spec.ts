import { AuthGuard } from './auth.guard';
import { AuthController } from "./auth.controller";

describe('AuthGuard', () => {
  let controller: AuthGuard;
  it('should be defined', () => {
    expect(AuthGuard).toBeDefined();
  });
});
