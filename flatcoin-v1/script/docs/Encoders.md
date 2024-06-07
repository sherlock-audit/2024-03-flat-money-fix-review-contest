# Encoders

The encoder files present in the `../deployment/encoders` directory are used to create encoded calldata to be passed to the deployment script. Each module requires an encoder. These are necessary because deployment using OZ Foundry Upgrades plugin requires the calldata for a function call (in most cases call to the `initialize` function) to be encoded.

The encoders read the config file for a particular chain and module and use the information to encode the calldata. The encoder contracts should be able to read the config TOML files and it's the responsibility of the dev writing the encoder to make sure that the values read from the config are appropriately type coerced. The deployment script automatically picks the correct encoder based on the chain and module provided certain conventions are followed. These are:

 - The encoder file should be named as `<module_name>.encoder.sol`
 - The encoder contract should be names as `<module_name>Encoder`
