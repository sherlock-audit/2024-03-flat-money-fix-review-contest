// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FlatcoinVault} from "../../../src/FlatcoinVault.sol";
import "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract FlatcoinVaultEncoder is EncoderBase {
    using stdToml for string;

    function getEncodedCallData() public override returns (bytes memory) {
        string memory tomlFile = getConfigTomlFile();

        address collateral = tomlFile.readAddress(".FlatcoinVault.collateral");
        uint64 maxExecutabilityAge = uint64(tomlFile.readUint(".FlatcoinVault.maxExecutabilityAge"));
        uint256 maxFundingVelocity = tomlFile.readUint(".FlatcoinVault.maxFundingVelocity");
        uint256 maxVelocitySkew = tomlFile.readUint(".FlatcoinVault.maxVelocitySkew");
        uint64 minExecutabilityAge = uint64(tomlFile.readUint(".FlatcoinVault.minExecutabilityAge"));
        uint256 skewFractionMax = tomlFile.readUint(".FlatcoinVault.skewFractionMax");
        uint256 stableCollateralCap = tomlFile.readUint(".FlatcoinVault.stableCollateralCap");

        return
            abi.encodeCall(
                FlatcoinVault.initialize,
                (
                    IERC20(collateral),
                    maxFundingVelocity,
                    maxVelocitySkew,
                    skewFractionMax,
                    stableCollateralCap,
                    minExecutabilityAge,
                    maxExecutabilityAge
                )
            );
    }
}
