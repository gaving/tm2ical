FROM node:alpine

WORKDIR /app

COPY . /app
COPY package.json /app

RUN npm install

EXPOSE 8080

CMD ["npm", "start"]
