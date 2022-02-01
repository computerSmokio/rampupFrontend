FROM node:17-alpine3.14

WORKDIR /usr/src/app

COPY ./package.json /usr/src/app/

RUN npm install

COPY ./*.* /usr/src/app/
COPY ./public /usr/src/app/public

ARG FRONTEND_PORT
ARG BACKEND_PORT

EXPOSE ${FRONTEND_PORT}
EXPOSE ${BACKEND_PORT}

CMD ["node", "server.js"]