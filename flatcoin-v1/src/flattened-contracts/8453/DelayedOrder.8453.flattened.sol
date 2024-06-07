// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity =0.8.20 ^0.8.0 ^0.8.20;

// lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// lib/pyth-sdk-solidity/IPythEvents.sol

/// @title IPythEvents contains the events that Pyth contract emits.
/// @dev This interface can be used for listening to the updates for off-chain and testing purposes.
interface IPythEvents {
    /// @dev Emitted when the price feed with `id` has received a fresh update.
    /// @param id The Pyth Price Feed ID.
    /// @param publishTime Publish time of the given price update.
    /// @param price Price of the given price update.
    /// @param conf Confidence interval of the given price update.
    event PriceFeedUpdate(bytes32 indexed id, uint64 publishTime, int64 price, uint64 conf);

    /// @dev Emitted when a batch price update is processed successfully.
    /// @param chainId ID of the source chain that the batch price update comes from.
    /// @param sequenceNumber Sequence number of the batch price update.
    event BatchPriceFeedUpdate(uint16 chainId, uint64 sequenceNumber);
}

// lib/pyth-sdk-solidity/PythStructs.sol

contract PythStructs {
    // A price with a degree of uncertainty, represented as a price +- a confidence interval.
    //
    // The confidence interval roughly corresponds to the standard error of a normal distribution.
    // Both the price and confidence are stored in a fixed-point numeric representation,
    // `x * (10^expo)`, where `expo` is the exponent.
    //
    // Please refer to the documentation at https://docs.pyth.network/consumers/best-practices for how
    // to how this price safely.
    struct Price {
        // Price
        int64 price;
        // Confidence interval around the price
        uint64 conf;
        // Price exponent
        int32 expo;
        // Unix timestamp describing when the price was published
        uint publishTime;
    }

    // PriceFeed represents a current aggregate price from pyth publisher feeds.
    struct PriceFeed {
        // The price ID.
        bytes32 id;
        // Latest available price
        Price price;
        // Latest available exponentially-weighted moving average price
        Price emaPrice;
    }
}

// src/interfaces/IChainlinkAggregatorV3.sol

interface IChainlinkAggregatorV3 {
    function decimals() external view returns (uint8 decimals);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// src/interfaces/IKeeperFee.sol

interface IKeeperFee {
    function getKeeperFee() external view returns (uint256 keeperFee);

    function getConfig()
        external
        view
        returns (
            uint256 profitMarginUSD,
            uint256 profitMarginPercent,
            uint256 minKeeperFeeUpperBound,
            uint256 minKeeperFeeLowerBound,
            uint256 gasUnitsL1,
            uint256 gasUnitsL2
        );

    function setParameters(uint256 keeperFeeUpperBound, uint256 keeperFeeLowerBound) external;
}

// src/interfaces/ILiquidationModule.sol

interface ILiquidationModule {
    function canLiquidate(uint256 tokenId) external view returns (bool liquidatable);

    function canLiquidate(uint256 tokenId, uint256 price) external view returns (bool liquidatable);

    function getLiquidationFee(uint256 tokenId) external view returns (uint256 liquidationFee);

    function getLiquidationMargin(uint256 additionalSize) external view returns (uint256 liquidationMargin);

    function getLiquidationMargin(
        uint256 additionalSize,
        uint256 price
    ) external view returns (uint256 liquidationMargin);

    function liquidate(uint256 tokenId) external;

    function liquidate(uint256 tokenID, bytes[] memory priceUpdateData) external payable;

    function liquidationBufferRatio() external view returns (uint128 liquidationBufferRatio);

    function liquidationFeeLowerBound() external view returns (uint256 feeLowerBound);

    function liquidationFeeRatio() external view returns (uint128 liquidationFeeRatio);

    function liquidationFeeUpperBound() external view returns (uint256 feeUpperBound);

    function liquidationPrice(uint256 tokenId) external view returns (uint256 liqPrice);

    function liquidationPrice(uint256 tokenId, uint256 price) external view returns (uint256 liqPrice);

    function setLiquidationBufferRatio(uint128 _newLiquidationBufferRatio) external;

    function setLiquidationFeeRatio(uint128 _newLiquidationFeeRatio) external;
}

// src/libraries/FlatcoinErrors.sol

library FlatcoinErrors {
    enum PriceSource {
        OnChain,
        OffChain
    }

    error ZeroAddress(string variableName);

    error ZeroValue(string variableName);

    error Paused(bytes32 moduleKey);

    error OnlyOwner(address msgSender);

    error AmountTooSmall(uint256 amount, uint256 minAmount);

    error HighSlippage(uint256 supplied, uint256 accepted);

    /// @dev DelayedOrder
    error MaxFillPriceTooLow(uint256 maxFillPrice, uint256 currentPrice);

    /// @dev DelayedOrder
    error MinFillPriceTooHigh(uint256 minFillPrice, uint256 currentPrice);

    /// @dev DelayedOrder
    error NotEnoughMarginForFees(int256 marginAmount, uint256 feeAmount);

    /// @dev DelayedOrder
    error OrderHasExpired();

    /// @dev DelayedOrder
    error OrderHasNotExpired();

    /// @dev DelayedOrder
    error ExecutableTimeNotReached(uint256 executableTime);

    /// @dev DelayedOrder
    error NotTokenOwner(uint256 tokenId, address msgSender);

    /// @dev DelayedOrder
    error MaxSkewReached(uint256 skewFraction);

    /// @dev DelayedOrder
    error InvalidSkewFractionMax(uint256 skewFractionMax);

    /// @dev DelayedOrder
    error InvalidMaxVelocitySkew(uint256 maxVelocitySkew);

    /// @dev DelayedOrder
    error NotEnoughBalanceForWithdraw(address account, uint256 totalBalance, uint256 withdrawAmount);

    /// @dev DelayedOrder
    error WithdrawalTooSmall(uint256 withdrawAmount, uint256 keeperFee);

    /// @dev DelayedOrder
    error InvariantViolation(string variableName);

    /// @dev DelayedOrder
    error InvalidLeverageCriteria();

    /// @dev DelayedOrder
    error LeverageTooLow(uint256 leverageMin, uint256 leverage);

    /// @dev DelayedOrder
    error LeverageTooHigh(uint256 leverageMax, uint256 leverage);

    /// @dev DelayedOrder
    error MarginTooSmall(uint256 marginMin, uint256 margin);

    /// @dev DelayedOrder
    error DepositCapReached(uint256 collateralCap);

    /// @dev LimitOrder
    error LimitOrderInvalid(uint256 tokenId);

    /// @dev LimitOrder
    error LimitOrderPriceNotInRange(uint256 price, uint256 priceLowerThreshold, uint256 priceUpperThreshold);

    /// @dev LimitOrder
    error InvalidThresholds(uint256 priceLowerThreshold, uint256 priceUpperThreshold);

    error InvalidFee(uint256 fee);

    error OnlyAuthorizedModule(address msgSender);

    error ValueNotPositive(string variableName);

    /// @dev LeverageModule
    error MarginMismatchOnClose();

    /// @dev FlatcoinVault
    error InsufficientGlobalMargin();

    /// @dev OracleModule
    error RefundFailed();

    error PriceStale(PriceSource priceSource);

    error PriceInvalid(PriceSource priceSource);

    error PriceMismatch(uint256 diffPercent);

    /// @dev OracleModule
    error OracleConfigInvalid();

    /// @dev StableModule
    error PriceImpactDuringWithdraw();

    /// @dev StableModule
    error PriceImpactDuringFullWithdraw();

    /// @dev KeeperFee
    error ETHPriceInvalid();

    /// @dev KeeperFee
    error ETHPriceStale();

    /// @dev Error to emit when a leverage position is not liquidatable.
    /// @param tokenId The token ID of the position.
    error CannotLiquidate(uint256 tokenId);

    error InvalidBounds(uint256 lower, uint256 upper);

    error PositionCreatesBadDebt();

    error ModuleKeyEmpty();

    /// @dev PointsModule
    error MaxVarianceExceeded(string variableName);
}

// src/libraries/FlatcoinModuleKeys.sol

library FlatcoinModuleKeys {
    bytes32 internal constant _STABLE_MODULE_KEY = bytes32("stableModule");
    bytes32 internal constant _LEVERAGE_MODULE_KEY = bytes32("leverageModule");
    bytes32 internal constant _ORACLE_MODULE_KEY = bytes32("oracleModule");
    bytes32 internal constant _DELAYED_ORDER_KEY = bytes32("delayedOrder");
    bytes32 internal constant _LIMIT_ORDER_KEY = bytes32("limitOrder");
    bytes32 internal constant _LIQUIDATION_MODULE_KEY = bytes32("liquidationModule");
    bytes32 internal constant _KEEPER_FEE_MODULE_KEY = bytes32("keeperFee");
    bytes32 internal constant _POINTS_MODULE_KEY = bytes32("pointsModule");
}

// lib/openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /// @custom:storage-location erc7201:openzeppelin.storage.ReentrancyGuard
    struct ReentrancyGuardStorage {
        uint256 _status;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ReentrancyGuardStorageLocation =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    function _getReentrancyGuardStorage() private pure returns (ReentrancyGuardStorage storage $) {
        assembly {
            $.slot := ReentrancyGuardStorageLocation
        }
    }

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if ($._status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        $._status = ENTERED;
    }

