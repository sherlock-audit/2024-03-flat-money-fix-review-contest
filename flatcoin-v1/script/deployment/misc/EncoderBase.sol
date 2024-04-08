// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdToml.sol";

abstract contract EncoderBase is Script {
    using stdToml for string;

    function getConfigTomlFile() public returns (string memory configTomlFile) {
        string memory projectRoot = vm.projectRoot();
        string memory chainId = vm.toString(block.chainid);
        string memory configFilePath = string.concat(projectRoot, "/script/deployment/configs/", chainId, ".toml");
        
        require(vm.isFile(configFilePath), string.concat("Config file not found: ", configFilePath));
        
        configTomlFile = vm.readFile(configFilePath);

        vm.closeFile(configFilePath);
    }

    function getDeploymentsTomlFile() public returns (string memory deploymentsTomlFile) {
        string memory projectRoot = vm.projectRoot();
        string memory chainId = vm.toString(block.chainid);
        string memory configFilePath = string.concat(projectRoot, "/deployments/", chainId, ".toml");
        
        require(vm.isFile(configFilePath), string.concat("Deployments file not found: ", configFilePath));
        
        deploymentsTomlFile = vm.readFile(configFilePath);

        vm.closeFile(configFilePath);
    }

    function getEncodedCallData() public virtual returns (bytes memory) {

    }
}
