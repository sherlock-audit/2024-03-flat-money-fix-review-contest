// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";
import {BatchScript} from "../utils/BatchScript.sol";
import {Surl} from "../utils/Surl.sol";
import {EncoderBase} from "../deployment/misc/EncoderBase.sol";

import "forge-std/StdToml.sol";
import "forge-std/Script.sol";

/// @dev OZ Docs are available at https://docs.openzeppelin.com/upgrades-plugins/1.x/api-foundry-upgrades#Upgrades
contract UpgradeModule is BatchScript {
    using stdToml for string;

    /// @notice Deploys the implementation contract and returns the address.
    /// @dev Note that the new module must contain `@custom:oz-upgrades-from <reference>` annotation.
    ///      Where reference is the name of the module to upgrade from.
    /// @dev Use this function to validate and deploy the new implementation contract.
    ///      This function can be used to build a Gnosis Safe transaction using Safe Transaction Builder.
    /// @param originalModuleName_ The name of the module/contract with the proxy address deployed with the system contracts.
    /// @param moduleName_ The name of the module/contract to upgrade to.
    function prepareUpgrade(
        string memory originalModuleName_,
        string memory moduleName_
    ) public returns (address newImplementation) {
        string memory projectRoot = vm.projectRoot();
        string memory chainId = vm.toString(block.chainid);
        string memory deploymentsConfigFile = string.concat(projectRoot, "/deployments/", chainId, ".toml");
        string memory moduleNameTrimmed = _trimModuleName(originalModuleName_);

        Options memory options; // Using the default options.

        vm.startBroadcast();
        newImplementation = Upgrades.prepareUpgrade(moduleName_, options);
        vm.stopBroadcast();

        // If the deployments file exists as well as the original module configs, update the implementation address.
        if (vm.isFile(deploymentsConfigFile) && vm.keyExistsToml(deploymentsConfigFile, moduleNameTrimmed)) {
            ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(
                deploymentsConfigFile.readAddress(string.concat(".", moduleNameTrimmed, ".proxy"))
            );

            vm.writeToml(vm.toString(newImplementation), string.concat(".", moduleNameTrimmed, ".implementation"));

            console2.log("Use the following encoded hex data for creating a transaction: ");
            console2.logBytes(abi.encodeCall(ProxyAdmin.upgradeAndCall, (proxy, newImplementation, bytes(""))));
        } else {
            console2.log("Deployments file not found at %s with key %s", deploymentsConfigFile, moduleNameTrimmed);
            console2.log("Skipping updating the implementation address for %s", originalModuleName_);
        }

        console2.log(
            "New implementation %s for %s deployed at: %s",
            moduleName_,
            originalModuleName_,
            newImplementation
        );
    }

    function upgradeProxyViaSafe(address safe_, address proxy_, string memory contractName_) public {
        bytes memory data;
        Options memory options;

        addToBatch(
            safe_,
            0,
            abi.encodeWithSignature(
                "upgradeProxy(address,string,bytes,(string,bytes,string,bool,bool,bool,(bool,bool,string,bytes32,string)))",
                proxy_,
                contractName_,
                data,
                options
            )
        );

        executeBatch(safe_, true);
    }

    function _trimModuleName(string memory moduleName_) private pure returns (string memory) {
        bytes memory moduleNameBytes = bytes(moduleName_);
        uint8 moduleNameLength = uint8(moduleNameBytes.length) - 4; // Remove the ".sol" extension
        bytes memory trimmedModuleName = new bytes(moduleNameLength);

        for (uint8 i; i < moduleNameLength; ++i) {
            trimmedModuleName[i] = moduleNameBytes[i];
        }

        return string(trimmedModuleName);
    }
}
