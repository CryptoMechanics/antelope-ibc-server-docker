# syntax=docker/dockerfile:1
FROM node:lts

RUN apt-get install -y git
RUN git clone https://github.com/eostitan/ibc-proof-server.git
WORKDIR /ibc-proof-server
RUN git checkout v1.0.0

RUN npm install

ARG NETWORK
ARG CHAIN_ID
COPY ../config/common/ibcEnv ./.env
RUN echo "\nCHAIN_ID=$CHAIN_ID" >> ./.env 

CMD ["node", "index.js"]
