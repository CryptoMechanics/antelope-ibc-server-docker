# syntax=docker/dockerfile:1
FROM node:lts

RUN apt-get install -y git

RUN git clone https://github.com/eostitan/lightproof-db.git
WORKDIR /lightproof-db
RUN git checkout v1.0.0
RUN npm install

ARG NETWORK
ARG START_BLOCK
COPY ../config/common/lightproofEnv ./.env

#force start block for (re)indexing
RUN if [[-z "$START_BLOCK"]] ; then echo "NA" ; else echo "\nFORCE_START_BLOCK=$START_BLOCK">> .env;  fi

#expose ibc server websocket port
EXPOSE 7788

CMD ["node", "index.js"]