    function _nonReentrantAfter() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        return $._status == ENTERED;
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// src/interfaces/IOracleModule.sol

interface IOracleModule {
    function onchainOracle() external view returns (IChainlinkAggregatorV3 oracleContract, uint32 maxAge);

    function getPrice() external view returns (uint256 price, uint256 timestamp);

    function getPrice(uint32 maxAge) external view returns (uint256 price, uint256 timestamp);

    function updatePythPrice(address sender, bytes[] calldata priceUpdateData) external payable;
}

// lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct OwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableStorageLocation =
        0x9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300;

    function _getOwnableStorage() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    function __Ownable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
    }

    function __Ownable_init_unchained(address initialOwner) internal onlyInitializing {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        OwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        OwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Enumerable.sol)

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// lib/pyth-sdk-solidity/IPyth.sol

/// @title Consume prices from the Pyth Network (https://pyth.network/).
/// @dev Please refer to the guidance at https://docs.pyth.network/consumers/best-practices for how to consume prices safely.
/// @author Pyth Data Association
interface IPyth is IPythEvents {
    /// @notice Returns the period (in seconds) that a price feed is considered valid since its publish time
    function getValidTimePeriod() external view returns (uint validTimePeriod);

    /// @notice Returns the price and confidence interval.
    /// @dev Reverts if the price has not been updated within the last `getValidTimePeriod()` seconds.
    /// @param id The Pyth Price Feed ID of which to fetch the price and confidence interval.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPrice(bytes32 id) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price and confidence interval.
    /// @dev Reverts if the EMA price is not available.
    /// @param id The Pyth Price Feed ID of which to fetch the EMA price and confidence interval.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPrice(bytes32 id) external view returns (PythStructs.Price memory price);

    /// @notice Returns the price of a price feed without any sanity checks.
    /// @dev This function returns the most recent price update in this contract without any recency checks.
    /// This function is unsafe as the returned price update may be arbitrarily far in the past.
    ///
    /// Users of this function should check the `publishTime` in the price to ensure that the returned price is
    /// sufficiently recent for their application. If you are considering using this function, it may be
    /// safer / easier to use either `getPrice` or `getPriceNoOlderThan`.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPriceUnsafe(bytes32 id) external view returns (PythStructs.Price memory price);

    /// @notice Returns the price that is no older than `age` seconds of the current time.
    /// @dev This function is a sanity-checked version of `getPriceUnsafe` which is useful in
    /// applications that require a sufficiently-recent price. Reverts if the price wasn't updated sufficiently
    /// recently.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPriceNoOlderThan(bytes32 id, uint age) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price of a price feed without any sanity checks.
    /// @dev This function returns the same price as `getEmaPrice` in the case where the price is available.
    /// However, if the price is not recent this function returns the latest available price.
    ///
    /// The returned price can be from arbitrarily far in the past; this function makes no guarantees that
    /// the returned price is recent or useful for any particular application.
    ///
    /// Users of this function should check the `publishTime` in the price to ensure that the returned price is
    /// sufficiently recent for their application. If you are considering using this function, it may be
    /// safer / easier to use either `getEmaPrice` or `getEmaPriceNoOlderThan`.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPriceUnsafe(bytes32 id) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price that is no older than `age` seconds
    /// of the current time.
    /// @dev This function is a sanity-checked version of `getEmaPriceUnsafe` which is useful in
    /// applications that require a sufficiently-recent price. Reverts if the price wasn't updated sufficiently
    /// recently.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPriceNoOlderThan(bytes32 id, uint age) external view returns (PythStructs.Price memory price);

    /// @notice Update price feeds with given update messages.
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    /// Prices will be updated if they are more recent than the current stored prices.
    /// The call will succeed even if the update is not the most recent.
    /// @dev Reverts if the transferred fee is not sufficient or the updateData is invalid.
    /// @param updateData Array of price update data.
    function updatePriceFeeds(bytes[] calldata updateData) external payable;

    /// @notice Wrapper around updatePriceFeeds that rejects fast if a price update is not necessary. A price update is
    /// necessary if the current on-chain publishTime is older than the given publishTime. It relies solely on the
    /// given `publishTimes` for the price feeds and does not read the actual price update publish time within `updateData`.
    ///
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    ///
    /// `priceIds` and `publishTimes` are two arrays with the same size that correspond to senders known publishTime
    /// of each priceId when calling this method. If all of price feeds within `priceIds` have updated and have
    /// a newer or equal publish time than the given publish time, it will reject the transaction to save gas.
    /// Otherwise, it calls updatePriceFeeds method to update the prices.
    ///
    /// @dev Reverts if update is not needed or the transferred fee is not sufficient or the updateData is invalid.
    /// @param updateData Array of price update data.
    /// @param priceIds Array of price ids.
    /// @param publishTimes Array of publishTimes. `publishTimes[i]` corresponds to known `publishTime` of `priceIds[i]`
    function updatePriceFeedsIfNecessary(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64[] calldata publishTimes
    ) external payable;

    /// @notice Returns the required fee to update an array of price updates.
    /// @param updateData Array of price update data.
    /// @return feeAmount The required fee in Wei.
    function getUpdateFee(bytes[] calldata updateData) external view returns (uint feeAmount);

