#!/bin/bash

## Dashboard Section
NEAR_NODE=$NEAR_CLI_SHARDNET_RPC_SERVER_URL

printf "\nNode Stats"
version=$(curl -s $NEAR_NODE/status | jq .version.build)
echo "Version: $version"
expectedblocks=$(curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' $NEAR_NODE | \
	jq --arg key1 $NEAR_POOL -c '.result.current_validators[] | select(.account_id | contains ($key1))' | jq .num_expected_blocks)
producedblocks=$(curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' $NEAR_NODE | \
	jq --arg key1 $NEAR_POOL -c '.result.current_validators[] | select(.account_id | contains ($key1))' | jq .num_produced_blocks)
expectedchunks=$(curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' $NEAR_NODE | \
	jq --arg key1 $NEAR_POOL -c '.result.current_validators[] | select(.account_id | contains ($key1))' | jq .num_expected_chunks)
producedchunks=$(curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' $NEAR_NODE | \
	jq --arg key1 $NEAR_POOL -c '.result.current_validators[] | select(.account_id | contains ($key1))' | jq .num_produced_chunks)
echo "Blocks Produced vs Expected: $producedblocks vs $expectedblocks"
echo "Chunks Produced vs Expected: $producedchunks vs $expectedchunks"
kickout=$(curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' $NEAR_NODE | \
	jq --arg key1 $NEAR_POOL -c '.result.prev_epoch_kickout[] | select(.account_id | contains ($key1))' | jq .reason)
echo "Kickout Reason: $kickout"
echo "Delegators & Stake: "
near view $NEAR_POOL get_accounts '{"from_index": 0, "limit": 1}' --accountId $NEAR_WALLET
near view $NEAR_POOL get_accounts '{"from_index": 2, "limit": 1}' --accountId $NEAR_WALLET
near validators current | grep "idtcn\|polkachu\|stakewars-\|ou812\|agrestus\|sierradelta" # Known Hetzner Validators

## Alerts Section
BOT_TOKEN="1839791942:AAHBXFSyddBDZB7JgWvZhlJjbohUH9JkkE0"
CHANNEL_ID="-1001539082426"

syncstatus=$(curl -s localhost:3030/status | jq .sync_info.syncing)
protocolversion=$(curl -s localhost:3030/status | jq .protocol_version )
latestprotocolversion=$(curl -s localhost:3030/status | jq .latest_protocol_version )
numofpeers=$(http post http://localhost:3030 jsonrpc=2.0 method=network_info params:='[]' id=dontcare)
function div { local _d=${3:-2}; local _n=0000000000; _n=${_n:0:$_d}; local _r=$(($1$_n/$2)); _r=${_r:0:-$_d}.${_r: -$_d}; echo $_r;}

if [ $producedblocks == "0" ] && [ $expectedblocks == "0" ]
then
	blocksratio=1.00
else
	blocksratio=div $producedblocks $expectedblocks
fi

chunksratio=$(echo "$producedchunks/$expectedchunks" | bc -l )

MSG1="Block production under 95%!!!!"
MSG2="Chunk production under 95%!!!"
MSG3="Validator has been kicked out!!!"
MSG4="Node is no longer synced!!!"
MSG5="Node auto-upgrade failed!!!"

if (( $(echo "$blocksratio < 0.95" |bc -l) ));
then
curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage \
	-d chat_id=${CHANNEL_ID} \
	-d parse_mode="Markdown" \
	-d text="ou812.factory.shardnet.near %0A MSG1" >> /home/j/near-alert.log 2>&1
fi

if (( $(echo "$chunksratio < 0.95" |bc -l) ));
then
curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage \
        -d chat_id=${CHANNEL_ID} \
        -d parse_mode="Markdown" \
        -d text="ou812.factory.shardnet.near %0A $MSG2" >> /home/j/near-alert.log 2>&1
fi

if [ "$kickout" != "" ] ; then
curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage \
        -d chat_id=${CHANNEL_ID} \
        -d parse_mode="Markdown" \
        -d text="ou812.factory.shardnet.near %0A $MSG3" >> /home/j/near-alert.log 2>&1
fi

if [ $syncstatus != "false" ] ; then
curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage \
        -d chat_id=${CHANNEL_ID} \
        -d parse_mode="Markdown" \
        -d text="ou812.factory.shardnet.near %0A $MSG4" >> /home/j/near-alert.log 2>&1
fi

if [ $protocolversion -lt $latestprotocolversion ] ; then
curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage \
        -d chat_id=${CHANNEL_ID} \
        -d parse_mode="Markdown" \
        -d text="ou812.factory.shardnet.near %0A $MSG5" >> /home/j/near-alert.log 2>&1
fi
