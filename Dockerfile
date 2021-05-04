## [8] use multi-stage builds
## =====================================================> The build image stage
FROM node:lts-alpine AS build
COPY package*.json ./
RUN npm ci --only=production
##  ~~~~~~~~~~~~ [2] install only production dependencies in a reproducible way.

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
