#!/bin/bash

moniker=$1

#######

cd ~

source ~/.profile

sudo apt install -y bc ufw build-essential make git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python3 protobuf-compiler libssl-dev pkg-config llvm clang
sudo apt purge -y cargo* rust* nodejs npm

sudo ufw enable
sudo ufw allow 24567
sudo ufw allow 3030
sudo ufw limit 22

echo "USER_BASE_BIN=$(python3 -m site --user-base)/bin" >> .profile
echo 'export PATH="$USER_BASE_BIN:$PATH"' >> .profile
echo "export PATH=$PATH:~/.npm-global/bin" >> .profile
echo "export NEAR_ENV=shardnet" >> .profile
echo "export NEAR_CLI_SHARDNET_RPC_SERVER_URL=http://127.0.0.1:3030" >> .profile
echo "export NEAR_GAS=30000000000000" >> .profile
echo "export NEAR_NAME=$moniker" >> .profile
echo 'export NEAR_WALLET=$NEAR_NAME.shardnet.near' >> .profile
echo 'export NEAR_POOL=$NEAR_NAME.factory.shardnet.near' >> .profile
source ~/.profile

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

source $HOME/.cargo/env

git clone https://github.com/near/nearcore
cd nearcore
git fetch --tags --force
git checkout shardnet
make shardnet-release

rm -rf ~/.near/
./target/release/neard --home ~/.near init --chain-id shardnet --download-genesis --download-config

echo "[Unit]
Description=NEARd Daemon Service

[Service]
Environment="RUST_LOG=network=info,chain=info,actix_web=info"
Environment="NEAR_ENV=shardnet"
Type=simple
User=$USER
WorkingDirectory=/home/$USER/.near
ExecStart=/home/$USER/nearcore/target/release/neard run
Restart=on-failure
RestartSec=30
KillSignal=SIGINT
TimeoutStopSec=45
KillMode=mixed

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/neard.service
sudo systemctl daemon-reload
sudo systemctl enable neard

FILE=~/$NEAR_POOL.tar.gz
if [ -f $FILE ]; then
        cd ~/.near
        tar xvf ~/$NEAR_POOL.tar.gz
else
        cd ~/.near
        near generate-key $NEAR_POOL
        cp ~/.near-credentials/shardnet/$NEAR_POOL.json ~/.near/validator_key.json
        sed -i 's/private_key/secret_key/g' ~/.near/validator_key.json
        tar caf ~/$NEAR_POOL.tar.gz *key*.json
fi

cd ~
wget -q -O near-stakewars-monitoring-installer.sh https://raw.githubusercontent.com/davaymne/near-stakewars-monitoring/main/near-stakewars-monitoring-installer.sh && chmod +x near-stakewars-monitoring-installer.sh && sudo /bin/bash near-stakewars-monitoring-installer.sh
sudo ufw allow 3000

sudo apt -y purge libnode-dev libnode72
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo chmod 644 /usr/share/keyrings/nodesource.gpg
sudo apt -y update
sudo apt install -y nodejs

echo "prefix=~/.npm-global" >> ~/.npmrc
npm -g install near-cli

sudo systemctl start neard
