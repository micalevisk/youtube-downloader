## [8] use multi-stage builds
## =====================================================> The build image stage
FROM node:lts-alpine AS build
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
##  ~~~~~~~~~~~~ [2] install only production dependencies in a reproducible way.

## Set this with shell variables at build-time.
## If they aren't set, then not-set will be default.
ARG CREATED_DATE=not-set
ARG SOURCE_COMMIT=not-set

## Labels from OCI https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Simple YouTube Downloader"
LABEL org.opencontainers.image.authors=https://t.me/micalevisk
LABEL org.opencontainers.image.source=https://github.com/micalevisk/youtube-downloader
LABEL org.opencontainers.image.created=$CREATED_DATE
LABEL org.opencontainers.image.revision=$SOURCE_COMMIT
LABEL org.opencontainers.image.licenses=MIT

## ================================================> The production image stage
FROM node:14.16.1-alpine3.11
##        ~~~~~~~~~~~~~~~~~ [1] use deterministic docker base image tags.

RUN apk add dumb-init
##          ^~~ Why? read this: https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html

ENV NODE_ENV production
##           ~~~~~~~~~ [3] optimize nodejs tooling for production.

USER node
##   ~~~~ [4] don't run nodejs apps as root.

ENV PORT 8080
EXPOSE 8080

WORKDIR /home/app
COPY --chown=node:node --from=build node_modules node_modules
COPY --chown=node:node . /home/app
##     ~~~~~~~~~~~~~~~ [4]

CMD ["dumb-init", "node", "."]
##    ~~~~~~~ [5] properly handle events to safely terminate a Node.js apps.
