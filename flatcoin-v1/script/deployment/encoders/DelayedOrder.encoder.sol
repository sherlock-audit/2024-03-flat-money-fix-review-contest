// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {DelayedOrder} from "../../../src/DelayedOrder.sol";
import {FlatcoinVault} from "../../../src/FlatcoinVault.sol";
import {EncoderBase} from "../misc/EncoderBase.sol";

import "forge-std/StdToml.sol";

contract DelayedOrderEncoder is EncoderBase {
    using stdToml for string;

    function getEncodedCallData() public override returns (bytes memory) {
        string memory deploymentsTomlFile = getDeploymentsTomlFile();

        FlatcoinVault vault = FlatcoinVault(deploymentsTomlFile.readAddress(".FlatcoinVault.proxy"));

        require(address(vault) != address(0), "DelayedOrderEncoder: Vault address null");

        return abi.encodeCall(DelayedOrder.initialize, (vault));
    }
}
