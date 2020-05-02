FROM node:lts-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package*.json ./

# RUN npm ci --only=production
RUN npm install

COPY . .

CMD [ "npm", "start" ]
