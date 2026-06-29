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
COPY services/streaming/src ./services/streaming/src/
COPY services/streaming/__tests__ ./services/streaming/__tests__/
COPY services/streaming/prisma ./services/streaming/prisma/


# ---------- DEV ----------
FROM base AS dev
ENV NODE_ENV=development

USER root
RUN corepack enable && pnpm install
RUN chown -R node:node /usr/src/app

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["pnpm", "--filter", "streaming", "start"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 50051 || exit 1


# ---------- PROD ----------
FROM base AS prod
ENV NODE_ENV=production

USER root
RUN corepack enable \
 && pnpm install --frozen-lockfile \
 && pnpm run --filter streaming build \
 && pnpm prune --prod \
 && chown -R node:node /usr/src/app

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["node", "services/streaming/dist/app.js"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 50051 || exit 1
