## TOML Config Files

We use TOML files to make the config files a lot easier on the eyes. The scripts rely on the config files present in the `script/deployment/configs/ directory`. The config files need to be in TOML format and should contain the necessary `initialize` or `constructor` function arguments for the contracts to be deployed. Event if there isn't any `constructor` or `initialize` data, an object must be made in the file which includes `isUpgradeable` key for the module/contract to be deployed. The config files need to be named as `chain_id.toml` where the `chain_id` is the number which denotes a unique chain.

### Some Notes

- Note that the config files have to be updated if the `initialize` or `constructor` function is modified with a new parameter. The values of the keys in the TOML file which often represent the storage variable values should be updated every time there is a change made by the owner by using `onlyOwner` authorized setter functions.
- Note that the types are inferred in the deployment contracts. Feel free to change the order of the variables.
- Avoid changing the names of the config keys as the encoders use these names. If you need to change the name of a key then make sure to make the same change wherever this key is referred in the scripts.
- One caveat is that you cannot use scientific notation, i.e, Floating point numbers with decimal digits are not allowed. This means you can't use the value 0.5e16, you can use the only its string representation.
- All the deployable contracts whether they are upgradeable or not, should be listed in the config file for a chain. Otherwise the protocol deployment script will miss deployment of those modules.
- A contract can be set to be an upgradeable contract by setting the `isUpgradeable` field to true. Otherwise, set it to false. The `isUpgradeable` key needs to be present in the config objects for all contracts.
- Even if there is no constructor/initializer parameters for a contract, it should be listed in a chain config file and `isUpgradeable` set to necessary boolean value.
- If you want to add a new object/key which isn't a module configuration, you should add it after the `owner` root key.
- For more encoding rules specific to Foundry see this doc: https://book.getfoundry.sh/cheatcodes/parse-toml
- To refer TOML specs see: https://toml.io/en/v1.0.0#spec