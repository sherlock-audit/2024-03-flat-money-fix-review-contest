// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {PointsModule} from "../../../src/PointsModule.sol";
import {FlatcoinVault} from "../../../src/FlatcoinVault.sol";
import {FlatcoinStructs} from "../../../src/libraries/FlatcoinStructs.sol";
import {EncoderBase} from "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract PointsModuleEncoder is EncoderBase {
    using stdToml for string;

    function getEncodedCallData() public override returns (bytes memory) {
        string memory configTomlFile = getConfigTomlFile();
        string memory deploymentsTomlFile = getDeploymentsTomlFile();

        FlatcoinVault vault = FlatcoinVault(deploymentsTomlFile.readAddress(".FlatcoinVault.proxy"));

        require(address(vault) != address(0), "PointsModuleEncoder: Vault address null");

        return
            abi.encodeCall(
                PointsModule.initialize,
                (
                    vault,
                    configTomlFile.readAddress(".PointsModule.treasury"),
                    configTomlFile.readUint(".PointsModule.unlockTaxVest"),
                    configTomlFile.readUint(".PointsModule.pointsPerSize"),
                    configTomlFile.readUint(".PointsModule.pointsPerDeposit"),
                    configTomlFile.readUint(".PointsModule.maxAccumulatedMint"),
                    uint64(configTomlFile.readUint(".PointsModule.decayTime"))
                )
            );
    }
}
