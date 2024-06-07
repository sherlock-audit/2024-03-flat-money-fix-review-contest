// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Vm.sol";
import "forge-std/Script.sol";

abstract contract FileManager is Script {
    function initProtocolDeploymentFile() internal {
        string memory deploymentsConfigDirPath = getDeploymentsDirPath();
        string memory deploymentsConfigFilePath = getDeploymentsFilePath();

        // Create a directory if it doesn't exist.
        if (!vm.isDir(deploymentsConfigDirPath)) {
            vm.createDir(deploymentsConfigDirPath, false);
        } else {
            // If there is a deployments file for the chainid, then:
            // - Read the contents of the file.
            // - Create a new file with the same contents but with a new timestamp i.e, <chain_id-timestamp>.toml.
            // - Delete the old file.
            if (vm.isFile(deploymentsConfigFilePath)) {
                string memory fileContents = vm.readFile(deploymentsConfigFilePath);
                string memory newFilePath = string.concat(
                    deploymentsConfigDirPath,
                    vm.toString(block.chainid),
                    "-",
                    vm.toString(block.timestamp),
                    ".toml"
                );

                vm.writeFile(newFilePath, fileContents);
            }
        }

        // Create/overwrite a new/existing deployments file.
        vm.writeFile(
            deploymentsConfigFilePath,
            "# This file was generated programmatically by the Foundry deployment script.\n\n"
        );
    }

    function getConfigTomlFile() internal returns (string memory configTomlFile) {
        string memory configFilePath = getConfigFilePath();

        require(vm.isFile(configFilePath), string.concat("Config file not found: ", configFilePath));

        configTomlFile = vm.readFile(configFilePath);

        vm.closeFile(configFilePath);
    }

    function getDeploymentsTomlFile() internal returns (string memory deploymentsTomlFile) {
        string memory deploymentsFilePath = getDeploymentsFilePath();

        require(vm.isFile(deploymentsFilePath), string.concat("Deployments file not found: ", deploymentsFilePath));

        deploymentsTomlFile = vm.readFile(deploymentsFilePath);

        vm.closeFile(deploymentsFilePath);
    }

    function getUpgradesHelperTomlFile() internal returns (string memory upgradesHelperTomlFile) {
        string memory upgradesHelperFilePath = getUpgradesHelperFilePath();

        require(
            vm.isFile(upgradesHelperFilePath),
            string.concat("Upgrades helper file not found: ", upgradesHelperFilePath)
        );

        upgradesHelperTomlFile = vm.readFile(upgradesHelperFilePath);

        vm.closeFile(upgradesHelperFilePath);
    }

    function flattenContract(string memory contractName_) internal {
        string[] memory input = new string[](5);
        input[0] = "forge";
        input[1] = "flatten";
        input[2] = "--output";
        input[3] = string.concat(
            getFlattenedContractsRelativeDirPath(),
            contractName_,
            ".",
            vm.toString(block.chainid),
            ".flattened.sol"
        );
        input[4] = string.concat(getModulesRelativePath(), contractName_, ".sol");

        Vm.FfiResult memory result = vm.tryFfi(input);

        if (result.exitCode != 0) {
            console2.log("Failed to flatten contract %s", contractName_);
            console2.log("Error: ");
            console2.logBytes(result.stderr);
        }
    }

    function getConfigFilePath() internal view returns (string memory configFilePath_) {
        return string.concat(vm.projectRoot(), "/script/deployment/configs/", vm.toString(block.chainid), ".toml");
    }

    function getDeploymentsFilePath() internal view returns (string memory deploymentsFilePath_) {
        return string.concat(getDeploymentsDirPath(), vm.toString(block.chainid), ".toml");
    }

    function getDeploymentsDirPath() internal view returns (string memory deploymentsDirPath_) {
        return string.concat(vm.projectRoot(), "/deployments/", vm.toString(block.chainid), "/");
    }

    /// @dev Path to upgrades script helper file.
    function getUpgradesHelperFilePath() internal view returns (string memory upgradesScriptPath_) {
        return string.concat(vm.projectRoot(), "/upgrades-helper.toml");
    }

    function getFlattenedContractQualifiedPath(
        string memory moduleName_
    ) internal view returns (string memory flattenedContractPath_) {
        return string.concat(moduleName_, ".", vm.toString(block.chainid), ".flattened.sol:", moduleName_);
    }

    function getFlattenedContractsRelativeDirPath() internal view returns (string memory flattenedContractsDirPath_) {
        return string.concat("src/flattened-contracts/", vm.toString(block.chainid), "/");
    }

    function getModuleQualifiedPath(
        string memory moduleName_
    ) internal pure returns (string memory upgradeContractPath_) {
        return string.concat(moduleName_, ".sol:", moduleName_);
    }

    /// @dev Path to upgradeable module contracts.
    function getModulesRelativePath() internal pure returns (string memory modulesPath_) {
        return "src/";
    }
}
