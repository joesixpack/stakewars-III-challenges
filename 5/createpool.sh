#!/bin/bash

AMOUNT=100

#####

source ~/.profile

near call factory.shardnet.near create_staking_pool '{"staking_pool_id": "$NEAR_POOL", "owner_id": "$NEAR_WALLET", "stake_public_key": "fromvalidatorkey", "reward_fee_fraction": {"numerator": 5, "denominator": 100}, "code_hash":"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ"}' --accountId $NEAR_WALLET --amount 30 --gas $NEAR_GAS --node_url $NEAR_NODE

sleep 60

near call $NEAR_POOL deposit_and_stake --account_id $NEAR_WALLET --amount $AMOUNT --gas $NEAR_GAS --node_url $NEAR_NODE
