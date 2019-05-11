FROM node:latest

WORKDIR /app

COPY . /app
COPY package.json /app

RUN yarn

EXPOSE 8080

CMD ["yarn", "start"]
