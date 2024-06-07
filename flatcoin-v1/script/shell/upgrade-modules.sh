#!/bin/bash

# Load the values from the .env file.
source .env

# Access the first 3 command-line arguments.
CHAIN_ID=$1
MODE=$2

if [[ $MODE == "dry" ]]; then
    GAS_PRICE=""
    shift 2 # Remove the first 2 arguments.
    SAFE_SEND=false
else
    GAS_PRICE=$3"gwei"
    shift 3 # Remove the first 3 arguments.
    SAFE_SEND=true # Since the mode is broadcast, this means we need to send the transactions to Gnosis Safe.
fi

# Get the next command-line arguments and put them in an array.
# These arguments are the module names to be upgraded.
declare -a moduleNames
for arg in "$@"
do
    moduleNames+=("$arg")
done

# Format the module names as an array of comma separated strings.
MODULE_NAMES_FORMATTED=$(printf '\"%s\", ' "${moduleNames[@]}")
MODULE_NAMES_FORMATTED="[${MODULE_NAMES_FORMATTED%, }]"

# Assign variables to the values from the .env file based on the chain id.
CHAIN_NAME_VAR="CHAIN_NAME_"$CHAIN_ID
ACCOUNT_KEY_VAR="ACCOUNT_KEY_"$CHAIN_ID
SENDER_ADDRESS_VAR="SENDER_ADDRESS_"$CHAIN_ID
CHAIN_NAME=${!CHAIN_NAME_VAR}
ACCOUNT_KEY=${!ACCOUNT_KEY_VAR}
SENDER_ADDRESS=${!SENDER_ADDRESS_VAR}

# Signature of the function to be in the upgrades script.
# This is the signature for "upgradeViaSafe(string[],bool)".
FUNC_SIG="0x21ef0172"

# Get abi-encoded parameters for the function.
# Don't proceed if there is an error after calling cast.
ENCODED_PARAMS=$(cast calldata "upgradeViaSafe(string[],bool)" "$MODULE_NAMES_FORMATTED" "$SAFE_SEND" || exit 1)

# Replace the first 4 bytes of the encoded parameters with the function signature.
ENCODED_PARAMS="${FUNC_SIG}${ENCODED_PARAMS:10}"

# Invoke the pnpm command to run the upgrade script depending on the mode.
if [[ $MODE == "dry" ]]; then
    echo "Executing script in dry-run mode"

    pnpm run:oz script/tasks/upgrade-module.s.sol \
    --sig $ENCODED_PARAMS\
    --rpc-url $CHAIN_NAME \
    --account $ACCOUNT_KEY \
    --sender $SENDER_ADDRESS
elif [[ $MODE == "broadcast" ]]; then
    echo "Executing script in broadcast mode"

    if [[ -z $GAS_PRICE ]]; then
        echo "GAS_PRICE is not set"
        exit 1
    fi

    pnpm run:oz script/tasks/upgrade-module.s.sol \
    --sig $ENCODED_PARAMS \
    --rpc-url $CHAIN_NAME \
    --account $ACCOUNT_KEY \
    --sender $SENDER_ADDRESS \
    --priority-gas-price $GAS_PRICE \
    --broadcast --verify
fi
