// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {StableModule} from "../../../src/StableModule.sol";
import {FlatcoinVault} from "../../../src/FlatcoinVault.sol";
import {EncoderBase} from "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract StableModuleEncoder is EncoderBase {
    using stdToml for string;

    function getEncodedCallData() public override returns (bytes memory) {
        string memory configTomlFile = getConfigTomlFile();
        string memory deploymentsTomlFile = getDeploymentsTomlFile();

        FlatcoinVault vault = FlatcoinVault(deploymentsTomlFile.readAddress(".FlatcoinVault.proxy"));

        require(address(vault) != address(0), "StableModuleEncoder: Vault address null");

        return
            abi.encodeCall(
                StableModule.initialize,
                (vault, configTomlFile.readUint(".StableModule.stableWithdrawFee"))
            );
    }
}
