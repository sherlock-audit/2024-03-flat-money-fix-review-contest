// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {FlatcoinStructs} from "../../src/libraries/FlatcoinStructs.sol";
import {FlatcoinModuleKeys} from "../../src/libraries/FlatcoinModuleKeys.sol";
import {FlatcoinVault} from "../../src/FlatcoinVault.sol";

import {FileManager} from "../utils/FileManager.sol";
import "../tasks/deploy-module.s.sol";

import "forge-std/Script.sol";
import "forge-std/StdToml.sol";

contract DeployProtocolScript is DeployScript {
    using stdToml for string;

    FlatcoinStructs.AuthorizedModule[] private authorizedModules;
    string[] private moduleNames;

    function run() public {
        console2.log("Deployer address: ", msg.sender);

        initProtocolDeploymentFile();

        string memory configFile = getConfigTomlFile();
        string[] memory tomlKeys = vm.parseTomlKeys(configFile, "$");
        address protocolOwner = (getConfigTomlFile()).readAddress(".owner");

        // Parse all keys starting with the 2nd key as the first one is the owner address.
        // This also assumes that all the keys starting from the 2nd key are module names.
        for (uint8 i = 1; i < tomlKeys.length; ++i) {
            moduleNames.push(tomlKeys[i]);
        }

        // As the protocol deployment assumes that the deployer is an EOA, no need to send any transactions to Gnosis Safe.
        // Even if you set the second argument as true it will not send any transactions to Gnosis Safe.
        deployModules(moduleNames, false);

        string memory deploymentsFile = getDeploymentsTomlFile();
        address vaultProxy = deploymentsFile.readAddress(".FlatcoinVault.proxy");

        vm.startBroadcast();

        // Authorize all the modules.
        FlatcoinVault(vaultProxy).addAuthorizedModules(authorizedModules);

        // Transfer the vault control from deployer to the protocol owner.
        FlatcoinVault(vaultProxy).transferOwnership(protocolOwner);

        vm.stopBroadcast();
    }

    function _tryAuthorizeModule(string memory moduleName_, address module_) internal override {
        (bool success, bytes memory data) = (module_).call(abi.encodeWithSignature("MODULE_KEY()"));

        if (success) {
            bytes32 moduleKey = abi.decode(data, (bytes32));

            authorizedModules.push(FlatcoinStructs.AuthorizedModule({moduleAddress: module_, moduleKey: moduleKey}));
        } else {
            console2.log(
                StdStyle.yellow(
                    string.concat(
                        "Module ",
                        moduleName_,
                        " does not have a MODULE_KEY() function. Please authorize this module manually if required."
                    )
                )
            );

            console2.log("Skipping authorization of the new implementation for %s", moduleName_);
        }
    }
}
