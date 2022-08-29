#!/bin/bash

source ~/.profile

sudo apt -y install moreutils

DATE=$(date +%Y-%m-%d-%H-%M)
DATADIR=~/.near/data

sudo systemctl stop neard.service

wait

echo "NEAR node was stopped" | ts

echo "Restore started" | ts

cd $DATADIR
ssh -p 23 u315394@u315394.your-storagebox.de "dd if=near_${DATE}_snapshot.tar.zstd bs=1048576" | pv | tar --zstd -x -C .

echo "Restore completed" | ts

sudo systemctl start neard.service

echo "NEAR node was started" | ts
