#!/bin/bash

nodeid=node0
neardir=/home/j/near-testnet/.near
walletid=joesixpack.testnet

cd ~

source ~/.profile

# install nix package manager
sh <(curl -L https://nixos.org/nix/install) --daemon

# enable flakes support in nix
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# install dependencies (consul, neard, hivemind, python)
git clone https://github.com/kuutamolabs/kuutamod
nix develop

# build kuutamod
cargo build --release

mkdir $neardir/$nodeid

echo "[Unit]
Description=Kuutamod Daemon Service

[Service]
Environment="RUST_LOG=stats=info,network=info,chain=info,actix_web=info"
Environment="NEAR_ENV=testnet"
Environment="KUUTAMO_NODE_ID=$nodeid"
Environment="KUUTAMO_ACCOUNT_ID=$walletid"
Environment="KUUTAMO_CONSUL_URL=http://localhost:8500"
Environment="KUUTAMO_EXPORTER_ADDRESS=127.0.0.1:2233"
Environment="KUUTAMO_VALIDATOR_KEY=$neardir/$nodeid/validator_key.json"
Environment="KUUTAMO_VALIDATOR_NODE_KEY=$neardir/$nodeid/node_key.json"
Environment="KUUTAMO_VOTER_NODE_KEY=$neardir/$nodeid/voter_node_key.json"
Environment="KUUTAMO_NEARD_HOME=$neardir"
Environment="KUUTAMO_CONSUL_URL=http://localhost:8500"
Type=simple
User=j
WorkingDirectory=$neardir
ExecStart=/home/j/kuutamod/target/release/kuutamod
Restart=on-failure
RestartSec=30
KillSignal=SIGINT
TimeoutStopSec=45
KillMode=mixed

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kuutamod.service

hivemind

sudo apt-get install awscli -y
aws s3 --no-sign-request cp s3://near-protocol-public/backups/testnet/rpc/latest .
LATEST=$(cat latest)
aws s3 --no-sign-request cp --no-sign-request --recursive s3://near-protocol-public/backups/testnet/rpcs/$LATEST $neardir/data

sudo systemctl daemon-reload
sudo systemctl start kuutamod

curl http://localhost:2233/metrics
