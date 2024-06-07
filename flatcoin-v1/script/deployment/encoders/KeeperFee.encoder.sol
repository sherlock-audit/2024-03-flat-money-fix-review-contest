// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {IChainlinkAggregatorV3} from "../../../src/interfaces/IChainlinkAggregatorV3.sol";
import {IOracleModule} from "../../../src/interfaces/IOracleModule.sol";
import {KeeperFee} from "../../../src/misc/KeeperFee.sol";
import {EncoderBase} from "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract KeeperFeeEncoder is EncoderBase {
    using stdToml for string;

    struct KeeperFeeOnlyConfigData {
        address assetToPayWith;
        address ethOracle;
        uint256 gasUnitsL1;
        uint256 gasUnitsL2;
        uint256 keeperFeeLowerBound;
        uint256 keeperFeeUpperBound;
        IOracleModule oracleModule;
        uint256 profitMarginPercent;
        uint256 profitMarginUSD;
        uint256 stalenessPeriod;
    }

    function getEncodedCallData() public override returns (bytes memory) {
        string memory configTomlFile = getConfigTomlFile();
        string memory deploymentsTomlFile = getDeploymentsTomlFile();

        address owner = configTomlFile.readAddress(".owner");
        KeeperFeeOnlyConfigData memory keeperFeeOnlyData = _getKeeperFeeOnlyConfigData(
            configTomlFile,
            deploymentsTomlFile
        );

        return
            abi.encode(
                owner,
                keeperFeeOnlyData.ethOracle,
                keeperFeeOnlyData.oracleModule,
                keeperFeeOnlyData.assetToPayWith,
                keeperFeeOnlyData.profitMarginUSD,
                keeperFeeOnlyData.profitMarginPercent,
                keeperFeeOnlyData.keeperFeeUpperBound,
                keeperFeeOnlyData.keeperFeeLowerBound,
                keeperFeeOnlyData.gasUnitsL1,
                keeperFeeOnlyData.gasUnitsL2,
                keeperFeeOnlyData.stalenessPeriod
            );
    }

    function _getKeeperFeeOnlyConfigData(
        string memory configTomlFile_,
        string memory deploymentsConfigFile_
    ) private pure returns (KeeperFeeOnlyConfigData memory) {
        KeeperFeeOnlyConfigData memory keeperFeeOnlyData = KeeperFeeOnlyConfigData(
            configTomlFile_.readAddress(".KeeperFee.assetToPayWith"),
            configTomlFile_.readAddress(".KeeperFee.ethOracle"),
            configTomlFile_.readUint(".KeeperFee.gasUnitsL1"),
            configTomlFile_.readUint(".KeeperFee.gasUnitsL2"),
            configTomlFile_.readUint(".KeeperFee.keeperFeeLowerBound"),
            configTomlFile_.readUint(".KeeperFee.keeperFeeUpperBound"),
            IOracleModule(deploymentsConfigFile_.readAddress(".OracleModule.proxy")),
            configTomlFile_.readUint(".KeeperFee.profitMarginPercent"),
            configTomlFile_.readUint(".KeeperFee.profitMarginUSD"),
            configTomlFile_.readUint(".KeeperFee.stalenessPeriod")
        );

        return keeperFeeOnlyData;
    }
}