    /// @notice Parse `updateData` and return price feeds of the given `priceIds` if they are all published
    /// within `minPublishTime` and `maxPublishTime`.
    ///
    /// You can use this method if you want to use a Pyth price at a fixed time and not the most recent price;
    /// otherwise, please consider using `updatePriceFeeds`. This method does not store the price updates on-chain.
    ///
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    ///
    ///
    /// @dev Reverts if the transferred fee is not sufficient or the updateData is invalid or there is
    /// no update for any of the given `priceIds` within the given time range.
    /// @param updateData Array of price update data.
    /// @param priceIds Array of price ids.
    /// @param minPublishTime minimum acceptable publishTime for the given `priceIds`.
    /// @param maxPublishTime maximum acceptable publishTime for the given `priceIds`.
    /// @return priceFeeds Array of the price feeds corresponding to the given `priceIds` (with the same order).
    function parsePriceFeedUpdates(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64 minPublishTime,
        uint64 maxPublishTime
    ) external payable returns (PythStructs.PriceFeed[] memory priceFeeds);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// src/libraries/FlatcoinStructs.sol

library FlatcoinStructs {
    enum OrderType {
        None, // 0
        StableDeposit, // 1
        StableWithdraw, // 2
        LeverageOpen, // 3
        LeverageClose, // 4
        LeverageAdjust, // 5
        LimitClose // 6
    }

    enum LimitOrderExecutionType {
        None, // 0
        StopLoss, // 1
        ProfitTake // 2
    }

    /// @notice Global position data
    /// @dev This is the consolidated data of all leverage positions used to calculate funding fees and total profit and loss.
    /// @dev One can imagine this as being the data of a single big position on leverage side against the stable side.
    /// @param marginDepositedTotal Total collateral deposited for leverage trade positions.
    /// @param averagePrice The last time funding fees and profit and loss were settled.
    /// @param sizeOpenedTotal The total size of leverage across all trades on entry.
    struct GlobalPositions {
        int256 marginDepositedTotal;
        uint256 averagePrice;
        uint256 sizeOpenedTotal;
    }

    /// @notice Individual leverage position
    struct Position {
        uint256 averagePrice;
        uint256 marginDeposited;
        uint256 additionalSize;
        int256 entryCumulativeFunding;
    }

    struct MarketSummary {
        int256 profitLossTotalByLongs;
        int256 accruedFundingTotalByLongs;
        int256 currentFundingRate;
        int256 nextFundingEntry;
    }

    struct PositionSummary {
        int256 profitLoss;
        int256 accruedFunding;
        int256 marginAfterSettlement;
    }

    struct VaultSummary {
        int256 marketSkew;
        int256 cumulativeFundingRate;
        int256 lastRecomputedFundingRate;
        uint64 lastRecomputedFundingTimestamp;
        uint256 stableCollateralTotal;
        GlobalPositions globalPositions;
    }

    struct Order {
        OrderType orderType;
        uint256 keeperFee; // The deposit paid upon submitting that needs to be paid / refunded on tx confirmation
        uint64 executableAtTime; // The timestamp at which this order is executable at
        bytes orderData;
    }

    struct AnnouncedStableDeposit {
        uint256 depositAmount;
        uint256 minAmountOut; // The minimum amount of tokens expected to receive back
    }

    struct AnnouncedStableWithdraw {
        uint256 withdrawAmount;
        uint256 minAmountOut; // The minimum amount of underlying tokens expected to receive back
    }

    struct AnnouncedLeverageOpen {
        uint256 margin; // The margin amount to be used as leverage collateral
        uint256 additionalSize; // The additional size exposure (leverage)
        uint256 maxFillPrice; // The maximum price accepted by the user
        uint256 tradeFee;
    }

    struct AnnouncedLeverageAdjust {
        uint256 tokenId;
        int256 marginAdjustment;
        int256 additionalSizeAdjustment;
        uint256 fillPrice; // should be passed depending on the type of additionalSizeAdjustment
        uint256 tradeFee;
        uint256 totalFee;
    }

    // Note: the tradeFee is determined at time of execution
    struct LimitClose {
        // Note: the tradeFee is determined at time of execution
        uint256 tokenId;
        uint256 priceLowerThreshold;
        uint256 priceUpperThreshold;
    }

    struct AnnouncedLeverageClose {
        uint256 tokenId; // The NFT of the position
        uint256 minFillPrice; // The minimum price accepted by the user
        uint256 tradeFee;
    }

    struct OnchainOracle {
        IChainlinkAggregatorV3 oracleContract; // Chainlink oracle contract
        uint32 maxAge; // Oldest price that is acceptable to use
    }

    struct OffchainOracle {
        IPyth oracleContract; // Pyth network oracle contract
        bytes32 priceId; // Pyth network price Id
        uint32 maxAge; // Oldest price that is acceptable to use
        uint32 minConfidenceRatio; // the minimum Pyth oracle price / expo ratio. The higher, the more confident the accuracy of the price.
    }

    struct AuthorizedModule {
        bytes32 moduleKey;
        address moduleAddress;
    }

    struct LeveragePositionData {
        uint256 tokenId;
        uint256 averagePrice;
        uint256 marginDeposited;
        uint256 additionalSize;
        int256 entryCumulativeFunding;
        int256 profitLoss;
        int256 accruedFunding;
        int256 marginAfterSettlement;
        uint256 liquidationPrice;
        uint256 limitOrderPriceLowerThreshold;
        uint256 limitOrderPriceUpperThreshold;
    }

    struct MintRate {
        uint256 lastAccumulatedMint;
        uint256 maxAccumulatedMint;
        uint64 lastMintTimestamp;
        uint64 decayTime;
    }
}

// src/interfaces/IDelayedOrder.sol

interface IDelayedOrder {
    // solhint-disable-next-line func-name-mixedcase
    function MIN_DEPOSIT() external view returns (uint256 minStableDeposit);

    function announceLeverageAdjust(
        uint256 tokenId,
        int256 marginAdjustment,
        int256 additionalSizeAdjustment,
        uint256 fillPrice,
        uint256 keeperFee
    ) external;

    function announceLeverageClose(uint256 tokenId, uint256 minFillPrice, uint256 keeperFee) external;

    function announceLeverageOpen(
        uint256 margin,
        uint256 additionalSize,
        uint256 maxFillPrice,
        uint256 keeperFee
    ) external;

    function announceStableDeposit(uint256 depositAmount, uint256 minAmountOut, uint256 keeperFee) external;

    function announceStableWithdraw(uint256 withdrawAmount, uint256 minAmountOut, uint256 keeperFee) external;

    function cancelExistingOrder(address account) external;

    function executeOrder(address account, bytes[] memory priceUpdateData) external payable;

    function getAnnouncedOrder(address account) external view returns (FlatcoinStructs.Order memory order);

    function hasOrderExpired(address account) external view returns (bool expired);
}

// src/interfaces/ILimitOrder.sol

interface ILimitOrder {
    function announceLimitOrder(uint256 tokenId, uint256 priceLowerThreshold, uint256 priceUpperThreshold) external;

    function cancelExistingLimitOrder(uint256 tokenId) external returns (bool cancelled);

    function cancelLimitOrder(uint256 tokenId) external;

    function executeLimitOrder(uint256 tokenId, bytes[] memory priceUpdateData) external payable;

    function getLimitOrder(uint256 tokenId) external view returns (FlatcoinStructs.Order memory order);

    function resetExecutionTime(uint256 tokenId) external;
}

// src/libraries/FlatcoinEvents.sol

library FlatcoinEvents {
    event OrderAnnounced(address account, FlatcoinStructs.OrderType orderType, uint256 keeperFee);

    event OrderExecuted(address account, FlatcoinStructs.OrderType orderType, uint256 keeperFee);

    event OrderCancelled(address account, FlatcoinStructs.OrderType orderType);

    event Deposit(address depositor, uint256 depositAmount, uint256 mintedAmount);

    event Withdraw(address withdrawer, uint256 withdrawAmount, uint256 burnedAmount);

    event LeverageOpen(address account, uint256 tokenId, uint256 entryPrice);

    event LeverageAdjust(uint256 tokenId, uint256 averagePrice, uint256 adjustPrice);

    event LeverageClose(uint256 tokenId, uint256 closePrice, FlatcoinStructs.PositionSummary positionSummary);

    event SetAsset(address asset);

    event SetOnChainOracle(FlatcoinStructs.OnchainOracle oracle);

    event SetOffChainOracle(FlatcoinStructs.OffchainOracle oracle);

    event PositionLiquidated(
        uint256 tokenId,
        address liquidator,
        uint256 liquidationFee,
        uint256 closePrice,
        FlatcoinStructs.PositionSummary positionSummary
    );

    event LiquidationFeeRatioModified(uint256 oldRatio, uint256 newRatio);

    event LiquidationBufferRatioModified(uint256 oldRatio, uint256 newRatio);

    event LiquidationFeeBoundsModified(uint256 oldMin, uint256 oldMax, uint256 newMin, uint256 newMax);

    event VaultAddressModified(address oldAddress, address newAddress);

    event LiquidationFundsDeposited(address depositor, uint256 amount);

    event LiquidationFeesWithdrawn(uint256 amount);

    event SetMaxDiffPercent(uint256 maxDiffPercent);

    event LimitOrderAnnounced(
        address account,
        uint256 tokenId,
        uint256 priceLowerThreshold,
        uint256 priceUpperThreshold
    );

    event LimitOrderExecuted(
        address account,
        uint256 tokenId,
        uint256 keeperFee,
        uint256 price,
        FlatcoinStructs.LimitOrderExecutionType limitOrderType
    );

    event LimitOrderCancelled(address account, uint256 tokenId);
}

// src/interfaces/IFlatcoinVault.sol

interface IFlatcoinVault {
    function collateral() external view returns (IERC20 collateral);

    function lastRecomputedFundingTimestamp() external view returns (uint64 lastRecomputedFundingTimestamp);

    function minExecutabilityAge() external view returns (uint64 minExecutabilityAge);

    function maxExecutabilityAge() external view returns (uint64 maxExecutabilityAge);

    function lastRecomputedFundingRate() external view returns (int256 lastRecomputedFundingRate);

    function cumulativeFundingRate() external view returns (int256 cumulativeFundingRate);

    function maxFundingVelocity() external view returns (uint256 maxFundingVelocity);

    function maxVelocitySkew() external view returns (uint256 maxVelocitySkew);

    function stableCollateralTotal() external view returns (uint256 totalAmount);

    function skewFractionMax() external view returns (uint256 skewFractionMax);

    function moduleAddress(bytes32 _moduleKey) external view returns (address moduleAddress);

    function isAuthorizedModule(address _address) external view returns (bool status);

    function isModulePaused(bytes32 moduleKey) external view returns (bool paused);

    function sendCollateral(address to, uint256 amount) external;

    function getVaultSummary() external view returns (FlatcoinStructs.VaultSummary memory _vaultSummary);

