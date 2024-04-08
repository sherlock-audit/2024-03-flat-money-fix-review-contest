// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import "forge-std/Script.sol";

contract DeployScript is Script {
    function deployUpgradeableContract(
        string memory moduleName_,
        address proxyAdminOwner_,
        bytes memory encodedCallData_
    ) public returns (address proxy_, address implementation_, address proxyAdmin_) {
        vm.startBroadcast();

        proxy_ = Upgrades.deployTransparentProxy(moduleName_, proxyAdminOwner_, encodedCallData_);

        vm.stopBroadcast();

        implementation_ = Upgrades.getImplementationAddress(proxy_);
        proxyAdmin_ = Upgrades.getAdminAddress(proxy_);

        _afterDeployment(moduleName_, proxy_, implementation_, proxyAdmin_);
    }

    function deployImmutableContract(
        string memory moduleName_,
        bytes memory constructorData_
    ) public returns (address contract_) {
        vm.startBroadcast();

        contract_ = deploy(moduleName_, constructorData_);

        vm.stopBroadcast();

        _afterDeployment(moduleName_, contract_);
    }

    /// @dev Adapted from OpenZeppelin's Foundry Upgrades package.
    ///      See the original implementation at: https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades/blob/359589365aeba6cf41d39bae69867446b194e582/src/Upgrades.sol#L487
    function deploy(string memory contractName, bytes memory constructorData) public returns (address) {
        bytes memory creationCode = vm.getCode(contractName);
        address deployedAddress = _deployFromBytecode(abi.encodePacked(creationCode, constructorData));
        if (deployedAddress == address(0)) {
            revert(
                string.concat(
                    "Failed to deploy contract ",
                    contractName,
                    ' using constructor data "',
                    string(constructorData),
                    '"'
                )
            );
        }

        return deployedAddress;
    }

    function _deployFromBytecode(bytes memory bytecode) private returns (address) {
        address addr;
        assembly {
            addr := create(0, add(bytecode, 32), mload(bytecode))
        }
        return addr;
    }

    function _afterDeployment(
        string memory moduleName_,
        address proxy_,
        address implementation_,
        address proxyAdmin
    ) private {
        string memory projectRoot = vm.projectRoot();
        string memory chainId = vm.toString(block.chainid);
        string memory deploymentsFilePath = string.concat(projectRoot, "/deployments/", chainId, ".toml");

        // If the deployments file related to thte current chain does not exist, create it.
        if (!vm.isFile(deploymentsFilePath)) {
            vm.writeFile(
                deploymentsFilePath,
                "# This file was generated programmatically by the Foundry deployment script.\n\n"
            );
        }

        string memory existingDeployments = vm.readFile(deploymentsFilePath);
        string memory moduleName = _trimModuleName(moduleName_);
        string memory newKeyToAppend = string.concat(
            "[",
            moduleName,
            "]\n",
            'proxy="',
            vm.toString(proxy_),
            '"\n',
            'implementation="',
            vm.toString(implementation_),
            '"\n',
            'proxyAdmin="',
            vm.toString(proxyAdmin),
            '"\n\n'
        );

        vm.writeFile(deploymentsFilePath, string.concat(existingDeployments, newKeyToAppend));
        vm.closeFile(deploymentsFilePath);
    }

    function _afterDeployment(string memory moduleName_, address contract_) private {
        string memory projectRoot = vm.projectRoot();
        string memory chainId = vm.toString(block.chainid);
        string memory deploymentsFilePath = string.concat(projectRoot, "/deployments/", chainId, ".toml");

        // If the deployments file related to thte current chain does not exist, create it.
        if (!vm.isFile(deploymentsFilePath)) {
            vm.writeFile(
                deploymentsFilePath,
                "# This file was generated programmatically by the Foundry deployment script.\n\n"
            );
        }

        string memory existingDeployments = vm.readFile(deploymentsFilePath);
        string memory moduleName = _trimModuleName(moduleName_);
        string memory newKeyToAppend = string.concat(
            "[",
            moduleName,
            "]\n",
            'contract="',
            vm.toString(contract_),
            '"\n\n'
        );

        vm.writeFile(deploymentsFilePath, string.concat(existingDeployments, newKeyToAppend));
        vm.closeFile(deploymentsFilePath);
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
