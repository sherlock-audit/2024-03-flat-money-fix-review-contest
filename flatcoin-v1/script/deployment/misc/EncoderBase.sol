// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "../../utils/FileManager.sol";

abstract contract EncoderBase is FileManager {
    function getEncodedCallData() public virtual returns (bytes memory) {}
}
