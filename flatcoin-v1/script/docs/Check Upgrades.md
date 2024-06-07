## Check Upgrades Script

The check upgrades script is named as `check-upgrades.s.sol` and can be used to check if the current deployed implementation matches the module source code. It uses the `forge verify-bytecode` command to check if the deployed implementation's bytecode matches the source code's bytecode. The script can parse all the deployed modules and if the module is upgradeable then it will check whether an upgrade is required or not and validate the storage layout. The script can be run as follows:

```bash
    script/shell/check-upgrades.sh <CHAIN_ID>
```

- The `CHAIN_ID` is the chain id of the chain you want to check the upgrades on.

Note that this script can take quite a while to complete as it needs to check the bytecode of all the deployed modules using the etherscan API which can be slow. The script will skip check for immutable contracts even if the contracts' source code has changed. This is because we don't store the flattened versions of the immutable contracts in the `flattened-contracts` directory. In case a need arises for you to check if an immutable contract's source code has changed and you want this script to work for immutable contracts as well, you can manually flatten the contract and store it in the `flattened-contracts` directory and modify the foundry script to take immutable contracts into account.