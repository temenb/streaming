# ---------- BASE ----------
FROM node:22 AS base

WORKDIR /usr/src/app

COPY shared ./shared
COPY pnpm-lock.yaml ./
COPY turbo.json ./
COPY package.json ./
COPY pnpm-workspace.yaml ./
COPY tsconfig.base.json ./
COPY proto ./proto

COPY services/streaming/package*.json ./services/streaming/
COPY services/streaming/jest.config.js ./services/streaming/
COPY services/streaming/tsconfig.json ./services/streaming/
COPY services/streaming/src ./services/streaming/src/
COPY services/streaming/__tests__ ./services/streaming/__tests__/
COPY services/streaming/prisma ./services/streaming/prisma/

# ---------- BUILD ----------
FROM base AS build

ENV NODE_ENV=development

RUN apt-get update && apt-get install -y protobuf-compiler

RUN corepack enable
RUN pnpm install --frozen-lockfile
RUN mkdir ./services/streaming/src/grpc/generated -p
RUN pnpm run --filter streaming proto:generate
RUN pnpm --filter @shared/logger build
RUN pnpm --filter @shared/grpc-client-manager build
RUN pnpm --filter @shared/kafka-manager build
RUN pnpm --filter @shared/pg-boss-manager buld
RUN pnpm --filter streaming build
RUN pnpm prune --prod

# ---------- DEV ----------
FROM build AS dev

ENV NODE_ENV=development

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["pnpm", "--filter", "streaming", "start"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/livez || exit 1

# ---------- PROD ----------
FROM node:22 AS prod

WORKDIR /usr/src/app

ENV NODE_ENV=production

#RUN pnpm deploy --filter streaming /out

##COPY --from=build /usr/src/app /usr/src/app

COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/services/streaming/node_modules ./services/streaming/node_modules
COPY --from=build /usr/src/app/services/streaming/dist ./services/streaming/dist
COPY --from=build /usr/src/app/shared ./shared


USER node

EXPOSE 50051
EXPOSE 8080

CMD ["node", "./services/streaming/dist/app.js"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/livez || exit 1
