#!/bin/bash

source ~/.profile

sudo apt -y install moreutils

DATE=$(date +%Y-%m-%d-%H-%M)
DATADIR=~/.near/data

sudo systemctl stop neard.service

wait

echo "NEAR node was stopped" | ts

echo "Backup started" | ts

cd $DATADIR

ssh -p 23 u315394@u315394.your-storagebox.de 'rm "$(ls -t *snapshot* | tail -1)"'
tar -I "zstd -c -T${CORES} -13" -cSf - * | pv | ssh -p 23 u315394@u315394.your-storagebox.de "dd of=near_${DATE}_snapshot.tar.zstd bs=1048576"

echo "Backup completed" | ts

sudo systemctl start neard.service

echo "NEAR node was started" | ts
