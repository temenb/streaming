# ---------- BASE ----------
FROM node:22 AS base

WORKDIR /usr/src/app

COPY shared ./shared
COPY pnpm-lock.yaml ./
COPY turbo.json ./
COPY package.json ./
COPY pnpm-workspace.yaml ./
COPY tsconfig.json ./

COPY services/streaming/package*.json ./services/streaming/
COPY services/streaming/jest.config.js ./services/streaming/
COPY services/streaming/tsconfig.json ./services/streaming/
COPY services/streaming/prisma ./services/streaming/prisma/
COPY services/streaming/src ./services/streaming/src/
COPY services/streaming/__tests__ ./services/streaming/__tests__/

# ---------- BUILD ----------
FROM base AS build

ENV NODE_ENV=development

RUN corepack enable \
 && pnpm install --frozen-lockfile \
 && pnpm run proto:generate \
 && pnpm run --filter streaming build \
 && pnpm prune --prod


# ---------- DEV ----------
FROM build AS dev

ENV NODE_ENV=development

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["pnpm", "--filter", "streaming", "start"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:9090/livez || exit 1

# ---------- PROD ----------
FROM node:22 AS prod

WORKDIR /usr/src/app

ENV NODE_ENV=production

#COPY --from=build /usr/src/app /usr/src/app
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["node", "dist/services/streaming/src/app.js"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:9090/livez || exit 1
