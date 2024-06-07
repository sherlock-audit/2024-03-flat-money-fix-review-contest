# Deployment Scripts

There are two main scripts used for deployments. One is the `deploy.protocol.s.sol` which is used to deploy the system contracts. The other is the `deploy.module.s.sol` which is used to deploy the modules. The former uses the latter to deploy the modules but in a manner such that an EOA can completely deploy the protocol along with module authorizations and hand over control to the owner afterwards.

The deployment scripts can pick the correct chain to be deployed on based on the `--rpc-url` script argument. The `deploy-module.s.sol` script can pick out relevant encoders based on the module name provided when calling the `deployModules` functions.

To deploy a module, add its config in the config file and then use the bash script provided in the `script/shell` directory. If using the `forge` or command directly instead of using the bash script, don't call the `deploy` function directly as it doesn't support transaction broadcasting so you might end up with a transaction which does nothing of note.

## Deploy a Module
To run a deployment script to deploy a module, you can execute the following command:

```bash
   script/shell/deploy-modules.sh <CHAIN_ID> <MODE> <GAS_PRICE?> <MODULE_NAME>...
```

- The `CHAIN_ID` is the chain id of the chain you want to deploy on.
- The `MODE` variable executes the script in either `dry` mode where the transactions aren't actually broadcasted and can be used for simulation purposes or `broadcast` mode where the transactions are actually broadcasted. Just enter `dry` or `broadcast` without quotes.
- The `GAS_PRICE` is an optional field depending on the `MODE`. You should not mention any value if you are running in `dry` mode. If you are running in `broadcast` mode, you should mention the gas price you want to use for the transactions without the `gwei` suffix. For example, if you want to use a gas price of 100 gwei, you would enter `100`.
- The `MODULE_NAME` is the name of the module you want to deploy. You can enter multiple module names separated by a space. No need for quotes around the names.

Once deployed, the module address and related information will be written in the `chain_id.toml` file in the deployments directory. This folder is re-written every time a new protocol deployment is done for a chain which was previously deployed on. The `deploy-module.s.sol` will append the new module information into the chain id specific deployments file.

It's important to note that the modules are automatically authorized provided the module contracts have the `MODULE_KEY()` function which returns the module key. If there is no such function, the module will not be authorized and the script will warn you in its logs.

## Deploy the Protocol
To run a deployment script to deploy the protocol, you can execute the following command:

```bash
    script/shell/deploy-protocol.sh <CHAIN_ID> <MODE> <GAS_PRICE?>
```

- The `CHAIN_ID` is the chain id of the chain you want to deploy on.
- The `MODE` variable executes the script in either `dry` mode where the transactions aren't actually broadcasted and can be used for simulation purposes or `broadcast` mode where the transactions are actually broadcasted. Just enter `dry` or `broadcast` without quotes.
- The `GAS_PRICE` is an optional field depending on the `MODE`. You should not mention any value if you are running in `dry` mode. If you are running in `broadcast` mode, you should mention the gas price you want to use for the transactions without the `gwei` suffix. For example, if you want to use a gas price of 100 gwei, you would enter `100`.

Once deployed, the protocol address and related information will be written in the `chain_id.toml` file in the deployments directory. This file is re-written every time a protocol deployment takes place. However, the old deployment addresses will also be stored in the same directory in a separate file named as `chain_id-timestamp.toml` where the timestamp is the time at which the latest/next deployment took place. This is done to ensure that the old deployment addresses are not lost in case of a new deployment. However, if you want to use old deployment addresses using the scripts provided, you will have to make changes to the scripts or do some manual file copying and renaming.
