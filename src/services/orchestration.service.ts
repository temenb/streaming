import * as OrchestrationClient from "../grpc/clients/orchestration.client";
import * as grpc from "@grpc/grpc-js";

export const health = async () =>
  await OrchestrationClient.health();

export const status = async () =>
  await OrchestrationClient.status();

export const livez = async () =>
  await OrchestrationClient.livez();

export const readyz = async () =>
  await OrchestrationClient.readyz();

export const getMyProfile = async (metadata: grpc.Metadata) =>
  await OrchestrationClient.getMyProfile(metadata);
