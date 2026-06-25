import jwt from 'jsonwebtoken';
import config from '../config/config';
import logger from "@shared/logger";

export function extractUserIdFromJwt(token: string) {
  const payload = jwt.verify(token, config.jwtAccessSecret);
  const userId = String(payload.sub);
  // logger.log("✅ Authorized:", userId);
  return userId;
}


export default extractUserIdFromJwt;