    function getGlobalPositions() external view returns (FlatcoinStructs.GlobalPositions memory _globalPositions);

    function setPosition(FlatcoinStructs.Position memory _position, uint256 _tokenId) external;

    function updateGlobalPositionData(uint256 price, int256 marginDelta, int256 additionalSizeDelta) external;

    function updateStableCollateralTotal(int256 _stableCollateralAdjustment) external;

    function addAuthorizedModules(FlatcoinStructs.AuthorizedModule[] calldata _modules) external;

    function addAuthorizedModule(FlatcoinStructs.AuthorizedModule calldata _module) external;

    function removeAuthorizedModule(bytes32 _moduleKey) external;

    function deletePosition(uint256 _tokenId) external;

    function settleFundingFees() external returns (int256 fundingFees);

    function getCurrentFundingRate() external view returns (int256 fundingRate);

    function getPosition(uint256 _tokenId) external view returns (FlatcoinStructs.Position memory position);

    function checkSkewMax(uint256 sizeChange, int256 stableCollateralChange) external view;

    function checkCollateralCap(uint256 depositAmount) external view;

    function stableCollateralCap() external view returns (uint256 collateralCap);

    function getCurrentSkew() external view returns (int256 skew);
}

// src/interfaces/IStableModule.sol

interface IStableModule is IERC20Metadata {
    function stableCollateralPerShare() external view returns (uint256 collateralPerShare);

    function executeDeposit(
        address account,
        uint64 executableAtTime,
        FlatcoinStructs.AnnouncedStableDeposit calldata announcedDeposit
    ) external returns (uint256 liquidityMinted);

    function executeWithdraw(
        address account,
        uint64 executableAtTime,
        FlatcoinStructs.AnnouncedStableWithdraw calldata announcedWithdraw
    ) external returns (uint256 amountOut, uint256 withdrawFee);

    function stableWithdrawFee() external view returns (uint256 stableWithdrawFee);

    function stableDepositQuote(uint256 depositAmount) external view returns (uint256 amountOut);

    function stableWithdrawQuote(uint256 withdrawAmount) external view returns (uint256 amountOut);

    function lock(address account, uint256 amount) external;

    function unlock(address account, uint256 amount) external;

    function getLockedAmount(address account) external view returns (uint256 amountLocked);
}

// src/interfaces/ILeverageModule.sol

interface ILeverageModule is IERC721Enumerable {
    function executeOpen(
        address account,
        address keeper,
        FlatcoinStructs.Order calldata order
    ) external returns (uint256 newTokenId);

    function executeAdjust(address account, address keeper, FlatcoinStructs.Order calldata order) external;

    function executeClose(
        address account,
        address keeper,
        FlatcoinStructs.Order calldata order
    ) external returns (int256 settledMargin);

    function burn(uint256 tokenId, bytes32 moduleKey) external;

    function lock(uint256 tokenId, bytes32 moduleKey) external;

    function unlock(uint256 tokenId, bytes32 moduleKey) external;

    function isLocked(uint256 tokenId) external view returns (bool lockStatus);

    function isLockedByModule(uint256 _tokenId, bytes32 _moduleKey) external view returns (bool _lockedByModuleStatus);

    function getPositionSummary(
        uint256 tokenId
    ) external view returns (FlatcoinStructs.PositionSummary memory positionSummary);

    function fundingAdjustedLongPnLTotal() external view returns (int256 _fundingAdjustedPnL);

    function fundingAdjustedLongPnLTotal(uint32 maxAge) external view returns (int256 _fundingAdjustedPnL);

    function tokenIdNext() external view returns (uint256 tokenId);

    function leverageTradingFee() external view returns (uint256 leverageTradingFee);

    function checkLeverageCriteria(uint256 margin, uint256 size) external view;

    function marginMin() external view returns (uint256 marginMin);

    function getTradeFee(uint256 size) external view returns (uint256 tradeFee);
}

// src/abstracts/OracleModifiers.sol

/// @title OracleModifiers
abstract contract OracleModifiers {
    /// @dev Important to use this modifier in functions which require the Pyth network price to be updated.
    ///      Otherwise, the invariant checks or any other logic which depends on the Pyth network price may not be correct.
    modifier updatePythPrice(
        IFlatcoinVault vault,
        address sender,
        bytes[] calldata priceUpdateData
    ) {
        IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).updatePythPrice{value: msg.value}(
            sender,
            priceUpdateData
        );
        _;
    }
}

// src/abstracts/ModuleUpgradeable.sol

/// @title ModuleUpgradeable
/// @author dHEDGE
/// @notice This is the base contract for all upgradeable modules in the Flatcoin system.
abstract contract ModuleUpgradeable is Initializable {
    /// @notice The bytes32 encoded key of the module.
    /// @dev Note that this shouldn't change ever for existing modules.
    ///      Due to this module being upgradeable, we can't use immutable here.
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public MODULE_KEY;

    /// @notice The FlatcoinVault contract referred to by all modules.
    /// @dev Contains all the module addresses, the state of the system and more.
    IFlatcoinVault public vault;

    modifier onlyAuthorizedModule() {
        if (vault.isAuthorizedModule(msg.sender) == false) revert FlatcoinErrors.OnlyAuthorizedModule(msg.sender);
        _;
    }

    modifier whenNotPaused() {
        if (vault.isModulePaused(MODULE_KEY)) revert FlatcoinErrors.Paused(MODULE_KEY);
        _;
    }

    modifier onlyOwner() {
        if (OwnableUpgradeable(address(vault)).owner() != msg.sender) revert FlatcoinErrors.OnlyOwner(msg.sender);
        _;
    }

    /// @notice Setter for the vault contract.
    /// @dev Can be used in case FlatcoinVault ever changes.
    function setVault(IFlatcoinVault _vault) external onlyOwner {
        if (address(_vault) == address(0)) revert FlatcoinErrors.ZeroAddress("vault");

        vault = _vault;
    }

    /// @dev Function to initialize a module.
    /// @param _moduleKey The bytes32 encoded key of the module.
    /// @param _vault FlatcoinVault contract address.
    // solhint-disable-next-line func-name-mixedcase
    function __Module_init(bytes32 _moduleKey, IFlatcoinVault _vault) internal {
        if (_moduleKey == bytes32("")) revert FlatcoinErrors.ModuleKeyEmpty();
        if (address(_vault) == address(0)) revert FlatcoinErrors.ZeroAddress("vault");

        MODULE_KEY = _moduleKey;
        vault = _vault;
    }

    uint256[48] private __gap;
}

// src/misc/InvariantChecks.sol

/// @title InvariantChecks
/// @author dHEDGE
/// @notice Contract module for critical invariant checking on the protocol.
abstract contract InvariantChecks {
    struct InvariantOrder {
        int256 collateralNet;
        uint256 stableCollateralPerShare;
    }

    struct InvariantLiquidation {
        int256 collateralNet;
        uint256 stableCollateralPerShare;
        int256 remainingMargin;
        uint256 liquidationFee;
    }

    /// @notice Invariant checks on order execution
    /// @dev Checks:
    ///      1. Collateral net: The vault collateral balance relative to tracked collateral on both stable LP and leverage side should not change
    ///      2. Stable collateral per share: Stable LP value per share should never decrease after order execution. It should only increase due to collected trading fees
    modifier orderInvariantChecks(IFlatcoinVault vault) {
        IStableModule stableModule = IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY));

        InvariantOrder memory invariantBefore = InvariantOrder({ // helps with stack too deep
            collateralNet: _getCollateralNet(vault),
            stableCollateralPerShare: stableModule.stableCollateralPerShare()
        });

        _;

        InvariantOrder memory invariantAfter = InvariantOrder({
            collateralNet: _getCollateralNet(vault),
            stableCollateralPerShare: stableModule.stableCollateralPerShare()
        });

