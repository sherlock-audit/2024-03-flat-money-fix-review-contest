// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";

import {FlatcoinVault} from "../../src/FlatcoinVault.sol";
import {FlatcoinStructs} from "../../src/libraries/FlatcoinStructs.sol";

import {FileManager} from "../utils/FileManager.sol";
import {BatchScript} from "../utils/BatchScript.sol";
import {DeployScript} from "./deploy-module.s.sol";

import "forge-std/StdStyle.sol";
import "forge-std/StdToml.sol";
import "forge-std/console2.sol";

/// @title UpgradeModule
/// @author dHEDGE
/// @notice Script to upgrade a module via Gnosis Safe multisend txs.
/// @dev OZ Docs are available at https://docs.openzeppelin.com/upgrades-plugins/1.x/api-foundry-upgrades#Upgrades
contract UpgradeModule is BatchScript, DeployScript {
    using stdToml for string;

    /// @dev Function to deploy new implementation contracts and upgrade the proxy via Gnosis Safe multisend txs.
    /// @param moduleNames_ The names of the module to be upgraded without ".sol" extension.
    /// @param send_ Boolean flag to determine if a transaction has to be simulated or sent to Gnosis Safe
    /// @dev Note that if `send_` is set as `true` but the transaction is not broadcasted then an invalid transaction will be sent to the Safe.
    function upgradeViaSafe(string[] memory moduleNames_, bool send_) public {
        string memory deploymentsFile = getDeploymentsTomlFile();

        console2.log("Upgrading %s modules in a batch\n", moduleNames_.length);

        for (uint8 i; i < moduleNames_.length; ++i) {
            // If the module is an immutable contract meaning, it has only `contract` as the value in the deployments file,
            // deploy a new implementation contract and create a transaction to authorize this new implementation.
            if (vm.keyExistsToml(deploymentsFile, string.concat(".", moduleNames_[i], ".contract"))) {
                console2.log("Module %s is an immutable contract", moduleNames_[i]);
                console2.log("Deploying a new implementation contract for %s", moduleNames_[i]);

                deployImmutableContract(moduleNames_[i]);
            } else {
                // If the module is an upgradeable contract, validate the new implementation and deploy it.
                // Then create a transaction to upgrade the proxy.
                address admin = deploymentsFile.readAddress(string.concat(".", moduleNames_[i], ".proxyAdmin"));
                ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(
                    deploymentsFile.readAddress(string.concat(".", moduleNames_[i], ".proxy"))
                );

                address newImplementation = prepareUpgrade(moduleNames_[i]);

                addToBatch(admin, abi.encodeCall(ProxyAdmin.upgradeAndCall, (proxy, newImplementation, bytes(""))));
            }
        }

        console2.log("\n");

        executeBatch(getConfigTomlFile().readAddress(".owner"), send_);

        console2.log(StdStyle.green("\nModule upgrade transactions sent to SAFE"));
    }

    /// @notice Deploys the implementation contract and returns the address.
    /// @dev Note that the new module must contain `@custom:oz-upgrades-from <reference>` annotation.
    ///      Where reference is the name of the module to upgrade from.
    /// @dev Use this function to validate and deploy the new implementation contract.
    ///      This function can be used to build a Gnosis Safe transaction using Safe Transaction Builder.
    /// @param moduleName_ The name of the module/contract to upgrade to.
    function prepareUpgrade(string memory moduleName_) public returns (address newImplementation) {
        string memory referenceContractQualifiedPath = getFlattenedContractQualifiedPath(moduleName_);
        string memory upgradeContractQualifiedPath = getModuleQualifiedPath(moduleName_);

        Options memory options; // Using the default options.

        // Refer the old implementation contract for storage layout comparisons.
        options.referenceContract = referenceContractQualifiedPath;

        vm.startBroadcast();
        newImplementation = Upgrades.prepareUpgrade(upgradeContractQualifiedPath, options);
        vm.stopBroadcast();

        _afterUpgrade(moduleName_, newImplementation);
    }

    function _afterDeployment(string memory moduleName_, address contract_) internal override {
        string memory deploymentsFile = getDeploymentsTomlFile();

        vm.writeToml(vm.toString(contract_), getDeploymentsFilePath(), string.concat(".", moduleName_, ".contract"));

        (bool success, bytes memory data) = (contract_).call(abi.encodeWithSignature("MODULE_KEY()"));

        if (!success) {
            console2.log(
                StdStyle.yellow(
                    string.concat(
                        "Module ",
                        moduleName_,
                        " does not have a MODULE_KEY() function. Please authorize this module manually"
                    )
                )
            );

            console2.log("Skipping authorization of the new implementation for %s", moduleName_);

            return;
        } else {
            console2.log("Authorizing the new implementation for %s", moduleName_);

            addToBatch(
                deploymentsFile.readAddress(".FlatcoinVault.proxy"),
                abi.encodeCall(
                    FlatcoinVault.addAuthorizedModule,
                    (
                        FlatcoinStructs.AuthorizedModule({
                            moduleAddress: contract_,
                            moduleKey: abi.decode(data, (bytes32))
                        })
                    )
                )
            );
        }
    }

    function _afterUpgrade(string memory moduleName_, address newImplementation_) private {
        string memory deploymentsFile = getDeploymentsTomlFile();
        string memory proxyKey = string.concat(".", moduleName_, ".proxy");

        // If the deployments file exists as well as the original module configs, update the implementation address.
        if (vm.keyExistsToml(deploymentsFile, proxyKey)) {
            ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(deploymentsFile.readAddress(proxyKey));

            vm.writeToml(
                vm.toString(newImplementation_),
                getDeploymentsFilePath(),
                string.concat(".", moduleName_, ".implementation")
            );

            console2.log("\nUse the following encoded hex data for creating a transaction: ");
            console2.logBytes(abi.encodeCall(ProxyAdmin.upgradeAndCall, (proxy, newImplementation_, bytes(""))));
        } else {
            console2.log("Key %s not found", moduleName_);
            console2.log("Skipping updating the implementation address for %s", moduleName_);
        }

        console2.log("New implementation for %s deployed at: %s", moduleName_, newImplementation_);

        flattenContract(moduleName_);
    }
}
