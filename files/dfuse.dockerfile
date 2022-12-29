# syntax=docker/dockerfile:1
FROM ubuntu:18.04

RUN apt-get update && apt-get -y install curl libtinfo5 wget git 

#install dfuseeos build dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - 
RUN apt-get -y install nodejs gcc
RUN npm i -g yarn
RUN wget https://go.dev/dl/go1.16.15.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.16.15.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"
RUN go install github.com/GeertJohan/go.rice/rice@latest

#build and install dfuseeos
RUN git clone https://github.com/pinax-network/dfuse-eosio.git
RUN cp `go env GOPATH`/bin/rice /usr/bin/
WORKDIR /dfuse-eosio
RUN git checkout mandel_updates
RUN /dfuse-eosio/scripts/build.sh
RUN cp `go env GOPATH`/bin/dfuseeos /usr/bin/

ARG NETWORK

#if building for WAX / WAX testnet, build instrumented WAX nodeos with the deep mind plugin
WORKDIR /
RUN if [ "$NETWORK" = "wax-testnet" ] || [ "$NETWORK" = "wax" ] ; then git clone -b wax-leap-3.2 --single-branch https://github.com/worldwide-asset-exchange/wax-blockchain; fi;
WORKDIR /wax-blockchain
RUN if [ "$NETWORK" = "wax-testnet" ] || [ "$NETWORK" = "wax" ] ; then git submodule update --init --recursive; fi;
RUN if [ "$NETWORK" = "wax-testnet" ] || [ "$NETWORK" = "wax" ] ; then /wax-blockchain/scripts/install_deps.sh -y; fi;
#TODO autodetect threads using nproc
RUN if [ "$NETWORK" = "wax-testnet" ] || [ "$NETWORK" = "wax" ] ; then /wax-blockchain/scripts/pinned_build.sh deps build 8; fi;

#install wax or leap binaries
RUN if [ "$NETWORK" = "wax-testnet" ] || [ "$NETWORK" = "wax" ] ; then cp /wax-blockchain/build/programs/nodeos/nodeos /usr/bin;  else curl -L https://github.com/AntelopeIO/leap/releases/download/v3.1.2/leap-3.1.2-ubuntu18.04-x86_64.deb --output eosio.deb && apt-get -y install ./eosio.deb;fi;

#configure mindreader and firehose for the chosen chain
RUN mkdir /dfuse 
RUN mkdir /dfuse/mindreader 
WORKDIR /dfuse
COPY ../config/$NETWORK/mindreader-config.ini /dfuse/mindreader/config.ini
COPY ../config/$NETWORK/genesis.json /dfuse/mindreader/
COPY ../config/common/dfuse.yaml /dfuse/dfuse.yaml
ARG API
RUN if [[-z "$API"]] ; then echo "Not using blockmeta upstream api" ; else echo "   blockmeta-eos-api-upstream-addr: $API"  >> /dfuse/dfuse.yaml; fi
ARG SNAPSHOT
RUN if [[-z "$SNAPSHOT"]] ; then echo "Not using a snapshot" ; else echo "   mindreader-restore-snapshot-name: $SNAPSHOT" >> /dfuse/dfuse.yaml;  fi

CMD ["dfuseeos", "--skip-checks", "start"]
# CMD ["dfuseeos", "start"]