        _collateralNetBalanceRemainsUnchanged(invariantBefore.collateralNet, invariantAfter.collateralNet);
        _stableCollateralPerShareIncreasesOrRemainsUnchanged(
            stableModule.totalSupply(),
            invariantBefore.stableCollateralPerShare,
            invariantAfter.stableCollateralPerShare
        );
        _globalAveragePriceIsNotNegative(vault);
    }

    /// @notice Invariant checks on order liquidation
    /// @dev For liquidations, stableCollateralPerShare can decrease if the position is underwater.
    modifier liquidationInvariantChecks(IFlatcoinVault vault, uint256 tokenId) {
        IStableModule stableModule = IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY));

        InvariantLiquidation memory invariantBefore = InvariantLiquidation({ // helps with stack too deep
            collateralNet: _getCollateralNet(vault),
            stableCollateralPerShare: stableModule.stableCollateralPerShare(),
            remainingMargin: ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY))
                .getPositionSummary(tokenId)
                .marginAfterSettlement,
            liquidationFee: ILiquidationModule(vault.moduleAddress(FlatcoinModuleKeys._LIQUIDATION_MODULE_KEY))
                .getLiquidationFee(tokenId)
        });

        _;

        InvariantLiquidation memory invariantAfter = InvariantLiquidation({
            collateralNet: _getCollateralNet(vault),
            stableCollateralPerShare: stableModule.stableCollateralPerShare(),
            remainingMargin: 0, // not used
            liquidationFee: 0 // not used
        });

        _stableCollateralPerShareLiquidation(
            stableModule,
            invariantBefore.liquidationFee,
            invariantBefore.remainingMargin,
            invariantBefore.stableCollateralPerShare,
            invariantAfter.stableCollateralPerShare
        );

        _collateralNetBalanceRemainsUnchanged(invariantBefore.collateralNet, invariantAfter.collateralNet);
        _globalAveragePriceIsNotNegative(vault);
    }

    /// @dev Returns the difference between actual total collateral balance in the vault vs tracked collateral
    ///      Tracked collateral should be updated when depositing to stable LP (stableCollateralTotal) or
    ///      opening leveraged positions (marginDepositedTotal).
    function _getCollateralNet(IFlatcoinVault vault) private view returns (int256 netCollateral) {
        int256 collateralBalance = int256(vault.collateral().balanceOf(address(vault)));
        int256 trackedCollateral = int256(vault.stableCollateralTotal()) +
            vault.getGlobalPositions().marginDepositedTotal;

        if (collateralBalance < trackedCollateral) revert FlatcoinErrors.InvariantViolation("collateralNet1");

        return collateralBalance - trackedCollateral;
    }

    function _globalAveragePriceIsNotNegative(IFlatcoinVault vault) private view {
        if (vault.getGlobalPositions().averagePrice < 0)
            revert FlatcoinErrors.InvariantViolation("globalAveragePriceIsNotNegative");
    }

    /// @dev Collateral balance changes should match tracked collateral changes
    function _collateralNetBalanceRemainsUnchanged(int256 netBefore, int256 netAfter) private pure {
        // Note: +1e6 to account for rounding errors.
        // This means we are ok with a small margin of error such that netAfter - 1e6 <= netBefore <= netAfter.
        if (netBefore > netAfter || netAfter > netBefore + 1e6)
            revert FlatcoinErrors.InvariantViolation("collateralNet2");
    }

    /// @dev Stable LPs should never lose value (can only gain on trading fees)
    function _stableCollateralPerShareIncreasesOrRemainsUnchanged(
        uint256 totalSupply,
        uint256 collateralPerShareBefore,
        uint256 collateralPerShareAfter
    ) private pure {
        // Note: +1 to account for rounding error
        if (totalSupply > 0 && collateralPerShareAfter + 1 < collateralPerShareBefore)
            revert FlatcoinErrors.InvariantViolation("stableCollateralPerShare");
    }

    /// @dev Stable LPs should be adjusted according to the liquidated position remaining margin and liquidation fee
    function _stableCollateralPerShareLiquidation(
        IStableModule stableModule,
        uint256 liquidationFee,
        int256 remainingMargin,
        uint256 stableCollateralPerShareBefore,
        uint256 stableCollateralPerShareAfter
    ) private view {
        uint256 totalSupply = stableModule.totalSupply();

        if (totalSupply == 0) return;

        int256 expectedStableCollateralPerShare;
        if (remainingMargin > 0) {
            if (remainingMargin > int256(liquidationFee)) {
                // position is healthy and there is a keeper fee taken from the margin
                // evaluate exact increase in stable collateral
                expectedStableCollateralPerShare =
                    int256(stableCollateralPerShareBefore) +
                    (((remainingMargin - int256(liquidationFee)) * 1e18) / int256(stableModule.totalSupply()));
            } else {
                // position has less or equal margin than liquidation fee
                // all the margin will go to the keeper and no change in stable collateral
                if (stableCollateralPerShareBefore != stableCollateralPerShareAfter)
                    revert FlatcoinErrors.InvariantViolation("stableCollateralPerShareLiquidation");

                return;
            }
        } else {
            // position is underwater and there is no keeper fee
            // evaluate exact decrease in stable collateral
            expectedStableCollateralPerShare =
                int256(stableCollateralPerShareBefore) +
                ((remainingMargin * 1e18) / int256(stableModule.totalSupply())); // underwater margin per share
        }
        if (
            expectedStableCollateralPerShare + 1e6 < int256(stableCollateralPerShareAfter) || // rounding error
            expectedStableCollateralPerShare - 1e6 > int256(stableCollateralPerShareAfter)
        ) revert FlatcoinErrors.InvariantViolation("stableCollateralPerShareLiquidation");
    }
}

// src/DelayedOrder.sol

