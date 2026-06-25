import logger from "@shared/logger";
import {updateBattle} from "../services/battle.service";
import * as battleGrpc from "../grpc/generated/battle";


// export async function battleUpdated(topic: string, partition: number, message: any): Promise<void> {
//   try {
//     logger.log('battleUpdated');
//     logger.log(message);
//     await updateBattle(message as battleGrpc.BattleObject);
//   } catch (error) {
//     logger.error(`[Kafka] Failed to process message`, {
//       rawValue: message.userId,
//       error,
//     });
//   }
// }
