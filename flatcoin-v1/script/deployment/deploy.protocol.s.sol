// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {FlatcoinStructs} from "../../src/libraries/FlatcoinStructs.sol";
import {FlatcoinModuleKeys} from "../../src/libraries/FlatcoinModuleKeys.sol";

import "./encoders/FlatcoinVault.encoder.sol";
import "./encoders/LeverageModule.encoder.sol";
import "./encoders/StableModule.encoder.sol";
import "./encoders/DelayedOrder.encoder.sol";
import "./encoders/OracleModule.encoder.sol";
import "./encoders/LiquidationModule.encoder.sol";
import "./encoders/PointsModule.encoder.sol";
import "./encoders/LimitOrder.encoder.sol";
import "./encoders/KeeperFee.encoder.sol";
import "./encoders/Viewer.encoder.sol";
import "./misc/EncoderBase.sol";

import "../tasks/deploy-module.s.sol";

import "forge-std/Script.sol";
import "forge-std/StdToml.sol";

contract DeployProtocolScript is DeployScript, EncoderBase {
    using stdToml for string;

    FlatcoinVaultEncoder public flatcoinVaultEncoder;
    LeverageModuleEncoder public leverageModuleEncoder;
    StableModuleEncoder public stableModuleEncoder;
    DelayedOrderEncoder public delayedOrderEncoder;
    OracleModuleEncoder public oracleModuleEncoder;
    LiquidationModuleEncoder public liquidationModuleEncoder;
    PointsModuleEncoder public pointsModuleEncoder;
    LimitOrderEncoder public limitOrderEncoder;
    KeeperFeeEncoder public keeperFeeEncoder;
    ViewerEncoder public viewerEncoder;

    FlatcoinStructs.AuthorizedModule[] public authorizedModules;

    constructor() {
        _deployEncoders();
    }

    function run() public {
        console2.log("Deployer address: ", msg.sender);

        address protocolOwner = (EncoderBase.getConfigTomlFile()).readAddress(".owner");

        (address vaultProxy, , ) = DeployScript.deployUpgradeableContract(
            "FlatcoinVault.sol",
            protocolOwner,
            flatcoinVaultEncoder.getEncodedCallData()
        );
        deployUpgradeableContractAndAuthorize(
            "LeverageModule.sol",
            protocolOwner,
            leverageModuleEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._LEVERAGE_MODULE_KEY
        );
        deployUpgradeableContractAndAuthorize(
            "StableModule.sol",
            protocolOwner,
            stableModuleEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._STABLE_MODULE_KEY
        );
        deployUpgradeableContractAndAuthorize(
            "DelayedOrder.sol",
            protocolOwner,
            delayedOrderEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._DELAYED_ORDER_KEY
        );
        deployUpgradeableContractAndAuthorize(
            "OracleModule.sol",
            protocolOwner,
            oracleModuleEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._ORACLE_MODULE_KEY
        );
        deployUpgradeableContractAndAuthorize(
            "LiquidationModule.sol",
            protocolOwner,
            liquidationModuleEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._LIQUIDATION_MODULE_KEY
        );
        deployUpgradeableContractAndAuthorize(
            "PointsModule.sol",
            protocolOwner,
            pointsModuleEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._POINTS_MODULE_KEY
        );
        deployUpgradeableContractAndAuthorize(
            "LimitOrder.sol",
            protocolOwner,
            limitOrderEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._LIMIT_ORDER_KEY
        );
        deployImmutableContractAndAuthorize(
            "KeeperFee.sol",
            keeperFeeEncoder.getEncodedCallData(),
            FlatcoinModuleKeys._KEEPER_FEE_MODULE_KEY
        );
        DeployScript.deployImmutableContract("Viewer.sol", viewerEncoder.getEncodedCallData());

        vm.startBroadcast();

        // Authorize all the modules.
        FlatcoinVault(vaultProxy).addAuthorizedModules(authorizedModules);

        // Transfer the vault control from deployer to the protocol owner.
        FlatcoinVault(vaultProxy).transferOwnership(protocolOwner);

        vm.stopBroadcast();
    }

    function deployUpgradeableContractAndAuthorize(
        string memory contractName_,
        address owner_,
        bytes memory encodedCallData_,
        bytes32 moduleKey_
    ) public returns (address proxy_, address implementation_, address proxyAdmin_) {
        (proxy_, implementation_, proxyAdmin_) = DeployScript.deployUpgradeableContract(
            contractName_,
            owner_,
            encodedCallData_
        );

        authorizedModules.push(FlatcoinStructs.AuthorizedModule({moduleAddress: proxy_, moduleKey: moduleKey_}));
    }

    function deployImmutableContractAndAuthorize(
        string memory contractName_,
        bytes memory encodedCallData_,
        bytes32 moduleKey_
    ) public returns (address contract_) {
        (contract_) = DeployScript.deployImmutableContract(contractName_, encodedCallData_);

        authorizedModules.push(FlatcoinStructs.AuthorizedModule({moduleAddress: contract_, moduleKey: moduleKey_}));
    }

    function _deployEncoders() private {
        flatcoinVaultEncoder = new FlatcoinVaultEncoder();
        leverageModuleEncoder = new LeverageModuleEncoder();
        stableModuleEncoder = new StableModuleEncoder();
        delayedOrderEncoder = new DelayedOrderEncoder();
        oracleModuleEncoder = new OracleModuleEncoder();
        liquidationModuleEncoder = new LiquidationModuleEncoder();
        pointsModuleEncoder = new PointsModuleEncoder();
        limitOrderEncoder = new LimitOrderEncoder();
        keeperFeeEncoder = new KeeperFeeEncoder();
        viewerEncoder = new ViewerEncoder();
    }
}
