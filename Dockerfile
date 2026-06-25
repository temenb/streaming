FROM node:22
ENV NODE_ENV=development

WORKDIR /usr/src/app

COPY shared/ ./shared/
COPY turbo.json  ./
COPY package.json ./
COPY pnpm-workspace.yaml ./
COPY tsconfig.json ./
COPY services/streaming/package*.json ./services/streaming/
COPY services/streaming/jest.config.js ./services/streaming/
COPY services/streaming/tsconfig.json ./services/streaming/
COPY services/streaming/src ./services/streaming/src/
COPY services/streaming/prisma ./services/streaming/prisma/
COPY services/streaming/__tests__ ./services/streaming/__tests__/

USER root

RUN corepack enable && pnpm install
RUN chown -R node:node /usr/src/app

USER node

EXPOSE 50051
EXPOSE 8080

CMD ["pnpm", "--filter", "streaming", "start"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:9090/livez || exit 1
