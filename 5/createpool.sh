#!/bin/bash

AMOUNT=100

#####

source ~/.profile

a="$(cat ~/.near/validator_key.json)"
pat='\"public_key\":\"(.*)\",'
[[ "$a" =~ $pat ]]; echo "${BASH_REMATCH[1]}"

near call factory.shardnet.near create_staking_pool '{"staking_pool_id": "$NEAR_POOL", "owner_id": "$NEAR_WALLET", "stake_public_key": "${BASH_REMATCH[1]}", "reward_fee_fraction": {"numerator": 5, "denominator": 100}, "code_hash":"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ"}' --accountId $NEAR_WALLET --amount 30 --gas $NEAR_GAS

sleep 60

near call $NEAR_POOL deposit_and_stake --account_id $NEAR_WALLET --amount $AMOUNT --gas $NEAR_GAS
