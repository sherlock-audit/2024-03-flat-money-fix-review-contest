# Upgrade Script

The upgrade script is a foundry script to upgrade multiple deployed modules. This script allows a deployer to deploy the new implementation contract after validation of the storage structure of the new implementation being compatible with the storage structure of the old implementation. The script also allows sending an `upgradeAndCall` transaction to the proxy admin of the module to upgrade the module to the new implementation via a Gnosis Safe.

There are a few things to keep in mind when upgrading a module:

- Make sure that flattened version of the previous version of source code or current deployed implementation is present in the `flattened-contracts` directory. The path to the flattened contract should be `flattened-contracts/chain_id/Module.sol` where the `chain_id` is the number which denotes a unique chain.
- Make sure that there's a `deployments` file for the chain you want to upgrade the module on. This file should contain the proxy, implementation and proxy admin addresses of an upgradeable module in the TOML format. The `deployments` file should be named as `chain_id.toml` where the `chain_id` is the number which denotes a unique chain.

There are two functions in the upgrade script. One is `prepareUpgrade` which deploys the new implementation contract without sending a gnosis safe transaction to a safe. This can be used in case the safe api isn't working or you want to manually craft an upgrade transaction. The other is the `upgradeViaSafe` function which does the same thing as `prepareUpgrade` but also sends an `upgradeAndCall` transaction to the proxy admin of the module to upgrade the module to the new implementation via a Gnosis Safe. The latter function takes in multiple module names in an array and sends a batch transaction to the safe to upgrade all the modules in the array. If a provided module is not upgradeable then it will deploy the new contract/implementation and send an authorize module transaction to the Gnosis Safe.

The `upgradeViaSafe` function also takes in a `send_` argument which is a boolean. If this is set to `true`, the script will send the gnosis safe transaction to the safe. If this is set to `false`, the script will only simulate creating a batch transaction for the upgrade and not send it to the gnosis safe.
> **WARNING:** The `upgradeViaSafe` function could send a gnosis safe transaction to the safe if the `send_` argument is set to `true` regardless of the `--broadcast` flag being present or not. Make sure to set the `send_` argument to `false` if you only want to simulate the upgrade transaction. It's recommended to use the shell script for upgrading modules.

To upgrade modules, use the following command:
```bash
    script/shell/upgrade-modules.sh <CHAIN_ID> <MODE> <GAS_PRICE?> <MODULE_NAME>...
```

- The `CHAIN_ID` is the chain id of the chain you want to upgrade the module on.
- The `MODE` variable executes the script in either `dry` mode where the transactions aren't actually broadcasted and can be used for simulation purposes or `broadcast` mode where the transactions are actually broadcasted. Just enter `dry` or `broadcast` without quotes.
- The `GAS_PRICE` is an optional field depending on the `MODE`. You should not mention any value if you are running in `dry` mode. If you are running in `broadcast` mode, you should mention the gas price you want to use for the transactions without the `gwei` suffix. For example, if you want to use a gas price of 100 gwei, you would enter `100`.
- The `MODULE_NAME` is the name of the module you want to upgrade. You can enter multiple module names separated by a space. No need for quotes around the names.

Note that the upgrade script will only send transactions to the Gnosis Safe if the `MODE` is set to `broadcast`. If the `MODE` is set to `dry`, the script will only simulate the upgrade transaction and not send it to the Gnosis Safe.
