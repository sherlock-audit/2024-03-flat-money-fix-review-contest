// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ExpectRevert} from "../../helpers/ExpectRevert.sol";
import {OrderHelpers} from "../../helpers/OrderHelpers.sol";
import {FlatcoinErrors} from "../../../src/libraries/FlatcoinErrors.sol";
import {FlatcoinStructs} from "../../../src/libraries/FlatcoinStructs.sol";

contract FlatcoinVaultTest is OrderHelpers, ExpectRevert {
    function test_revert_when_caller_not_owner() public {
        vm.startPrank(alice);

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setSkewFractionMax.selector, 0),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setMaxFundingVelocity.selector, 0),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setMaxVelocitySkew.selector, 0),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setStableCollateralCap.selector, 0),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setExecutabilityAge.selector, 0, 0),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        FlatcoinStructs.AuthorizedModule[] memory authorizedModules;
        FlatcoinStructs.AuthorizedModule memory authorizedModule;

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.addAuthorizedModules.selector, authorizedModules),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.addAuthorizedModule.selector, authorizedModule),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        bytes32 moduleKey;

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.removeAuthorizedModule.selector, moduleKey),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.pauseModule.selector, moduleKey),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.unpauseModule.selector, moduleKey),
            expectedErrorSignature: "OwnableUnauthorizedAccount(address)",
            errorData: abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
        });
    }

    function test_revert_when_caller_not_authorized_module() public {
        vm.startPrank(alice);

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.sendCollateral.selector, alice, 0),
            expectedErrorSignature: "OnlyAuthorizedModule(address)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.OnlyAuthorizedModule.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.updateStableCollateralTotal.selector, 0),
            expectedErrorSignature: "OnlyAuthorizedModule(address)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.OnlyAuthorizedModule.selector, alice)
        });

        FlatcoinStructs.Position memory position;

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setPosition.selector, position, 0),
            expectedErrorSignature: "OnlyAuthorizedModule(address)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.OnlyAuthorizedModule.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.deletePosition.selector, 0),
            expectedErrorSignature: "OnlyAuthorizedModule(address)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.OnlyAuthorizedModule.selector, alice)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.updateGlobalPositionData.selector, 0, 0, 0),
            expectedErrorSignature: "OnlyAuthorizedModule(address)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.OnlyAuthorizedModule.selector, alice)
        });
    }

    function test_revert_when_wrong_skew_fraction_max_value() public {
        vm.startPrank(admin);

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setSkewFractionMax.selector, 0),
            expectedErrorSignature: "InvalidSkewFractionMax(uint256)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.InvalidSkewFractionMax.selector, 0)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setSkewFractionMax.selector, 0.01e18),
            expectedErrorSignature: "InvalidSkewFractionMax(uint256)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.InvalidSkewFractionMax.selector, 0.01e18)
        });
    }

    function test_revert_when_wrong_max_velocity_skew_value() public {
        vm.startPrank(admin);

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setMaxVelocitySkew.selector, 0),
            expectedErrorSignature: "InvalidMaxVelocitySkew(uint256)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.InvalidMaxVelocitySkew.selector, 0)
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setMaxVelocitySkew.selector, 2e18),
            expectedErrorSignature: "InvalidMaxVelocitySkew(uint256)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.InvalidMaxVelocitySkew.selector, 2e18)
        });
    }

    function test_revert_when_wrong_module_params() public {
        vm.startPrank(admin);

        FlatcoinStructs.AuthorizedModule memory module;

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.addAuthorizedModule.selector, module),
            expectedErrorSignature: "ZeroAddress(string)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.ZeroAddress.selector, "moduleAddress")
        });

        module.moduleAddress = address(delayedOrderProxy);

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.addAuthorizedModule.selector, module),
            expectedErrorSignature: "ZeroValue(string)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.ZeroValue.selector, "moduleKey")
        });

        module.moduleKey = bytes32(uint256(1));
        module.moduleAddress = address(0);

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.addAuthorizedModule.selector, module),
            expectedErrorSignature: "ZeroAddress(string)",
            errorData: abi.encodeWithSelector(FlatcoinErrors.ZeroAddress.selector, "moduleAddress")
        });
    }

    function test_revert_when_executability_age_is_wrong() public {
        vm.startPrank(admin);

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setExecutabilityAge.selector, 0, 0),
            expectedErrorSignature: "ZeroValue(string)",
            errorData: abi.encodeWithSelector(
                FlatcoinErrors.ZeroValue.selector,
                "minExecutabilityAge|maxExecutabilityAge"
            )
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setExecutabilityAge.selector, 0, 1),
            expectedErrorSignature: "ZeroValue(string)",
            errorData: abi.encodeWithSelector(
                FlatcoinErrors.ZeroValue.selector,
                "minExecutabilityAge|maxExecutabilityAge"
            )
        });

        _expectRevertWithCustomError({
            target: address(vaultProxy),
            callData: abi.encodeWithSelector(vaultProxy.setExecutabilityAge.selector, 1, 0),
            expectedErrorSignature: "ZeroValue(string)",
            errorData: abi.encodeWithSelector(
                FlatcoinErrors.ZeroValue.selector,
                "minExecutabilityAge|maxExecutabilityAge"
            )
        });
    }
}
