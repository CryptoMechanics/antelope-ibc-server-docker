# NOTE : This repository is no longer maintained. New repository is https://github.com/CryptoMechanics/antelope-ibc-server-docker

---

# Antelope IBC Proof Docker
This includes everything needed to generate proofs for antelope chains and relay them to a client using websockets.
It utilises docker compose to launch and manage mindreader, firehose, lightproof-db, ibc-server.

---
## Scripts:
#### To install docker + docker compose plugin
`./install-docker.sh`

#### Start containers
`./start.sh`

#### Stop containers
`./stop.sh`

#### View running containers' logs
`./logs.sh`

#### dfuse logs
`tail -f ./dfuse-data/dfuse.log.json`

#### Delete all chain data (stop containers first) 
`sudo rm -rf dfuse-data/ lightproof-data/`

---
## Steps to run a proof server:

1 - Create a ".env" file (check .env.example) with the chain details, and desired host websocket port like so: 

        NETWORK=ux-testnet
        API=https://testnet.uxnetwork.io
        CHAIN_ID=5002d6813ffe275d9471a7e3a301eab91c36e8017f9664b8431fbf0e812a0b04
        WS_PORT=7788
        

2 - To start from genesis: 
    `./start.sh`
       
    To start from a snapshot:
       - Start indexing from before the previous power of 2's block number (see below)
       - Download and decompress a snapshot (V4/V6) and place it in the "snapshots" folder
       - Add the snapshot file name in the .env file like in .env.example  (SNAPSHOT=$NAME_OF_SNAPSHOT_FILE) 
       - If starting with an empty database, In ".env" set the START_BLOCK to a number above the snapshot's block number (1000 blocks above, to avoid firehose issues)
       - After starting the containers, you can remove/comment out the SNAPSHOT and START_BLOCK lines added to ".env" above, so they are not in effect on next restart.


---
### Note on choosing snapshots:
    To be able to generate proofs of actions occuring at a certain block, 
    you need to start from a snapshot prior to the last power of two block height. 

    For example, if current block height is at 190M blocks, the previous power of two 
    would be block #134,217,728. You will need a snapshot before this block number, 
    to be able to prove actions from block #134,217,728 and onwards.

list of relevant power of 2s for convenience:
```
  2097152
  4194304
  8388608
 16777216
 33554432
 67108864
134217728 
268435456
```