/// @title DelayedOrder
/// @author dHEDGE
/// @notice Contains functions to announce and execute delayed orders.
contract DelayedOrder is
    IDelayedOrder,
    ModuleUpgradeable,
    ReentrancyGuardUpgradeable,
    InvariantChecks,
    OracleModifiers
{
    using SafeERC20 for IERC20;
    using SafeERC20 for IStableModule;
    using SignedMath for int256;

    /// @notice Minimum deposit amount for stable LP collateral.
    uint256 public constant MIN_DEPOSIT = 1e6;

    /// @dev Mapping containing all the orders in an encoded format.
    mapping(address account => FlatcoinStructs.Order order) private _announcedOrder;

    /// @dev To prevent the implementation contract from being used, we invoke the _disableInitializers
    ///      function in the constructor to automatically lock it when it is deployed.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Function to initialize this contract.
    function initialize(IFlatcoinVault _vault) external initializer {
        __Module_init(FlatcoinModuleKeys._DELAYED_ORDER_KEY, _vault);
        __ReentrancyGuard_init();
    }

    /////////////////////////////////////////////
    //         Announcement Functions          //
    /////////////////////////////////////////////

    /// @notice Announces deposit intent for keepers to execute at offchain oracle price.
    /// @dev The deposit amount is taken plus the keeper fee.
    /// @param depositAmount The amount of collateral to deposit.
    /// @param minAmountOut The minimum amount of tokens the user expects to receive back.
    /// @param keeperFee The fee the user is paying for keeper transaction execution (in collateral tokens).
    function announceStableDeposit(
        uint256 depositAmount,
        uint256 minAmountOut,
        uint256 keeperFee
    ) external whenNotPaused {
        uint64 executableAtTime = _prepareAnnouncementOrder(keeperFee);

        vault.checkCollateralCap(depositAmount);

        if (depositAmount < MIN_DEPOSIT)
            revert FlatcoinErrors.AmountTooSmall({amount: depositAmount, minAmount: MIN_DEPOSIT});

        // Check that the requested minAmountOut is feasible
        uint256 quotedAmount = IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY))
            .stableDepositQuote(depositAmount);

        if (quotedAmount < minAmountOut) revert FlatcoinErrors.HighSlippage(quotedAmount, minAmountOut);

        _announcedOrder[msg.sender] = FlatcoinStructs.Order({
            orderType: FlatcoinStructs.OrderType.StableDeposit,
            orderData: abi.encode(
                FlatcoinStructs.AnnouncedStableDeposit({depositAmount: depositAmount, minAmountOut: minAmountOut})
            ),
            keeperFee: keeperFee,
            executableAtTime: executableAtTime
        });

        // Sends collateral to the delayed order contract first before it is settled by keepers and sent to the vault
        vault.collateral().safeTransferFrom(msg.sender, address(this), depositAmount + keeperFee);

        emit FlatcoinEvents.OrderAnnounced({
            account: msg.sender,
            orderType: FlatcoinStructs.OrderType.StableDeposit,
            keeperFee: keeperFee
        });
    }

    /// @notice Announces withdrawal intent for keepers to execute at offchain oracle price.
    /// @dev The deposit amount is taken plus the keeper fee, also in LP tokens.
    /// @param withdrawAmount The amount to withdraw in stable LP tokens.
    /// @param minAmountOut The minimum amount of underlying asset tokens the user expects to receive back.
    /// @param keeperFee The fee the user is paying for keeper transaction execution (in stable LP tokens).
    function announceStableWithdraw(
        uint256 withdrawAmount,
        uint256 minAmountOut,
        uint256 keeperFee
    ) external whenNotPaused {
        uint64 executableAtTime = _prepareAnnouncementOrder(keeperFee);

        IStableModule stableModule = IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY));
        uint256 lpBalance = IERC20(stableModule).balanceOf(msg.sender);

        if (lpBalance < withdrawAmount)
            revert FlatcoinErrors.NotEnoughBalanceForWithdraw(msg.sender, lpBalance, withdrawAmount);

        // Check that the requested minAmountOut is feasible
        {
            uint256 expectedAmountOut = stableModule.stableWithdrawQuote(withdrawAmount);

            vault.checkSkewMax({sizeChange: 0, stableCollateralChange: -int256(expectedAmountOut)});

            if (keeperFee > expectedAmountOut) revert FlatcoinErrors.WithdrawalTooSmall(expectedAmountOut, keeperFee);

            expectedAmountOut -= keeperFee;

            if (expectedAmountOut < minAmountOut) revert FlatcoinErrors.HighSlippage(expectedAmountOut, minAmountOut);
        }

        _announcedOrder[msg.sender] = FlatcoinStructs.Order({
            orderType: FlatcoinStructs.OrderType.StableWithdraw,
            orderData: abi.encode(
                FlatcoinStructs.AnnouncedStableWithdraw({withdrawAmount: withdrawAmount, minAmountOut: minAmountOut})
            ),
            keeperFee: keeperFee,
            executableAtTime: executableAtTime
        });

        // Lock the LP tokens belonging to this position so that it can't be transferred to someone else.
        // Locking doesn't require an approval from an account.
        stableModule.lock({account: msg.sender, amount: withdrawAmount});

        emit FlatcoinEvents.OrderAnnounced({
            account: msg.sender,
            orderType: FlatcoinStructs.OrderType.StableWithdraw,
            keeperFee: keeperFee
        });
    }

    /// @notice Announces leverage open intent for keepers to execute at offchain oracle price.
    /// @param margin The amount of collateral to deposit.
    /// @param additionalSize The amount of additional size to open.
    /// @param maxFillPrice The maximum price at which the trade can be executed.
    /// @param keeperFee The fee the user is paying for keeper transaction execution (in collateral tokens).
    function announceLeverageOpen(
        uint256 margin,
        uint256 additionalSize,
        uint256 maxFillPrice,
        uint256 keeperFee
    ) external whenNotPaused {
        ILeverageModule leverageModule = ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY));

        uint64 executableAtTime = _prepareAnnouncementOrder(keeperFee);

        uint256 tradeFee = leverageModule.getTradeFee(additionalSize);

        vault.checkSkewMax({sizeChange: additionalSize, stableCollateralChange: int256(tradeFee)});

        leverageModule.checkLeverageCriteria(margin, additionalSize);

        (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice();

        if (maxFillPrice < currentPrice) revert FlatcoinErrors.MaxFillPriceTooLow(maxFillPrice, currentPrice);

        if (
            ILiquidationModule(vault.moduleAddress(FlatcoinModuleKeys._LIQUIDATION_MODULE_KEY)).getLiquidationMargin(
                additionalSize,
                maxFillPrice
            ) >= margin
        ) revert FlatcoinErrors.PositionCreatesBadDebt();

        _announcedOrder[msg.sender] = FlatcoinStructs.Order({
            orderType: FlatcoinStructs.OrderType.LeverageOpen,
            orderData: abi.encode(
                FlatcoinStructs.AnnouncedLeverageOpen({
                    margin: margin,
                    additionalSize: additionalSize,
                    maxFillPrice: maxFillPrice,
                    tradeFee: tradeFee
                })
            ),
            keeperFee: keeperFee,
            executableAtTime: executableAtTime
        });

        // Sends collateral to the delayed order contract first before it is settled by keepers and sent to the vault
        vault.collateral().safeTransferFrom(msg.sender, address(this), margin + keeperFee + tradeFee);

        emit FlatcoinEvents.OrderAnnounced({
            account: msg.sender,
            orderType: FlatcoinStructs.OrderType.LeverageOpen,
            keeperFee: keeperFee
        });
    }

    /// @notice Announces leverage adjust intent for keepers to execute at offchain oracle price.
    /// @param tokenId The ERC721 token ID of the position.
    /// @param marginAdjustment The amount of margin to deposit or withdraw.
    /// @param additionalSizeAdjustment The amount of additional size to increase or decrease.
    /// @param fillPrice The price at which the trade can be executed.
    /// @param keeperFee The fee the user is paying for keeper transaction execution (in collateral tokens).
    function announceLeverageAdjust(
        uint256 tokenId,
        int256 marginAdjustment,
        int256 additionalSizeAdjustment,
        uint256 fillPrice,
        uint256 keeperFee
    ) external whenNotPaused {
        uint64 executableAtTime = _prepareAnnouncementOrder(keeperFee);

        // If both adjustable parameters are zero, there is nothing to adjust
        if (marginAdjustment == 0 && additionalSizeAdjustment == 0)
            revert FlatcoinErrors.ZeroValue("marginAdjustment|additionalSizeAdjustment");

        ILeverageModule leverageModule = ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY));

        // Check that the caller is the owner of the token
        if (leverageModule.ownerOf(tokenId) != msg.sender) revert FlatcoinErrors.NotTokenOwner(tokenId, msg.sender);

        // Trade fee is calculated based on additional size change
        uint256 totalFee;
        {
            uint256 tradeFee;
            (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY))
                .getPrice();

            // Means increasing or decreasing additional size
            if (additionalSizeAdjustment >= 0) {
                // If additionalSizeAdjustment equals zero, trade fee is zero as well
                tradeFee = leverageModule.getTradeFee(uint256(additionalSizeAdjustment));
                vault.checkSkewMax({
                    sizeChange: uint256(additionalSizeAdjustment),
                    stableCollateralChange: int256(tradeFee)
                });

                if (fillPrice < currentPrice) revert FlatcoinErrors.MaxFillPriceTooLow(fillPrice, currentPrice);
            } else {
                tradeFee = leverageModule.getTradeFee(uint256(additionalSizeAdjustment * -1));

                if (fillPrice > currentPrice) revert FlatcoinErrors.MinFillPriceTooHigh(fillPrice, currentPrice);
            }

            totalFee = tradeFee + keeperFee;
        }

        {
            // New additional size will be either bigger or smaller than current additional size
            // depends on if additionalSizeAdjustment is positive or negative.
            int256 newAdditionalSize = int256(vault.getPosition(tokenId).additionalSize) + additionalSizeAdjustment;

            // If user withdraws margin or changes additional size with no changes to margin, fees are charged from their existing margin.
            int256 newMarginAfterSettlement = leverageModule.getPositionSummary(tokenId).marginAfterSettlement +
                ((marginAdjustment > 0) ? marginAdjustment : marginAdjustment - int256(totalFee));

            // New margin or size can't be negative, which means that they want to withdraw more than they deposited or not enough to pay the fees
            if (newMarginAfterSettlement < 0 || newAdditionalSize < 0)
                revert FlatcoinErrors.ValueNotPositive("newMarginAfterSettlement|newAdditionalSize");

            if (
                ILiquidationModule(vault.moduleAddress(FlatcoinModuleKeys._LIQUIDATION_MODULE_KEY))
                    .getLiquidationMargin(uint256(newAdditionalSize), fillPrice) >= uint256(newMarginAfterSettlement)
            ) revert FlatcoinErrors.PositionCreatesBadDebt();

            // New values can't be less than min margin and min/max leverage requirements.
            leverageModule.checkLeverageCriteria(uint256(newMarginAfterSettlement), uint256(newAdditionalSize));
        }

        _announcedOrder[msg.sender] = FlatcoinStructs.Order({
            orderType: FlatcoinStructs.OrderType.LeverageAdjust,
            orderData: abi.encode(
                FlatcoinStructs.AnnouncedLeverageAdjust({
                    tokenId: tokenId,
                    marginAdjustment: marginAdjustment,
                    additionalSizeAdjustment: additionalSizeAdjustment,
                    fillPrice: fillPrice,
                    tradeFee: totalFee - keeperFee,
                    totalFee: totalFee
                })
            ),
            keeperFee: keeperFee,
            executableAtTime: executableAtTime
        });

        // Lock the NFT belonging to this position so that it can't be transferred to someone else.
        // Locking doesn't require an approval from the leverage trader.
        leverageModule.lock(tokenId, FlatcoinModuleKeys._DELAYED_ORDER_KEY);

        // If user increases margin, fees are charged from their account.
        if (marginAdjustment > 0) {
            // Sending positive margin adjustment and both fees from the user to the delayed order contract.
            vault.collateral().safeTransferFrom(msg.sender, address(this), uint256(marginAdjustment) + totalFee);
        }

        emit FlatcoinEvents.OrderAnnounced({
            account: msg.sender,
            orderType: FlatcoinStructs.OrderType.LeverageAdjust,
            keeperFee: keeperFee
        });
    }

    /// @notice Announces leverage close intent for keepers to execute at offchain oracle price.
    /// @param tokenId The ERC721 token ID of the position.
    /// @param minFillPrice The minimum price at which the trade can be executed.
    /// @param keeperFee The fee the user is paying for keeper transaction execution (in collateral tokens).
    function announceLeverageClose(uint256 tokenId, uint256 minFillPrice, uint256 keeperFee) external whenNotPaused {
        uint64 executableAtTime = _prepareAnnouncementOrder(keeperFee);
        uint256 tradeFee;

        ILeverageModule leverageModule = ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY));

        // Check that the caller of this function is actually the owner of the token ID.
        // Since `lock` function in leverage module doesn't check for this, we need to do it here.
        if (leverageModule.ownerOf(tokenId) != msg.sender) revert FlatcoinErrors.NotTokenOwner(tokenId, msg.sender);

        {
            uint256 size = vault.getPosition(tokenId).additionalSize;

            // Position needs additional margin to cover the trading fee on closing the position
            tradeFee = leverageModule.getTradeFee(size);

            // Make sure there is enough margin in the position to pay the keeper fee and trading fee
            // This should always pass because the position should get liquidated before the margin becomes too small
            int256 settledMargin = leverageModule.getPositionSummary(tokenId).marginAfterSettlement;

            uint256 totalFee = tradeFee + keeperFee;
            if (settledMargin < int256(totalFee)) revert FlatcoinErrors.NotEnoughMarginForFees(settledMargin, totalFee);

            (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY))
                .getPrice();

            if (minFillPrice > currentPrice) revert FlatcoinErrors.MinFillPriceTooHigh(minFillPrice, currentPrice);
        }

        _announcedOrder[msg.sender] = FlatcoinStructs.Order({
            orderType: FlatcoinStructs.OrderType.LeverageClose,
            orderData: abi.encode(
                FlatcoinStructs.AnnouncedLeverageClose({
                    tokenId: tokenId,
                    minFillPrice: minFillPrice,
                    tradeFee: tradeFee
                })
            ),
            keeperFee: keeperFee,
            executableAtTime: executableAtTime
        });

        // Lock the NFT belonging to this position so that it can't be transferred to someone else.
        // Locking doesn't require an approval from the leverage trader.
        leverageModule.lock(tokenId, FlatcoinModuleKeys._DELAYED_ORDER_KEY);

        emit FlatcoinEvents.OrderAnnounced({
            account: msg.sender,
            orderType: FlatcoinStructs.OrderType.LeverageClose,
            keeperFee: keeperFee
        });
    }

    /////////////////////////////////////////////
    //           Execution Functions           //
    /////////////////////////////////////////////

    /// @notice Executes any valid pending order for an account.
    /// @dev Uses the Pyth network price to execute.
    /// @param account The user account which has a pending deposit.
    /// @param priceUpdateData The Pyth network offchain price oracle update data.
    function executeOrder(
        address account,
        bytes[] calldata priceUpdateData
    )
        external
        payable
        nonReentrant
        whenNotPaused
        updatePythPrice(vault, msg.sender, priceUpdateData)
        orderInvariantChecks(vault)
    {
        FlatcoinStructs.OrderType orderType = _announcedOrder[account].orderType;

        // If there is no order in store, just return.
        if (orderType == FlatcoinStructs.OrderType.None) return;

        // Settle funding fees before executing any order.
        // This is to avoid error related to max caps or max skew reached when the market has been skewed to one side for a long time.
        // This is more important in case the we allow for limit orders in the future.
        vault.settleFundingFees();

        if (orderType == FlatcoinStructs.OrderType.StableDeposit) {
            _executeStableDeposit(account);
        } else if (orderType == FlatcoinStructs.OrderType.StableWithdraw) {
            _executeStableWithdraw(account);
        } else if (orderType == FlatcoinStructs.OrderType.LeverageOpen) {
            _executeLeverageOpen(account);
        } else if (orderType == FlatcoinStructs.OrderType.LeverageClose) {
            _executeLeverageClose(account);
        } else if (orderType == FlatcoinStructs.OrderType.LeverageAdjust) {
            _executeLeverageAdjust(account);
        }
    }

    /// @notice Function to cancel an existing order after it has expired.
    /// @dev This function can be called by anyone.
    /// @param account The user account which has a pending order.
    function cancelExistingOrder(address account) public {
        FlatcoinStructs.Order memory order = _announcedOrder[account];

        // If there is no order in store, just return.
        if (order.orderType == FlatcoinStructs.OrderType.None) return;

        if (block.timestamp <= order.executableAtTime + vault.maxExecutabilityAge())
            revert FlatcoinErrors.OrderHasNotExpired();

        // Delete the order tracker from storage.
        // NOTE: This is done before the transfer of ERC721 NFT to prevent reentrancy attacks.
        delete _announcedOrder[account];

        if (order.orderType == FlatcoinStructs.OrderType.StableDeposit) {
            FlatcoinStructs.AnnouncedStableDeposit memory stableDeposit = abi.decode(
                order.orderData,
                (FlatcoinStructs.AnnouncedStableDeposit)
            );

            // Send collateral back to trader
            vault.collateral().safeTransfer({to: account, value: stableDeposit.depositAmount + order.keeperFee});
        } else if (order.orderType == FlatcoinStructs.OrderType.StableWithdraw) {
            FlatcoinStructs.AnnouncedStableWithdraw memory stableWithdraw = abi.decode(
                order.orderData,
                (FlatcoinStructs.AnnouncedStableWithdraw)
            );

            // Unlock the LP tokens belonging to this position which were locked during announcement.
            IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY)).unlock({
                account: account,
                amount: stableWithdraw.withdrawAmount
            });
        } else if (order.orderType == FlatcoinStructs.OrderType.LeverageOpen) {
            FlatcoinStructs.AnnouncedLeverageOpen memory leverageOpen = abi.decode(
                order.orderData,
                (FlatcoinStructs.AnnouncedLeverageOpen)
            );

            // Send collateral back to trader
            vault.collateral().safeTransfer({
                to: account,
                value: order.keeperFee + leverageOpen.margin + leverageOpen.tradeFee
            });
        } else if (order.orderType == FlatcoinStructs.OrderType.LeverageClose) {
            FlatcoinStructs.AnnouncedLeverageClose memory leverageClose = abi.decode(
                order.orderData,
                (FlatcoinStructs.AnnouncedLeverageClose)
            );

            // Unlock the ERC721 position NFT to allow for transfers.
            ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY)).unlock(
                leverageClose.tokenId,
                FlatcoinModuleKeys._DELAYED_ORDER_KEY
            );
        } else if (order.orderType == FlatcoinStructs.OrderType.LeverageAdjust) {
            FlatcoinStructs.AnnouncedLeverageAdjust memory leverageAdjust = abi.decode(
                order.orderData,
                (FlatcoinStructs.AnnouncedLeverageAdjust)
            );

            if (leverageAdjust.marginAdjustment > 0) {
                vault.collateral().safeTransfer({
                    to: account,
                    value: uint256(leverageAdjust.marginAdjustment) + leverageAdjust.totalFee
                });
            }

            // Unlock the ERC721 position NFT to allow for transfers.
            ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY)).unlock(
                leverageAdjust.tokenId,
                FlatcoinModuleKeys._DELAYED_ORDER_KEY
            );
        }

        emit FlatcoinEvents.OrderCancelled({account: account, orderType: order.orderType});
    }

    /////////////////////////////////////////////
    //       Internal Execution Functions      //
    /////////////////////////////////////////////

    /// @notice User delayed deposit into the stable LP. Mints ERC20 token receipt.
    /// @dev Uses the Pyth network price to execute.
    /// @param account The user account which has a pending deposit.
    /// @return liquidityMinted The amount of stable LP tokens the user receives.
    function _executeStableDeposit(address account) internal returns (uint256 liquidityMinted) {
        FlatcoinStructs.Order memory order = _announcedOrder[account];

        FlatcoinStructs.AnnouncedStableDeposit memory stableDeposit = abi.decode(
            order.orderData,
            (FlatcoinStructs.AnnouncedStableDeposit)
        );

        vault.checkCollateralCap(stableDeposit.depositAmount);

        _prepareExecutionOrder(account, order.executableAtTime);

        liquidityMinted = IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY)).executeDeposit(
            account,
            order.executableAtTime,
            stableDeposit
        );

        // Settle the collateral
        vault.collateral().safeTransfer({to: msg.sender, value: order.keeperFee}); // pay the keeper their fee
        vault.collateral().safeTransfer({to: address(vault), value: stableDeposit.depositAmount}); // transfer collateral to the vault

        emit FlatcoinEvents.OrderExecuted({account: account, orderType: order.orderType, keeperFee: order.keeperFee});
    }

    /// @notice User delayed withdrawal from the stable LP.
    /// @dev Uses the Pyth network price to execute.
    /// @param account The user account which has a pending withdrawal.
    /// @return amountOut The amount of collateral asset tokens the user receives.
    function _executeStableWithdraw(address account) internal returns (uint256 amountOut) {
        FlatcoinStructs.Order memory order = _announcedOrder[account];

        _prepareExecutionOrder(account, order.executableAtTime);

        FlatcoinStructs.AnnouncedStableWithdraw memory stableWithdraw = abi.decode(
            order.orderData,
            (FlatcoinStructs.AnnouncedStableWithdraw)
        );

        uint256 withdrawFee;

        (amountOut, withdrawFee) = IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY))
            .executeWithdraw(account, order.executableAtTime, stableWithdraw);

        uint256 totalFee = order.keeperFee + withdrawFee;

        // Make sure there is enough margin in the position to pay the keeper fee and withdrawal fee
        if (amountOut < totalFee) revert FlatcoinErrors.NotEnoughMarginForFees(int256(amountOut), totalFee);

        // include the fees here to check for slippage
        amountOut -= totalFee;

        if (amountOut < stableWithdraw.minAmountOut)
            revert FlatcoinErrors.HighSlippage(amountOut, stableWithdraw.minAmountOut);

        // Settle the collateral
        vault.updateStableCollateralTotal(int256(withdrawFee)); // pay the withdrawal fee to stable LPs
        vault.sendCollateral({to: msg.sender, amount: order.keeperFee}); // pay the keeper their fee
        vault.sendCollateral({to: account, amount: amountOut}); // transfer remaining amount to the trader

        emit FlatcoinEvents.OrderExecuted({account: account, orderType: order.orderType, keeperFee: order.keeperFee});
    }

    /// @notice Execution of user delayed leverage open order. Mints ERC721 token receipt.
    /// @dev Uses the Pyth network price to execute.
    /// @param account The user account which has a pending order.
    /// @return tokenId The ERC721 token ID of the position.
    function _executeLeverageOpen(address account) internal returns (uint256 tokenId) {
        FlatcoinStructs.Order memory order = _announcedOrder[account];
        FlatcoinStructs.AnnouncedLeverageOpen memory announcedOpen = abi.decode(
            order.orderData,
            (FlatcoinStructs.AnnouncedLeverageOpen)
        );

        _prepareExecutionOrder(account, order.executableAtTime);

        vault.collateral().safeTransfer({
            to: address(vault),
            value: announcedOpen.margin + announcedOpen.tradeFee + order.keeperFee
        }); // transfer collateral + fees to the vault

        tokenId = ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY)).executeOpen({
            account: account,
            keeper: msg.sender,
            order: order
        });

        emit FlatcoinEvents.OrderExecuted({account: account, orderType: order.orderType, keeperFee: order.keeperFee});
    }

    /// @notice Execution of user delayed leverage adjust order.
    /// @dev Uses the Pyth network price to execute.
    /// @param account The user account which has a pending order.
    function _executeLeverageAdjust(address account) internal {
        FlatcoinStructs.Order memory order = _announcedOrder[account];
        FlatcoinStructs.AnnouncedLeverageAdjust memory leverageAdjust = abi.decode(
            order.orderData,
            (FlatcoinStructs.AnnouncedLeverageAdjust)
        );

        ILeverageModule leverageModule = ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY));

        // Check that position exists (ownerOf reverts if owner is null address)
        // There is a possibility that position was deleted by liquidation or limit order module
        leverageModule.ownerOf(leverageAdjust.tokenId);

        _prepareExecutionOrder(account, order.executableAtTime);

        ILimitOrder(vault.moduleAddress(FlatcoinModuleKeys._LIMIT_ORDER_KEY)).resetExecutionTime(
            leverageAdjust.tokenId
        );

        if (leverageAdjust.marginAdjustment > 0) {
            // Sending positive margin adjustment and fees from delayed order contract to the vault
            vault.collateral().safeTransfer({
                to: address(vault),
                value: uint256(leverageAdjust.marginAdjustment) + leverageAdjust.tradeFee + order.keeperFee
            });
        }

        // Since the lock was set in the `announceLeverageAdjust`, we need to unlock it here.
        leverageModule.unlock(leverageAdjust.tokenId, FlatcoinModuleKeys._DELAYED_ORDER_KEY);

        leverageModule.executeAdjust({account: account, keeper: msg.sender, order: order});

        emit FlatcoinEvents.OrderExecuted({account: account, orderType: order.orderType, keeperFee: order.keeperFee});
    }

    /// @notice Execution of user delayed leverage close order. Burns ERC721 token receipt.
    /// @dev Uses the Pyth network price to execute.
    /// @param account The user account which has a pending order.
    /// @return settledMargin The amount of margin settled from the position.
    function _executeLeverageClose(address account) internal returns (int256 settledMargin) {
        FlatcoinStructs.Order memory order = _announcedOrder[account];
        FlatcoinStructs.AnnouncedLeverageClose memory leverageClose = abi.decode(
            order.orderData,
            (FlatcoinStructs.AnnouncedLeverageClose)
        );

        ILeverageModule leverageModule = ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY));

        // Check that position exists (ownerOf reverts if owner is null address)
        // There is a possibility that position was deleted by liquidation or limit order module
        leverageModule.ownerOf(leverageClose.tokenId);

        _prepareExecutionOrder(account, order.executableAtTime);

        settledMargin = leverageModule.executeClose({account: account, keeper: msg.sender, order: order});

        emit FlatcoinEvents.OrderExecuted({account: account, orderType: order.orderType, keeperFee: order.keeperFee});
    }

    /// @dev This function HAS to be called as soon as the transaction flow enters an announce function.
    function _prepareAnnouncementOrder(uint256 keeperFee) internal returns (uint64 executableAtTime) {
        // Settle funding fees to not encounter the `MaxSkewReached` error.
        // This error could happen if the funding fees are not settled for a long time and the market is skewed long
        // for a long time.
        vault.settleFundingFees();

        if (keeperFee < IKeeperFee(vault.moduleAddress(FlatcoinModuleKeys._KEEPER_FEE_MODULE_KEY)).getKeeperFee())
            revert FlatcoinErrors.InvalidFee(keeperFee);

        // If the user has an existing pending order that expired, then cancel it.
        cancelExistingOrder(msg.sender);

        executableAtTime = uint64(block.timestamp + vault.minExecutabilityAge());
    }

    /// @dev This function HAS to be called as soon as the transaction flow enters an execute function.
    function _prepareExecutionOrder(address account, uint256 executableAtTime) internal {
        if (block.timestamp > executableAtTime + vault.maxExecutabilityAge()) revert FlatcoinErrors.OrderHasExpired();

        // Check that the minimum time delay is reached before execution
        if (block.timestamp < executableAtTime) revert FlatcoinErrors.ExecutableTimeNotReached(executableAtTime);

        // Delete the order tracker from storage.
        delete _announcedOrder[account];
    }

    /////////////////////////////////////////////
    //             View Functions              //
    /////////////////////////////////////////////

    /// @notice Getter for the announced order of an account
    /// @param account The user account which has a pending order
    /// @return order The order struct
    function getAnnouncedOrder(address account) external view returns (FlatcoinStructs.Order memory order) {
        return _announcedOrder[account];
    }

    /// @notice Checks whether a user announced order has expired executability time or not
    /// @param account The user account which has a pending order
    /// @return expired True if the order has expired, false otherwise
    function hasOrderExpired(address account) public view returns (bool expired) {
        uint256 executableAtTime = _announcedOrder[account].executableAtTime;

        if (executableAtTime <= 0) revert FlatcoinErrors.ZeroValue("executableAtTime");

        expired = (executableAtTime + vault.maxExecutabilityAge() >= block.timestamp) ? false : true;
    }
}
