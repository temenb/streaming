# ---------- BASE ----------
FROM node:22 AS base

WORKDIR /usr/src/app

COPY shared ./shared
COPY pnpm-lock.yaml ./
COPY turbo.json ./
COPY package.json ./
COPY pnpm-workspace.yaml ./
COPY tsconfig.json ./
COPY services/auth/package*.json ./services/auth/
COPY services/auth/jest.config.js ./services/auth/
COPY services/auth/tsconfig.json ./services/auth/
COPY services/auth/src ./services/auth/src/
COPY services/auth/__tests__ ./services/auth/__tests__/
COPY services/auth/prisma ./services/auth/prisma/


# ---------- DEV ----------
FROM base AS dev
ENV NODE_ENV=development

USER root
RUN corepack enable && pnpm install
RUN chown -R node:node /usr/src/app

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["pnpm", "--filter", "auth", "start"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 50051 || exit 1


# ---------- PROD ----------
FROM base AS prod
ENV NODE_ENV=production

USER root
RUN corepack enable && pnpm install --frozen-lockfile --prod && pnpm run --filter auth build
RUN chown -R node:node /usr/src/app

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["node", "services/auth/dist/app.js"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 50051 || exit 1
