#!/bin/bash

# Load the values from the .env file.
source .env

# Access the first 3 command-line arguments.
CHAIN_ID=$1
MODE=$2
GAS_PRICE=$3"gwei"

if [[ -z $CHAIN_ID ]] || [[ -z $MODE ]]; then
    echo "CHAIN_ID or MODE is not provided"
    exit 1
fi

# Assign variables to the values from the .env file based on the chain id.
CHAIN_NAME_VAR="CHAIN_NAME_"$CHAIN_ID
ACCOUNT_KEY_VAR="ACCOUNT_KEY_"$CHAIN_ID
SENDER_ADDRESS_VAR="SENDER_ADDRESS_"$CHAIN_ID
CHAIN_NAME=${!CHAIN_NAME_VAR}
ACCOUNT_KEY=${!ACCOUNT_KEY_VAR}
SENDER_ADDRESS=${!SENDER_ADDRESS_VAR}

echo "Running protocol deployment script for chain $CHAIN_NAME (id: $CHAIN_ID)"

# Invoke the pnpm command to run the upgrade script depending on the mode.
if [[ $MODE == "dry" ]]; then
    echo "Executing script in dry-run mode"

    pnpm run:oz script/deployment/deploy.protocol.s.sol \
    --rpc-url $CHAIN_NAME \
    --account $ACCOUNT_KEY \
    --sender $SENDER_ADDRESS
elif [[ $MODE == "broadcast" ]]; then
    echo "Executing script in broadcast mode"

    if [[ -z $GAS_PRICE ]]; then
        echo "GAS_PRICE is not set"
        exit 1
    fi

    pnpm run:oz script/deployment/deploy.protocol.s.sol \
    --rpc-url $CHAIN_NAME \
    --account $ACCOUNT_KEY \
    --sender $SENDER_ADDRESS \
    --priority-gas-price $GAS_PRICE \
    --broadcast --verify
fi
