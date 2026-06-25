import * as battleGrpc from "../grpc/generated/battle";
import {Battle, BattleCellValue, BattleStatus} from "@prisma/client";

const battleStatusMap: Record<BattleStatus, battleGrpc.BattleStatus> = {
  [BattleStatus.Active]: battleGrpc.BattleStatus.ACTIVE,
  [BattleStatus.Finished]: battleGrpc.BattleStatus.FINISHED,
};

// Мапа для клеток
const battleCellValueMap: Record<BattleCellValue, battleGrpc.BattleCellValue> = {
  [BattleCellValue.X]: battleGrpc.BattleCellValue.CELL_X,
  [BattleCellValue.O]: battleGrpc.BattleCellValue.CELL_O,
  [BattleCellValue.EMPTY]: battleGrpc.BattleCellValue.CELL_EMPTY,
};

export function battleStatusToGrpc(status: BattleStatus): battleGrpc.BattleStatus {
  const mapped = battleStatusMap[status];
  if (mapped === undefined) throw new Error(`Unknown BattleStatus: ${status}`);
  return mapped;
}

function flip<T extends string | number, U extends string | number>(
  obj: Record<T, U>
): Record<U, T> {
  const flipped: any = {};
  for (const [key, value] of Object.entries(obj)) {
    flipped[value as any] = key;
  }
  return flipped;
}

export function battleStatusToPrisma(status: battleGrpc.BattleStatus): BattleStatus {
  const grpcToBattleStatusMap = flip(battleStatusMap);
  const mapped = grpcToBattleStatusMap[status];
  if (mapped === undefined) throw new Error(`Unknown battleGrpc.BattleStatus: ${status}`);
  return mapped as BattleStatus;
}

export function battleCellValueToGrpc(cell: BattleCellValue): battleGrpc.BattleCellValue {
  const mapped = battleCellValueMap[cell];
  if (mapped === undefined) throw new Error(`Unknown BattleCellValue: ${cell}`);
  return mapped;
}

export function battleCellValueToPrisma(cell: battleGrpc.BattleCellValue): BattleCellValue {
  const grpcToBattleCellValueMap = flip(battleCellValueMap);
  const mapped = grpcToBattleCellValueMap[cell];
  if (mapped === undefined) throw new Error(`Unknown battleGrpc.BattleCellValue: ${cell}`);
  return mapped as BattleCellValue;
}

export function battleToGrpc(battle: Battle): battleGrpc.BattleObject {
  const grpcCells: battleGrpc.BattleCellValue[] = (battle.cells).map(battleCellValueToGrpc);
  const status: battleGrpc.BattleStatus = battleStatusToGrpc(battle.status);
  const players: string[] = battle.players;

  return {
    id: battle.id,
    cells: grpcCells,
    players: players,
    status: status,
    winner: battle.winner ?? "",
    createdAt: result.createdAt,
    updatedAt: result.updatedAt,
  };
}

export function battleToPrisma(battle: battleGrpc.BattleObject) {
  const cells: BattleCellValue[] = (battle.cells).map(battleCellValueToPrisma);
  const status: BattleStatus = battleStatusToPrisma(battle.status);
  const players: string[] = battle.players;

  return {
    id: battle.id,
    cells: cells,
    players: players,
    status: status,
    winner: battle.winner ?? "",
    createdAt: result.createdAt,
    updatedAt: result.updatedAt,
  };
}

