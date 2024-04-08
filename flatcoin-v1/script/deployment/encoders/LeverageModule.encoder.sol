// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {LeverageModule} from "../../../src/LeverageModule.sol";
import {FlatcoinVault} from "../../../src/FlatcoinVault.sol";
import {EncoderBase} from "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract LeverageModuleEncoder is EncoderBase {
    using stdToml for string;

    function getEncodedCallData() public override returns (bytes memory) {
        string memory tomlFile = getConfigTomlFile();
        string memory deploymentsTomlFile = getDeploymentsTomlFile();

        FlatcoinVault vault = FlatcoinVault(deploymentsTomlFile.readAddress(".FlatcoinVault.proxy"));

        require(address(vault) != address(0), "LeverageModuleEncoder: Vault address null");

        return
            abi.encodeCall(
                LeverageModule.initialize,
                (
                    vault,
                    tomlFile.readUint(".LeverageModule.leverageTradingFee"),
                    tomlFile.readUint(".LeverageModule.marginMin"),
                    tomlFile.readUint(".LeverageModule.leverageMin"),
                    tomlFile.readUint(".LeverageModule.leverageMax")
                )
            );
    }
}
