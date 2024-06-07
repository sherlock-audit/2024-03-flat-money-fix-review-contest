// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {EncoderBase} from "../deployment/misc/EncoderBase.sol";
import {FileManager} from "../utils/FileManager.sol";
import {BatchScript} from "../utils/BatchScript.sol";

import {FlatcoinVault} from "../../src/FlatcoinVault.sol";
import {FlatcoinStructs} from "../../src/libraries/FlatcoinStructs.sol";

import "forge-std/StdStyle.sol";
import "forge-std/StdToml.sol";
import "forge-std/console2.sol";

/// @title DeployScript
/// @author dHEDGE
/// @notice Deployment script for deploying upgradeable and immutable contracts.
/// @dev The script assumes the following:
///      - The encoded initialization data can be retrieved from an encoder contract.
///      - The encoder contract file name should be the same as the module name with the suffix `.encoder.sol`.
///      - The encoder contract name should be the same as the module name with the suffix `Encoder`.
contract DeployScript is BatchScript, FileManager {
    using stdToml for string;

    function deployModules(string[] memory moduleName_, bool send_) public {
        string memory configFile = getConfigTomlFile();

        for (uint8 i; i < moduleName_.length; ++i) {
            string memory moduleName = moduleName_[i];

            if (configFile.readBool(string.concat(".", moduleName, ".isUpgradeable")) == false) {
                deployImmutableContract(moduleName);
            } else {
                deployUpgradeableContract(moduleName);
            }
        }

        if (encodedTxns.length != 0) executeBatch(configFile.readAddress(".owner"), send_);
    }

    function deployUpgradeableContract(
        string memory moduleName_
    ) internal returns (address proxy_, address implementation_, address proxyAdmin_) {
        address proxyAdminOwner = getConfigTomlFile().readAddress(".owner");

        // Basically, the encoder contract qualified path should be of the form:- <moduleName>.encoder.sol:<moduleName>Encoder
        EncoderBase encoder = EncoderBase(
            deployCode(string.concat(moduleName_, ".encoder.sol:", moduleName_, "Encoder"))
        );

        vm.startBroadcast();

        proxy_ = Upgrades.deployTransparentProxy(
            string.concat(moduleName_, ".sol"),
            proxyAdminOwner,
            encoder.getEncodedCallData()
        );

        vm.stopBroadcast();

        implementation_ = Upgrades.getImplementationAddress(proxy_);
        proxyAdmin_ = Upgrades.getAdminAddress(proxy_);

        _afterDeployment(moduleName_, proxy_, implementation_, proxyAdmin_);
    }

    function deployImmutableContract(string memory moduleName_) internal returns (address contract_) {
        EncoderBase encoder = EncoderBase(
            deployCode(string.concat(moduleName_, ".encoder.sol:", moduleName_, "Encoder"))
        );

        vm.startBroadcast();

        contract_ = deploy(string.concat(moduleName_, ".sol"), encoder.getEncodedCallData());

        vm.stopBroadcast();

        _afterDeployment(moduleName_, contract_);
    }

    /// @dev Adapted from OpenZeppelin's Foundry Upgrades package.
    ///      See the original implementation at: https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades/blob/359589365aeba6cf41d39bae69867446b194e582/src/Upgrades.sol#L487
    ///      This function has to be public to be able to broadcast the contract creation transaction.
    function deploy(string memory contractName_, bytes memory constructorData_) public returns (address) {
        bytes memory creationCode = vm.getCode(contractName_);
        address deployedAddress = _deployFromBytecode(abi.encodePacked(creationCode, constructorData_));

        if (deployedAddress == address(0)) {
            console2.log("Failed to deploy contract %s using the constructor data: ", contractName_);
            console2.logBytes(constructorData_);

            revert("Immutable contract deployment failed");
        }

        return deployedAddress;
    }

    function _afterDeployment(
        string memory moduleName_,
        address proxy_,
        address implementation_,
        address proxyAdmin
    ) internal virtual {
        string memory newKeyToAppend = _getNewKeyToAppend(moduleName_, proxy_, implementation_, proxyAdmin);

        _tryAuthorizeModule(moduleName_, proxy_);
        flattenContract(moduleName_);
        _appendKeyToFile(newKeyToAppend);
    }

    function _afterDeployment(string memory moduleName_, address contract_) internal virtual {
        string memory newKeyToAppend = _getNewKeyToAppend(moduleName_, contract_);

        _tryAuthorizeModule(moduleName_, contract_);
        _appendKeyToFile(newKeyToAppend);
    }

    function _tryAuthorizeModule(string memory moduleName_, address contract_) internal virtual {
        (bool success, bytes memory data) = (contract_).call(abi.encodeWithSignature("MODULE_KEY()"));

        if (!success) {
            console2.log(
                StdStyle.yellow(
                    string.concat(
                        "Module ",
                        moduleName_,
                        " does not have a MODULE_KEY() function. Please authorize this module manually if required."
                    )
                )
            );

            console2.log("Skipping authorization of the new implementation for %s", moduleName_);

            return;
        } else {
            console2.log("Authorizing the new implementation for %s", moduleName_);

            addToBatch(
                getDeploymentsTomlFile().readAddress(".FlatcoinVault.proxy"),
                abi.encodeCall(
                    FlatcoinVault.addAuthorizedModule,
                    (
                        FlatcoinStructs.AuthorizedModule({
                            moduleAddress: contract_,
                            moduleKey: abi.decode(data, (bytes32))
                        })
                    )
                )
            );
        }
    }

    function _appendKeyToFile(string memory key_) private {
        string memory deploymentsFilePath = getDeploymentsFilePath();
        string memory existingDeployments = getDeploymentsTomlFile();

        vm.writeFile(deploymentsFilePath, string.concat(existingDeployments, key_));
    }

    function _deployFromBytecode(bytes memory bytecode) private returns (address) {
        address addr;
        assembly {
            addr := create(0, add(bytecode, 32), mload(bytecode))
        }
        return addr;
    }

    function _getNewKeyToAppend(
        string memory moduleName_,
        address proxy_,
        address implementation_,
        address proxyAdmin_
    ) private pure returns (string memory) {
        return
            string.concat(
                "[",
                moduleName_,
                "]\n",
                'proxy="',
                vm.toString(proxy_),
                '"\n',
                'implementation="',
                vm.toString(implementation_),
                '"\n',
                'proxyAdmin="',
                vm.toString(proxyAdmin_),
                '"\n\n'
            );
    }

    function _getNewKeyToAppend(string memory moduleName_, address contract_) private pure returns (string memory) {
        return string.concat("[", moduleName_, "]\n", 'contract="', vm.toString(contract_), '"\n\n');
    }
}
