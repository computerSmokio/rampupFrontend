FROM node:16-alpine

WORKDIR /app

COPY . /app

RUN npm install

ARG FRONTEND_PORT=3030

EXPOSE ${FRONTEND_PORT}

CMD ["node", "server.js"]