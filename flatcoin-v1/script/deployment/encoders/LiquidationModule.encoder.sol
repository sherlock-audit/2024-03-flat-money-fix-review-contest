// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {LiquidationModule} from "../../../src/LiquidationModule.sol";
import {FlatcoinVault} from "../../../src/FlatcoinVault.sol";
import {EncoderBase} from "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract LiquidationModuleEncoder is EncoderBase {
    using stdToml for string;

    function getEncodedCallData() public override returns (bytes memory) {
        string memory configTomlFile = getConfigTomlFile();
        string memory deploymentsTomlFile = getDeploymentsTomlFile();

        FlatcoinVault vault = FlatcoinVault(deploymentsTomlFile.readAddress(".FlatcoinVault.proxy"));

        require(address(vault) != address(0), "LiquidationModuleEncoder: Vault address null");

        return
            abi.encodeCall(
                LiquidationModule.initialize,
                (
                    vault,
                    uint128(configTomlFile.readUint(".LiquidationModule.liquidationFeeRatio")),
                    uint128(configTomlFile.readUint(".LiquidationModule.liquidationBufferRatio")),
                    configTomlFile.readUint(".LiquidationModule.liquidationFeeLowerBound"),
                    configTomlFile.readUint(".LiquidationModule.liquidationFeeUpperBound")
                )
            );
    }
}
