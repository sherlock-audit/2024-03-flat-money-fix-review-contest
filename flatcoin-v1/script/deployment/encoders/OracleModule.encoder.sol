// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {OracleModule} from "../../../src/OracleModule.sol";
import {FlatcoinVault} from "../../../src/FlatcoinVault.sol";
import {FlatcoinStructs} from "../../../src/libraries/FlatcoinStructs.sol";
import {IChainlinkAggregatorV3} from "../../../src/interfaces/IChainlinkAggregatorV3.sol";
import {IPyth} from "pyth-sdk-solidity/IPyth.sol";
import {EncoderBase} from "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract OracleModuleEncoder is EncoderBase {
    using stdToml for string;

    function getEncodedCallData() public override returns (bytes memory) {
        string memory configTomlFile = getConfigTomlFile();
        string memory deploymentsTomlFile = getDeploymentsTomlFile();

        FlatcoinVault vault = FlatcoinVault(deploymentsTomlFile.readAddress(".FlatcoinVault.proxy"));

        require(address(vault) != address(0), "OracleModuleEncoder: Vault address null");

        FlatcoinStructs.OnchainOracle memory onchainOracleConfig = FlatcoinStructs.OnchainOracle(
            IChainlinkAggregatorV3(configTomlFile.readAddress(".OracleModule.onchainOracle.oracleContract")),
            uint32(configTomlFile.readUint(".OracleModule.onchainOracle.maxAge"))
        );
        FlatcoinStructs.OffchainOracle memory offchainOracleConfig = FlatcoinStructs.OffchainOracle(
            IPyth(configTomlFile.readAddress(".OracleModule.offchainOracle.oracleContract")),
            bytes32(configTomlFile.readBytes32(".OracleModule.offchainOracle.priceId")),
            uint32(configTomlFile.readUint(".OracleModule.offchainOracle.maxAge")),
            uint32(configTomlFile.readUint(".OracleModule.offchainOracle.minConfidenceRatio"))
        );

        return
            abi.encodeCall(
                OracleModule.initialize,
                (
                    vault,
                    configTomlFile.readAddress(".OracleModule.collateral"),
                    onchainOracleConfig,
                    offchainOracleConfig,
                    configTomlFile.readUint(".OracleModule.maxDiffPercent")
                )
            );
    }
}
