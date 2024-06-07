// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";

import {FileManager} from "../utils/FileManager.sol";

import "forge-std/StdToml.sol";
import "forge-std/StdStyle.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";

/// @title UpgradesCheckerScript
/// @author dHEDGE
/// @notice Script to check if any module requires an upgrade. Relies on the `forge verify-bytecode` command.
contract UpgradesCheckerScript is FileManager {
    using stdToml for string;

    function run() public {
        console2.log("Checking if any module requires upgrade...");

        string memory deploymentsFile = getDeploymentsTomlFile();
        string[] memory moduleNames = vm.parseTomlKeys(deploymentsFile, "$");

        for (uint8 i; i < moduleNames.length; ++i) {
            console2.log("\n");

            if (vm.keyExistsToml(deploymentsFile, string.concat(".", moduleNames[i], ".contract"))) {
                console2.log("Module %s is an immutable contract, skipping check", moduleNames[i]);
            } else if (vm.keyExistsToml(deploymentsFile, string.concat(".", moduleNames[i], ".proxy"))) {
                string memory oldImplementationQualifiedPath = getFlattenedContractQualifiedPath(moduleNames[i]);
                string memory newImplementationQualifiedPath = getModuleQualifiedPath(moduleNames[i]);
                address deployedImplementation = deploymentsFile.readAddress(
                    string.concat(".", moduleNames[i], ".implementation")
                );

                if (_verifyBytecode(deployedImplementation, newImplementationQualifiedPath)) {
                    console2.log(StdStyle.cyan(string.concat("Module ", moduleNames[i], " does not require upgrade")));
                } else {
                    console2.log(StdStyle.magenta(string.concat("Module ", moduleNames[i], " may require an upgrade")));

                    Options memory options;
                    options.referenceContract = oldImplementationQualifiedPath;

                    // Check if the upgrade is safe to do by comparing storage layouts.
                    try this.validateUpgrade(newImplementationQualifiedPath, options) {
                        console2.log(StdStyle.green(string.concat("Module ", moduleNames[i], " is safe to upgrade")));
                    } catch {
                        console2.log(StdStyle.red(string.concat("Module ", moduleNames[i], " is not safe to upgrade")));
                    }
                }
            }
        }
    }

    function validateUpgrade(string memory moduleQualifiedPath, Options memory options) external {
        Upgrades.validateUpgrade(moduleQualifiedPath, options);
    }

    function _verifyBytecode(
        address oldImplementation,
        string memory moduleQualifiedPath
    ) private returns (bool matched_) {
        string[] memory input = new string[](3);
        input[0] = "bash";
        input[1] = "-c";

        string memory chainName = vm.envString(string.concat("CHAIN_NAME_", vm.toString(block.chainid)));
        string memory forgeCommand = string.concat(
            "'",
            "forge verify-bytecode ",
            vm.toString(oldImplementation),
            " ",
            moduleQualifiedPath,
            " --rpc-url ",
            chainName,
            "'",
            "; "
        );

        string memory bashScript = string.concat(
            "COMMAND=",
            forgeCommand,
            "$($COMMAND | tail -n 1 | sed -r 's,\\x1B\\[([0-9;]*m),,g' | grep -q 'Runtime code matched with status full'); ",
            "echo -n $?"
        );

        input[2] = bashScript;

        Vm.FfiResult memory result = vm.tryFfi(input);

        if (result.exitCode != 0) {
            console2.log("Failed to verify bytecode");
            console2.log("Error: ");
            console2.logBytes(result.stderr);

            revert("Failed to verify bytecode");
        } else {
            // 0x31 is the ASCII code 48 for '0'. So check if the output is '0'.
            if (keccak256(abi.encodePacked(vm.toString(result.stdout))) == keccak256(abi.encodePacked("0x31"))) {
                matched_ = true;
            } else {
                matched_ = false;
            }
        }
    }
}
