FROM node:17-alpine3.14

RUN mkdir /app
WORKDIR /app

COPY . /app

RUN npm install

ARG FRONTEND_PORT
ARG BACKEND_PORT

EXPOSE ${FRONTEND_PORT}
EXPOSE ${BACKEND_PORT}

CMD ["node", "server.js"]