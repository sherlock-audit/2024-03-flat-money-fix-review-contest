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

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
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

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
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

// src/interfaces/IPointsModule.sol

interface IPointsModule {
    struct MintPoints {
        address to;
        uint256 amount;
    }

    function getUnlockTax(address account) external view returns (uint256 unlockTax);

    function lockedBalance(address account) external view returns (uint256 amount);

    function mintDeposit(address to, uint256 depositAmount) external;

    function mintLeverageOpen(address to, uint256 size) external;

    function mintTo(MintPoints memory _mintPoints) external;

    function mintToMultiple(MintPoints[] memory _mintPoints) external;

    function pointsPerDeposit() external view returns (uint256 depositPoints);

    function pointsPerSize() external view returns (uint256 sizePoints);

    function setPointsVest(uint256 _unlockTaxVest, uint256 _pointsPerSize, uint256 _pointsPerDeposit) external;

    function setTreasury(address _treasury) external;

    function treasury() external view returns (address treasury);

    function unlock(uint256 amount) external;

    function unlockAll() external;

    function unlockTaxVest() external view returns (uint256 unlockTaxVest);

    function unlockTime(address account) external view returns (uint256 unlockTime);
}

// src/libraries/DecimalMath.sol

/// @title DecimalMath
/// @author dHEDGE
/// @author Adapted from Synthetix <https://github.com/Synthetixio/synthetix/blob/cbd8666f4331ee95fcc667ec7345d13c8ba77efb/contracts/SignedSafeDecimalMath.sol>
///         and  <https://github.com/Synthetixio/synthetix/blob/cbd8666f4331ee95fcc667ec7345d13c8ba77efb/contracts/SafeDecimalMath.sol>
/// @notice Library for fixed point math.
// TODO: Explore if Solmate FixedPointMathLib can be used instead. <https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol>
// solhint-disable gas-named-return-values
library DecimalMath {
    /* Number of decimal places in the representations. */
    uint8 public constant DECIMALS = 18;
    uint8 public constant HIGH_PRECISION_DECIMALS = 27;

    /* The number representing 1.0. */
    int256 public constant UNIT = 1e18;

    /* The number representing 1.0 for higher fidelity numbers. */
    int256 public constant PRECISE_UNIT = int256(10 ** uint256(HIGH_PRECISION_DECIMALS));
    int256 private constant _UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR =
        int256(10 ** uint256(HIGH_PRECISION_DECIMALS - DECIMALS));

    /**
     * @return The result of multiplying x and y, interpreting the operands as fixed-point
     * decimals.
     *
     * @dev A unit factor is divided out after the product of x and y is evaluated,
     * so that product must be less than 2**256. As this is an integer division,
     * the internal division always rounds down. This helps save on gas. Rounding
     * is more expensive on gas.
     */
    function _multiplyDecimal(int256 x, int256 y) internal pure returns (int256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return (x * y) / UNIT;
    }

    /**
     * @return The result of multiplying x and y, interpreting the operands as fixed-point
     * decimals.
     *
     * @dev A unit factor is divided out after the product of x and y is evaluated,
     * so that product must be less than 2**256. As this is an integer division,
     * the internal division always rounds down. This helps save on gas. Rounding
     * is more expensive on gas.
     */
    function _multiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return (x * y) / uint256(UNIT);
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a precise unit.
     *
     * @dev The operands should be in the precise unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRoundPrecise(int256 x, int256 y) internal pure returns (int256) {
        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a precise unit.
     *
     * @dev The operands should be in the precise unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRoundPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        return _multiplyDecimalRound(x, y, uint256(PRECISE_UNIT));
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a standard unit.
     *
     * @dev The operands should be in the standard unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRound(int256 x, int256 y) internal pure returns (int256) {
        return _multiplyDecimalRound(x, y, UNIT);
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a standard unit.
     *
     * @dev The operands should be in the standard unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRound(uint256 x, uint256 y) internal pure returns (uint256) {
        return _multiplyDecimalRound(x, y, uint256(UNIT));
    }

    /**
     * @return The result of safely dividing x and y. The return value is a high
     * precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and UNIT must be less than 2**256. As
     * this is an integer division, the result is always rounded down.
     * This helps save on gas. Rounding is more expensive on gas.
     */
    function _divideDecimal(int256 x, int256 y) internal pure returns (int256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return (x * UNIT) / y;
    }

    /**
     * @return The result of safely dividing x and y. The return value is a high
     * precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and UNIT must be less than 2**256. As
     * this is an integer division, the result is always rounded down.
     * This helps save on gas. Rounding is more expensive on gas.
     */
    function _divideDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return (x * uint256(UNIT)) / y;
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * standard precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and the standard precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function _divideDecimalRound(int256 x, int256 y) internal pure returns (int256) {
        return _divideDecimalRound(x, y, UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * high precision decimal.
     *
     * @dev y is divided after the product of x and the high precision unit
     * is evaluated, so the product of x and the high precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function _divideDecimalRoundPrecise(int256 x, int256 y) internal pure returns (int256) {
        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * high precision decimal.
     *
     * @dev y is divided after the product of x and the high precision unit
     * is evaluated, so the product of x and the high precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function _divideDecimalRoundPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        return _divideDecimalRound(x, y, uint256(PRECISE_UNIT));
    }

    /**
     * @dev Convert a standard decimal representation to a high precision one.
     */
    function _decimalToPreciseDecimal(int256 i) internal pure returns (int256) {
        return i * _UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR;
    }

    /**
     * @dev Convert a standard decimal representation to a high precision one.
     */
    function _decimalToPreciseDecimal(uint256 i) internal pure returns (uint256) {
        return i * uint256(_UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    /**
     * @dev Convert a high precision decimal to a standard decimal representation.
     */
    function _preciseDecimalToDecimal(int256 i) internal pure returns (int256) {
        int256 quotientTimesTen = i / (_UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);
        return _roundDividingByTen(quotientTimesTen);
    }

    /**
     * @dev Convert a high precision decimal to a standard decimal representation.
     */
    function _preciseDecimalToDecimal(uint256 i) internal pure returns (uint256) {
        uint256 quotientTimesTen = i / (uint256(_UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR) / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    /**
     * @dev Rounds an input with an extra zero of precision, returning the result without the extra zero.
     * Half increments round away from zero; positive numbers at a half increment are rounded up,
     * while negative such numbers are rounded down. This behaviour is designed to be consistent with the
     * unsigned version of this library (SafeDecimalMath).
     */
    function _roundDividingByTen(int256 valueTimesTen) private pure returns (int256) {
        int256 increment;
        if (valueTimesTen % 10 >= 5) {
            increment = 10;
        } else if (valueTimesTen % 10 <= -5) {
            increment = -10;
        }
        return (valueTimesTen + increment) / 10;
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of the specified precision unit.
     *
     * @dev The operands should be in the form of a the specified unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRound(int256 x, int256 y, int256 precisionUnit) private pure returns (int256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        int256 quotientTimesTen = (x * y) / (precisionUnit / 10);
        return _roundDividingByTen(quotientTimesTen);
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of the specified precision unit.
     *
     * @dev The operands should be in the form of a the specified unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRound(uint256 x, uint256 y, uint256 precisionUnit) private pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        uint256 quotientTimesTen = (x * y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * decimal in the precision unit specified in the parameter.
     *
     * @dev y is divided after the product of x and the specified precision unit
     * is evaluated, so the product of x and the specified precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function _divideDecimalRound(int256 x, int256 y, int256 precisionUnit) private pure returns (int256) {
        int256 resultTimesTen = (x * precisionUnit * 10) / y;
        return _roundDividingByTen(resultTimesTen);
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * decimal in the precision unit specified in the parameter.
     *
     * @dev y is divided after the product of x and the specified precision unit
     * is evaluated, so the product of x and the specified precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function _divideDecimalRound(uint256 x, uint256 y, uint256 precisionUnit) private pure returns (uint256) {
        uint256 resultTimesTen = (x * (precisionUnit * 10)) / y;

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }
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

    function getPrice(uint32 maxAge, bool priceDiffCheck) external view returns (uint256 price, uint256 timestamp);

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

// lib/openzeppelin-contracts-upgradeable/contracts/utils/introspection/ERC165Upgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {}

    function __ERC165_init_unchained() internal onlyInitializing {}
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
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

// src/libraries/PerpMath.sol

/// @title PerpMath
/// @author dHEDGE
/// @notice Abstract contract which contains necessary math functions for perps.
/// @dev Adapted from Synthetix PerpsV2MarketBase <https://github.com/Synthetixio/synthetix/blob/cbd8666f4331ee95fcc667ec7345d13c8ba77efb/contracts/PerpsV2MarketBase.sol#L156>
///      and <https://github.com/Synthetixio/synthetix/blob/cbd8666f4331ee95fcc667ec7345d13c8ba77efb/contracts/SafeDecimalMath.sol>
library PerpMath {
    using SignedMath for int256;
    using DecimalMath for int256;
    using DecimalMath for uint256;

    /////////////////////////////////////////////
    //           Funding Math Functions        //
    /////////////////////////////////////////////

    /// @dev Returns the pSkew = skew / skewScale capping the pSkew between [-1, 1].
    /// @param skew The current system skew.
    /// @param stableCollateralTotal The total stable collateral in the system.
    /// @return pSkew The capped proportional skew.
    function _proportionalSkew(int256 skew, uint256 stableCollateralTotal) internal pure returns (int256 pSkew) {
        if (stableCollateralTotal > 0) {
            pSkew = skew._divideDecimal(int256(stableCollateralTotal));

            if (pSkew < -1e18 || pSkew > 1e18) {
                pSkew = DecimalMath.UNIT.min(pSkew.max(-DecimalMath.UNIT));
            }
        } else {
            assert(skew == 0);
            pSkew = 0;
        }
    }

    /// @dev Retrieves the change in funding rate since the last re-computation.
    ///      There is no variance in computation but will be affected based on outside modifications to
    ///      the market skew, max funding velocity, and time delta.
    /// @param proportionalSkew The capped proportional skew.
    /// @param prevFundingModTimestamp The last recomputed funding timestamp.
    /// @param maxFundingVelocity The maximum funding velocity.
    /// @param maxVelocitySkew The maximum velocity skew.
    /// @return fundingChange The change in funding rate since the last re-computation.
    function _fundingChangeSinceRecomputed(
        int256 proportionalSkew,
        uint256 prevFundingModTimestamp,
        uint256 maxFundingVelocity,
        uint256 maxVelocitySkew
    ) internal view returns (int256 fundingChange) {
        return
            _currentFundingVelocity(proportionalSkew, maxFundingVelocity, maxVelocitySkew)._multiplyDecimal(
                int256(_proportionalElapsedTime(prevFundingModTimestamp))
            );
    }

    /// @dev Function to calculate the funding rate based on market conditions.
    /// @param lastRecomputedFundingRate The last recomputed funding rate.
    /// @param lastRecomputedFundingTimestamp The last recomputed funding timestamp.
    /// @param proportionalSkew The capped proportional skew.
    /// @param maxFundingVelocity The maximum funding velocity.
    /// @param maxVelocitySkew The maximum velocity skew.
    /// @return currFundingRate The current funding rate.
    function _currentFundingRate(
        int256 lastRecomputedFundingRate,
        uint64 lastRecomputedFundingTimestamp,
        int256 proportionalSkew,
        uint256 maxFundingVelocity,
        uint256 maxVelocitySkew
    ) internal view returns (int256 currFundingRate) {
        return
            lastRecomputedFundingRate +
            _fundingChangeSinceRecomputed(
                proportionalSkew,
                lastRecomputedFundingTimestamp,
                maxFundingVelocity,
                maxVelocitySkew
            );
    }

    /// @dev Calculates the sum of the unrecorded funding rates since the last funding re-computation.
    /// @param vaultSummary The current summary of the vault state.
    /// @param maxFundingVelocity The maximum funding velocity.
    /// @param maxVelocitySkew The maximum velocity skew.
    /// @return unrecordedFunding The sum of the unrecorded funding rates since the last funding re-computation.
    function _unrecordedFunding(
        FlatcoinStructs.VaultSummary memory vaultSummary,
        uint256 maxFundingVelocity,
        uint256 maxVelocitySkew
    ) internal view returns (int256 unrecordedFunding) {
        int256 nextFundingRate = _currentFundingRate({
            proportionalSkew: _proportionalSkew(vaultSummary.marketSkew, vaultSummary.stableCollateralTotal),
            lastRecomputedFundingRate: vaultSummary.lastRecomputedFundingRate,
            lastRecomputedFundingTimestamp: vaultSummary.lastRecomputedFundingTimestamp,
            maxFundingVelocity: maxFundingVelocity,
            maxVelocitySkew: maxVelocitySkew
        });

        // NOTE: Synthetix uses the -ve sign here. We won't use it here as we believe it makes intutive sense
        // to use the same sign as the skew to preserve the traditional sense of the sign of the funding rate.
        // However, this also means that we have to invert the sign when calculating the difference between user's index
        // and the current global index for accumulated funding rate.
        int256 avgFundingRate = (vaultSummary.lastRecomputedFundingRate + nextFundingRate) / 2;
        return
            avgFundingRate._multiplyDecimal(
                int256(_proportionalElapsedTime(vaultSummary.lastRecomputedFundingTimestamp))
            );
    }

    /// @dev Same as the above `_unrecordedFunding but with the current funding rate passed in.
    /// @param currentFundingRate The current funding rate.
    /// @param prevFundingRate The previous funding rate.
    /// @param prevFundingModTimestamp The last recomputed funding timestamp.
    /// @return unrecordedFunding The sum of the unrecorded funding rates since the last funding re-computation.
    function _unrecordedFunding(
        int256 currentFundingRate,
        int256 prevFundingRate,
        uint256 prevFundingModTimestamp
    ) internal view returns (int256 unrecordedFunding) {
        int256 avgFundingRate = (prevFundingRate + currentFundingRate) / 2;

        return avgFundingRate._multiplyDecimal(int256(_proportionalElapsedTime(prevFundingModTimestamp)));
    }

    /// @dev The new entry in the funding sequence, appended when funding is recomputed.
    ///      It is the sum of the last entry and the unrecorded funding,
    ///      so the sequence accumulates running total over the market's lifetime.
    /// @param vaultSummary The current summary of the vault state.
    /// @param maxFundingVelocity The maximum funding velocity.
    /// @param maxVelocitySkew The maximum velocity skew.
    /// @return nextFundingEntry The next entry in the funding sequence.
    function _nextFundingEntry(
        FlatcoinStructs.VaultSummary memory vaultSummary,
        uint256 maxFundingVelocity,
        uint256 maxVelocitySkew
    ) internal view returns (int256 nextFundingEntry) {
        return
            vaultSummary.cumulativeFundingRate + _unrecordedFunding(vaultSummary, maxFundingVelocity, maxVelocitySkew);
    }

    /// @dev Same as the above `_nextFundingEntry` but with the next funding entry passed in.
    /// @param unrecordedFunding The sum of the unrecorded funding rates since the last funding re-computation.
    /// @param latestFundingSequenceEntry The latest funding sequence entry.
    /// @return nextFundingEntry The next entry in the funding sequence.
    function _nextFundingEntry(
        int256 unrecordedFunding,
        int256 latestFundingSequenceEntry
    ) internal pure returns (int256 nextFundingEntry) {
        return latestFundingSequenceEntry + unrecordedFunding;
    }

    /// @dev Calculates the current net funding per unit for a position.
    /// @param userFundingSequenceEntry The user's last funding sequence entry.
    /// @param nextFundingEntry The next funding sequence entry.
    /// @return netFundingPerUnit The net funding per unit for a position.
    function _netFundingPerUnit(
        int256 userFundingSequenceEntry,
        int256 nextFundingEntry
    ) internal pure returns (int256 netFundingPerUnit) {
        return userFundingSequenceEntry - nextFundingEntry;
    }

    /*******************************************
     *             Position Details             *
     *******************************************/

    /// @dev Returns the PnL in terms of the market currency (ETH/LST) and not in dollars ($).
    ///      This function rounds down the PnL to avoid rounding errors when subtracting individual PnLs
    ///      from the global `marginDepositedTotal` value when closing the position.
    /// @param position The position to calculate the PnL for.
    /// @param price The current price of the collateral asset.
    /// @return pnl The PnL in terms of the market currency (ETH/LST) and not in dollars ($).
    function _profitLoss(FlatcoinStructs.Position memory position, uint256 price) internal pure returns (int256 pnl) {
        int256 priceShift = int256(price) - int256(position.averagePrice);
        int256 profitLossTimesTen = (int256(position.additionalSize) * (priceShift) * 10) / int256(price);

        if (profitLossTimesTen % 10 != 0) {
            return profitLossTimesTen / 10 - 1;
        } else {
            return profitLossTimesTen / 10;
        }
    }

    /// @dev Returns the PnL in terms of the market currency (ETH/LST) and not in dollars ($).
    ///      This function rounds down the funding accrued to avoid rounding errors when subtracting individual funding fees accrued
    ///      from the global `marginDepositedTotal` value when closing the position.
    /// @param globalPosition The global position to calculate the PnL for.
    /// @param price The current price of the collateral asset.
    /// @return pnl The PnL in terms of the market currency (ETH/LST) and not in dollars ($).
    function _profitLossTotal(
        FlatcoinStructs.GlobalPositions memory globalPosition,
        uint256 price
    ) internal pure returns (int256 pnl) {
        int256 priceShift = int256(price) - int256(globalPosition.averagePrice);

        return (int256(globalPosition.sizeOpenedTotal) * (priceShift)) / int256(price);
    }

    function _accruedFunding(
        FlatcoinStructs.Position memory position,
        int256 nextFundingEntry
    ) internal pure returns (int256 accruedFunding) {
        int256 net = _netFundingPerUnit(position.entryCumulativeFunding, nextFundingEntry);

        return int256(position.additionalSize)._multiplyDecimal(net);
    }

    /// @dev Calculates the funding fees accrued by the global position (all leverage traders).
    ///      To avoid rounding errors when individual positions close and the global `marginDepositedTotal` is updated,
    ///      we add 1 wei to the total accrued funding by longs. This also means that there might be some amount left in the
    ///      vault belonging to the longs which is not distributed. This is insignificant and is a trade-off to avoid rounding errors.
    /// @param globalPosition The global position to calculate the funding fees accrued for.
    /// @param unrecordedFunding The sum of the unrecorded funding rates since the last funding re-computation.
    /// @return accruedFundingLongs The funding fees accrued by the global position (all leverage traders).
    function _accruedFundingTotalByLongs(
        FlatcoinStructs.GlobalPositions memory globalPosition,
        int256 unrecordedFunding
    ) internal pure returns (int256 accruedFundingLongs) {
        int256 accruedFundingTotal = -int256(globalPosition.sizeOpenedTotal)._multiplyDecimal(unrecordedFunding);

        return (accruedFundingTotal != 0) ? accruedFundingTotal + 1 : accruedFundingTotal;
    }

    /// @dev Summarises a positions' earnings/losses.
    /// @param position The position to summarise.
    /// @param nextFundingEntry The next (recalculated) cumulative funding rate.
    /// @param price The current price of the collateral asset.
    /// @return positionSummary The summary of the position.
    function _getPositionSummary(
        FlatcoinStructs.Position memory position,
        int256 nextFundingEntry,
        uint256 price
    ) internal pure returns (FlatcoinStructs.PositionSummary memory positionSummary) {
        int256 profitLoss = _profitLoss(position, price);
        int256 accruedFunding = _accruedFunding(position, nextFundingEntry);

        return
            FlatcoinStructs.PositionSummary({
                profitLoss: profitLoss,
                accruedFunding: accruedFunding,
                marginAfterSettlement: int256(position.marginDeposited) + profitLoss + accruedFunding
            });
    }

    /// @dev Summarises the market state which is used in other functions.
    /// @param vaultSummary The current summary of the vault state.
    /// @param maxFundingVelocity The maximum funding velocity.
    /// @param maxVelocitySkew The maximum velocity skew.
    /// @param price The current price of the collateral asset.
    /// @return marketSummary The summary of the market.
    function _getMarketSummaryLongs(
        FlatcoinStructs.VaultSummary memory vaultSummary,
        uint256 maxFundingVelocity,
        uint256 maxVelocitySkew,
        uint256 price
    ) internal view returns (FlatcoinStructs.MarketSummary memory marketSummary) {
        int256 currentFundingRate = _currentFundingRate({
            proportionalSkew: _proportionalSkew(vaultSummary.marketSkew, vaultSummary.stableCollateralTotal),
            lastRecomputedFundingRate: vaultSummary.lastRecomputedFundingRate,
            lastRecomputedFundingTimestamp: vaultSummary.lastRecomputedFundingTimestamp,
            maxFundingVelocity: maxFundingVelocity,
            maxVelocitySkew: maxVelocitySkew
        });

        int256 unrecordedFunding = _unrecordedFunding(
            currentFundingRate,
            vaultSummary.lastRecomputedFundingRate,
            vaultSummary.lastRecomputedFundingTimestamp
        );

        return
            FlatcoinStructs.MarketSummary({
                profitLossTotalByLongs: _profitLossTotal(vaultSummary.globalPositions, price),
                accruedFundingTotalByLongs: _accruedFundingTotalByLongs(
                    vaultSummary.globalPositions,
                    unrecordedFunding
                ),
                currentFundingRate: currentFundingRate,
                nextFundingEntry: _nextFundingEntry(unrecordedFunding, vaultSummary.cumulativeFundingRate)
            });
    }

    /////////////////////////////////////////////
    //            Liquidation Math             //
    /////////////////////////////////////////////

    /// @notice Function to calculate the approximate liquidation price.
    /// @dev Only approximation can be achieved due to the fact that the funding rate influences the liquidation price.
    /// @param position The position to calculate the liquidation price for.
    /// @param nextFundingEntry The next (recalculated) cumulative funding rate.
    /// @param liquidationFeeRatio The liquidation fee of the system.
    /// @param liquidationBufferRatio The liquidation buffer ratio of the system.
    /// @param liquidationFeeUpperBound The maximum liquidation fee to be paid to the keepers.
    /// @param currentPrice Current price of the collateral asset.
    function _approxLiquidationPrice(
        FlatcoinStructs.Position memory position,
        int256 nextFundingEntry,
        uint128 liquidationFeeRatio,
        uint128 liquidationBufferRatio,
        uint256 liquidationFeeLowerBound,
        uint256 liquidationFeeUpperBound,
        uint256 currentPrice
    ) internal pure returns (uint256 approxLiquidationPrice) {
        if (position.additionalSize == 0) {
            return 0;
        }

        FlatcoinStructs.PositionSummary memory positionSummary = _getPositionSummary(
            position,
            nextFundingEntry,
            currentPrice
        );

        int256 result = _calcLiquidationPrice(
            position,
            positionSummary,
            _liquidationMargin(
                position.additionalSize,
                liquidationFeeRatio,
                liquidationBufferRatio,
                liquidationFeeLowerBound,
                liquidationFeeUpperBound,
                currentPrice
            )
        );

        return (result > 0) ? uint256(result) : 0;
    }

    /// @dev Function to get the liquidation status of a position.
    /// @param position The position to check the liquidation status for.
    /// @param liquidationFeeRatio The liquidation fee of the system.
    /// @param liquidationBufferRatio The liquidation buffer ratio of the system.
    /// @param liquidationFeeLowerBound The minimum liquidation fee to be paid to the flagger.
    /// @param liquidationFeeUpperBound The maximum liquidation fee to be paid to the keepers.
    /// @param nextFundingEntry The next (recalculated) cumulative funding rate.
    /// @param currentPrice Current price of the collateral asset.
    /// @return isLiquidatable Whether the position is liquidatable.
    function _canLiquidate(
        FlatcoinStructs.Position memory position,
        uint128 liquidationFeeRatio,
        uint128 liquidationBufferRatio,
        uint256 liquidationFeeLowerBound,
        uint256 liquidationFeeUpperBound,
        int256 nextFundingEntry,
        uint256 currentPrice
    ) internal pure returns (bool isLiquidatable) {
        // No liquidations of empty positions.
        if (position.additionalSize == 0) {
            return false;
        }

        FlatcoinStructs.PositionSummary memory positionSummary = _getPositionSummary(
            position,
            nextFundingEntry,
            currentPrice
        );

        uint256 lMargin = _liquidationMargin(
            position.additionalSize,
            liquidationFeeRatio,
            liquidationBufferRatio,
            liquidationFeeLowerBound,
            liquidationFeeUpperBound,
            currentPrice
        );

        return positionSummary.marginAfterSettlement <= int256(lMargin);
    }

    /// @dev The minimal margin at which liquidation can happen.
    ///      Is the sum of liquidationBuffer, liquidationFee (for flagger) and keeperLiquidationFee (for liquidator)
    ///      The liquidation margin contains a buffer that is proportional to the position
    ///      size. The buffer should prevent liquidation happening at negative margin (due to next price being worse).
    /// @param positionSize size of position in fixed point decimal collateral asset units.
    /// @param liquidationFeeRatio ratio of the position size to be charged as fee.
    /// @param liquidationBufferRatio ratio of the position size needed to be maintained as buffer.
    /// @param liquidationFeeUpperBound maximum fee to be charged in collateral asset units.
    /// @param currentPrice current price of the collateral asset in USD units.
    /// @return lMargin liquidation margin to maintain in collateral asset units.
    function _liquidationMargin(
        uint256 positionSize,
        uint128 liquidationFeeRatio,
        uint128 liquidationBufferRatio,
        uint256 liquidationFeeLowerBound,
        uint256 liquidationFeeUpperBound,
        uint256 currentPrice
    ) internal pure returns (uint256 lMargin) {
        uint256 liquidationBuffer = positionSize._multiplyDecimal(liquidationBufferRatio);

        // The liquidation margin consists of the liquidation buffer, liquidation fee and the keeper fee for covering execution costs.
        return
            liquidationBuffer +
            _liquidationFee(
                positionSize,
                liquidationFeeRatio,
                liquidationFeeLowerBound,
                liquidationFeeUpperBound,
                currentPrice
            );
    }

    /// The fee charged from the margin during liquidation. Fee is proportional to position size.
    /// @dev There is a cap on the fee to prevent liquidators from being overpayed.
    /// @param positionSize size of position in fixed point decimal baseAsset units.
    /// @param liquidationFeeRatio ratio of the position size to be charged as fee.
    /// @param liquidationFeeUpperBound maximum fee to be charged in USD units.
    /// @return liquidationFee liquidation fee to be paid to liquidator in collateral asset units.
    function _liquidationFee(
        uint256 positionSize,
        uint128 liquidationFeeRatio,
        uint256 liquidationFeeLowerBound,
        uint256 liquidationFeeUpperBound,
        uint256 currentPrice
    ) internal pure returns (uint256 liquidationFee) {
        // size * price * fee-ratio
        uint256 proportionalFee = positionSize._multiplyDecimal(liquidationFeeRatio)._multiplyDecimal(currentPrice);
        uint256 cappedProportionalFee = proportionalFee > liquidationFeeUpperBound
            ? liquidationFeeUpperBound
            : proportionalFee;

        uint256 lFeeUSD = cappedProportionalFee < liquidationFeeLowerBound
            ? liquidationFeeLowerBound
            : cappedProportionalFee;

        // Return liquidation fee in collateral asset units.
        return (lFeeUSD * 1e18) / currentPrice;
    }

    /////////////////////////////////////////////
    //            Private Functions            //
    /////////////////////////////////////////////

    /// @dev The funding velocity is based on the market skew and is scaled by the maxVelocitySkew.
    ///      With higher skews beyond the maxVelocitySkew, the velocity remains constant.
    /// @param proportionalSkew The calculated capped proportional skew.
    /// @param maxFundingVelocity The maximum funding velocity.
    /// @param maxVelocitySkew The maximum velocity skew.
    function _currentFundingVelocity(
        int256 proportionalSkew,
        uint256 maxFundingVelocity,
        uint256 maxVelocitySkew
    ) private pure returns (int256 currFundingVelocity) {
        if (maxVelocitySkew > 0) {
            // Scale the funding velocity by the maxVelocitySkew and cap it at the maximum +- velocity.
            int256 fundingVelocity = (proportionalSkew * int256(maxFundingVelocity)) / int256(maxVelocitySkew);
            return int256(maxFundingVelocity).min(fundingVelocity.max(-int256(maxFundingVelocity)));
        }

        return proportionalSkew._multiplyDecimal(int256(maxFundingVelocity));
    }

    /// @dev Returns the time delta between the last funding timestamp and the current timestamp.
    /// @param prevModTimestamp The last funding timestamp.
    /// @return elapsedTime The time delta between the last funding timestamp and the current timestamp.
    function _proportionalElapsedTime(uint256 prevModTimestamp) private view returns (uint256 elapsedTime) {
        return (block.timestamp - prevModTimestamp)._divideDecimal(1 days);
    }

    /// @dev Calculates the liquidation price.
    /// @param position The position to calculate the liquidation price for.
    /// @param positionSummary The summary of the position.
    /// @param liquidationMargin The liquidation margin.
    /// @return liqPrice The liquidation price.
    function _calcLiquidationPrice(
        FlatcoinStructs.Position memory position,
        FlatcoinStructs.PositionSummary memory positionSummary,
        uint256 liquidationMargin
    ) private pure returns (int256 liqPrice) {
        // A position can be liquidated whenever:- remainingMargin <= liquidationMargin
        //
        // Hence, expanding the definition of remainingMargin the exact price at which a position can be liquidated is:
        //
        // liquidationMargin = margin + profitLoss + funding
        // liquidationMargin = margin + [(price - entryPrice) * postionSize / price] + funding
        // liquidationMargin - (margin + funding) = [(price - entryPrice) * postionSize / price]
        // liquidationMargin - (margin + funding) = postionSize - (entryPrice * postionSize / price)
        // positionSize - [liquidationMargin - (margin + funding)] = entryPrice * postionSize / price
        // positionSize * entryPrice / {positionSize - [liquidationMargin - (margin + funding)]} = price
        //
        // In our case, positionSize = position.additionalSize.
        // Note: If there are bounds on `liquidationFee` and/or `keeperFee` then this formula doesn't yield an accurate liquidation price.
        // This is because, when the position size is too large such that liquidation fee for that position has to be bounded we are essentially
        // solving the following equation:
        // LiquidationBuffer + (LiquidationUpperBound / Price) + KeeperFee = Margin + (Price - EntryPrice)*PositionSize + AccruedFunding
        // And according to Wolfram Alpha, this equation cannot be solved for Price (at least trivially):
        // https://www.wolframalpha.com/input?i=A+++(B+/+X)+%3D+C+++(X+-+D)+*+E+,+X+%3E+0,+Solution+for+variable+X
        return
            int256((position.additionalSize)._multiplyDecimal(position.averagePrice))._divideDecimal(
                int256(position.additionalSize + position.marginDeposited) +
                    positionSummary.accruedFunding -
                    int256(liquidationMargin)
            );
    }
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

    function fundingAdjustedLongPnLTotal(
        uint32 maxAge,
        bool priceDiffCheck
    ) external view returns (int256 _fundingAdjustedPnL);

    function tokenIdNext() external view returns (uint256 tokenId);

    function leverageTradingFee() external view returns (uint256 leverageTradingFee);

    function checkLeverageCriteria(uint256 margin, uint256 size) external view;

    function marginMin() external view returns (uint256 marginMin);

    function getTradeFee(uint256 size) external view returns (uint256 tradeFee);
}

// lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ERC721Upgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC721,
    IERC721Metadata,
    IERC721Errors
{
    using Strings for uint256;

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC721
    struct ERC721Storage {
        // Token name
        string _name;
        // Token symbol
        string _symbol;
        mapping(uint256 tokenId => address) _owners;
        mapping(address owner => uint256) _balances;
        mapping(uint256 tokenId => address) _tokenApprovals;
        mapping(address owner => mapping(address operator => bool)) _operatorApprovals;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721StorageLocation = 0x80bb2b638cc20bc4d0a60d66940f3ab4a00c1d7b313497ca82fb0b4ab0079300;

    function _getERC721Storage() private pure returns (ERC721Storage storage $) {
        assembly {
            $.slot := ERC721StorageLocation
        }
    }

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC721Storage storage $ = _getERC721Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        ERC721Storage storage $ = _getERC721Storage();
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return $._balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
     * the `spender` for the specific `tokenId`.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        unchecked {
            $._balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                $._balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                $._balances[to] += 1;
            }
        }

        $._owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        $._tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        ERC721Storage storage $ = _getERC721Storage();
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        $._operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
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

// lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/ERC721Enumerable.sol)

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds enumerability
 * of all the token ids in the contract as well as all token ids owned by each account.
 *
 * CAUTION: `ERC721` extensions that implement custom `balanceOf` logic, such as `ERC721Consecutive`,
 * interfere with enumerability and should not be used together with `ERC721Enumerable`.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721Enumerable {
    /// @custom:storage-location erc7201:openzeppelin.storage.ERC721Enumerable
    struct ERC721EnumerableStorage {
        mapping(address owner => mapping(uint256 index => uint256)) _ownedTokens;
        mapping(uint256 tokenId => uint256) _ownedTokensIndex;
        uint256[] _allTokens;
        mapping(uint256 tokenId => uint256) _allTokensIndex;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721Enumerable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721EnumerableStorageLocation =
        0x645e039705490088daad89bae25049a34f4a9072d398537b1ab2425f24cbed00;

    function _getERC721EnumerableStorage() private pure returns (ERC721EnumerableStorage storage $) {
        assembly {
            $.slot := ERC721EnumerableStorageLocation
        }
    }

    /**
     * @dev An `owner`'s token query was out of bounds for `index`.
     *
     * NOTE: The owner being `address(0)` indicates a global out of bounds index.
     */
    error ERC721OutOfBoundsIndex(address owner, uint256 index);

    /**
     * @dev Batch mint is not allowed.
     */
    error ERC721EnumerableForbiddenBatchMint();

    function __ERC721Enumerable_init() internal onlyInitializing {}

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {}
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        if (index >= balanceOf(owner)) {
            revert ERC721OutOfBoundsIndex(owner, index);
        }
        return $._ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        return $._allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        if (index >= totalSupply()) {
            revert ERC721OutOfBoundsIndex(address(0), index);
        }
        return $._allTokens[index];
    }

    /**
     * @dev See {ERC721-_update}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address previousOwner = super._update(to, tokenId, auth);

        if (previousOwner == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            _removeTokenFromOwnerEnumeration(previousOwner, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }

        return previousOwner;
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        uint256 length = balanceOf(to) - 1;
        $._ownedTokens[to][length] = tokenId;
        $._ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        $._allTokensIndex[tokenId] = $._allTokens.length;
        $._allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from);
        uint256 tokenIndex = $._ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = $._ownedTokens[from][lastTokenIndex];

            $._ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            $._ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete $._ownedTokensIndex[tokenId];
        delete $._ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = $._allTokens.length - 1;
        uint256 tokenIndex = $._allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = $._allTokens[lastTokenIndex];

        $._allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        $._allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete $._allTokensIndex[tokenId];
        $._allTokens.pop();
    }

    /**
     * See {ERC721-_increaseBalance}. We need that to account tokens that were minted in batch
     */
    function _increaseBalance(address account, uint128 amount) internal virtual override {
        if (amount > 0) {
            revert ERC721EnumerableForbiddenBatchMint();
        }
        super._increaseBalance(account, amount);
    }
}

// src/misc/ERC721LockableEnumerableUpgradeable.sol

// solhint-disable reason-string
// solhint-disable gas-custom-errors
contract ERC721LockableEnumerableUpgradeable is ERC721EnumerableUpgradeable {
    struct LockData {
        uint8 lockCount;
        mapping(bytes32 moduleKeys => bool locked) lockedByModule;
    }

    /// @dev Mapping which holds the lock status of each token ID.
    ///      A `tokenId` is locked if the `lockData.lockCount` value is greater than 0.
    mapping(uint256 tokenId => LockData lockData) internal _lockCounter;

    event Locked(uint256 indexed tokenId, bytes32 indexed moduleKey);
    event Unlocked(uint256 indexed tokenId, bytes32 indexed moduleKey);
    event UnlockedAllLocks(uint256 tokenId, bytes32 indexed moduleKey);

    // solhint-disable-next-line func-name-mixedcase
    function __ERC721LockableEnumerableUpgradeable_init()
        internal
        onlyInitializing // solhint-disable-next-line no-empty-blocks
    {}

    // solhint-disable-next-line func-name-mixedcase
    function __ERC721LockableEnumerableUpgradeable_init_unchained()
        internal
        onlyInitializing // solhint-disable-next-line no-empty-blocks
    {}

    /// @notice Function to lock a token ID.
    /// @dev Note that this function doesn't revert if the token ID is already locked.
    /// @dev  Some important notes about the lock mechanism:
    ///       - Multiple modules can lock the same token ID, but the token ID will only be unlocked when all modules unlock it.
    ///       - Each time a module calls `lock`, the `lockCount` is incremented by 1 only if the module hasn't locked the token ID before.
    /// @dev Warning: This function doesn't check the caller is the owner of the token. That's why this should only be used by trusted modules.
    ///      which contain the check for the same.
    /// @param tokenId The ERC721 token ID to lock.
    function _lock(uint256 tokenId, bytes32 moduleKey) internal virtual {
        require(
            !_lockCounter[tokenId].lockedByModule[moduleKey],
            "ERC721LockableEnumerableUpgradeable: token is already locked by this module"
        );

        ++_lockCounter[tokenId].lockCount;
        _lockCounter[tokenId].lockedByModule[moduleKey] = true;

        emit Locked(tokenId, moduleKey);
    }

    /// @notice Function to unlock a token ID.
    /// @dev Note that this function doesn't revert if the token ID is already unlocked.
    /// @dev Warning: This function doesn't check the caller is the owner of the token. That's why this should only be used by trusted modules.
    ///      which contain the check for the same.
    /// @param tokenId The ERC721 token ID to unlock.
    function _unlock(uint256 tokenId, bytes32 moduleKey) internal virtual {
        require(_lockCounter[tokenId].lockCount > 0, "ERC721LockableEnumerableUpgradeable: token is already unlocked");
        require(
            _lockCounter[tokenId].lockedByModule[moduleKey],
            "ERC721LockableEnumerableUpgradeable: token is not locked by this module"
        );

        --_lockCounter[tokenId].lockCount;
        _lockCounter[tokenId].lockedByModule[moduleKey] = false;

        emit Unlocked(tokenId, moduleKey);
    }

    /// @notice Function to clear all locks of a token ID.
    /// @dev Warning: This function should only be used before burning the token.
    /// @dev This function doesn't check if there are any locks or not as there is no point in doing so as we are going to clear all locks anyway.
    /// @dev We just emit the `moduleKey` which called this function for tracking purposes.
    function _clearAllLocks(uint256 tokenId, bytes32 moduleKey) internal virtual {
        _lockCounter[tokenId].lockCount = 0;

        emit UnlockedAllLocks(tokenId, moduleKey);
    }

    /// @notice Before token transfer hook.
    /// @dev Reverts if the token is locked. Make sure that when minting/burning a token it is unlocked.
    /// @param to The address to transfer tokens to.
    /// @param tokenId The ERC721 token ID to transfer.
    /// @param auth See OZ _update function.
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address from) {
        // Make sure the token is not locked.
        require(_lockCounter[tokenId].lockCount == 0, "ERC721LockableEnumerableUpgradeable: token is locked");

        return super._update(to, tokenId, auth);
    }

    uint256[49] private __gap;
}

// src/LeverageModule.sol

/// @title LeverageModule
/// @author dHEDGE
/// @notice Contains functions to create/manage leverage positions.
/// @dev This module shouldn't hold any funds but can direct the vault to transfer funds.
contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnumerableUpgradeable {
    using SafeCast for *;
    using DecimalMath for uint256;

    /// @notice ERC721 token ID increment on mint.
    uint256 public tokenIdNext;

    /// @notice Charged for opening, adjusting or closing a position.
    /// @dev 1e18 = 100%
    uint256 public leverageTradingFee;

    /// @notice Leverage position criteria limits
    /// @notice A minimum margin limit adds a cost to create a position and ensures it can be liquidated at high leverage
    uint256 public marginMin;

    /// @notice Minimum leverage limit ensures that the position is valuable and adds long open interest
    uint256 public leverageMin;

    /// @notice Maximum leverage limit ensures that the position is safely liquidatable by keepers
    uint256 public leverageMax;

    /// @dev To prevent the implementation contract from being used, we invoke the _disableInitializers
    ///      function in the constructor to automatically lock it when it is deployed.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Function to initialize this contract.
    function initialize(
        IFlatcoinVault _vault,
        uint256 _levTradingFee,
        uint256 _marginMin,
        uint256 _leverageMin,
        uint256 _leverageMax
    ) external initializer {
        __Module_init(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY, _vault);
        __ERC721_init("Flat Money Leveraged Positions", "LEV");

        setLeverageTradingFee(_levTradingFee);
        setLeverageCriteria(_marginMin, _leverageMin, _leverageMax);
    }

    /////////////////////////////////////////////
    //         External Write Functions         //
    /////////////////////////////////////////////

    /// @notice Leverage open function. Mints ERC721 token receipt.
    /// @dev Has to be used in conjunction with the DelayedOrder module.
    /// @dev Uses the Pyth network price to execute.
    /// @param _account The user account which has a pending open leverage order.
    /// @param _keeper The address of the keeper executing the order.
    /// @param _order The order to be executed.
    /// @return _newTokenId The ERC721 token ID of the new leverage position.
    function executeOpen(
        address _account,
        address _keeper,
        FlatcoinStructs.Order calldata _order
    ) external onlyAuthorizedModule returns (uint256 _newTokenId) {
        // Make sure the oracle price is after the order executability time
        uint32 maxAge = _getMaxAge(_order.executableAtTime);

        FlatcoinStructs.AnnouncedLeverageOpen memory announcedOpen = abi.decode(
            _order.orderData,
            (FlatcoinStructs.AnnouncedLeverageOpen)
        );

        // Check that buy price doesn't exceed requested price.
        (uint256 entryPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
            maxAge: maxAge,
            priceDiffCheck: true
        });

        if (entryPrice > announcedOpen.maxFillPrice)
            revert FlatcoinErrors.HighSlippage(entryPrice, announcedOpen.maxFillPrice);

        vault.checkSkewMax({
            sizeChange: announcedOpen.additionalSize,
            stableCollateralChange: int256(announcedOpen.tradeFee)
        });

        {
            // The margin change is equal to funding fees accrued to longs and the margin deposited by the trader.
            vault.updateGlobalPositionData({
                price: entryPrice,
                marginDelta: int256(announcedOpen.margin),
                additionalSizeDelta: int256(announcedOpen.additionalSize)
            });

            _newTokenId = _mint(_account);

            vault.setPosition(
                FlatcoinStructs.Position({
                    averagePrice: entryPrice,
                    marginDeposited: announcedOpen.margin,
                    additionalSize: announcedOpen.additionalSize,
                    entryCumulativeFunding: vault.cumulativeFundingRate()
                }),
                _newTokenId
            );
        }

        // Check that the new position isn't immediately liquidatable.
        if (
            ILiquidationModule(vault.moduleAddress(FlatcoinModuleKeys._LIQUIDATION_MODULE_KEY)).canLiquidate(
                _newTokenId
            )
        ) revert FlatcoinErrors.PositionCreatesBadDebt();

        // Mint points
        IPointsModule pointsModule = IPointsModule(vault.moduleAddress(FlatcoinModuleKeys._POINTS_MODULE_KEY));
        pointsModule.mintLeverageOpen(_account, announcedOpen.additionalSize);

        // Settle the collateral
        vault.updateStableCollateralTotal(int256(announcedOpen.tradeFee)); // pay the trade fee to stable LPs
        vault.sendCollateral({to: _keeper, amount: _order.keeperFee}); // pay the keeper their fee

        emit FlatcoinEvents.LeverageOpen(_account, _newTokenId, entryPrice);
    }

    /// @notice Leverage adjust function.
    /// @dev Needs to be used in conjunction with the DelayedOrder module.
    /// @dev Note that a check has to be made in the calling module to ensure that
    ///      the position exists before calling this function.
    /// @param _account The user account which has a pending adjust leverage order.
    /// @param _keeper The address of the keeper executing the order.
    /// @param _order The order to be executed.
    function executeAdjust(
        address _account,
        address _keeper,
        FlatcoinStructs.Order calldata _order
    ) external onlyAuthorizedModule {
        uint32 maxAge = _getMaxAge(_order.executableAtTime);

        FlatcoinStructs.AnnouncedLeverageAdjust memory announcedAdjust = abi.decode(
            _order.orderData,
            (FlatcoinStructs.AnnouncedLeverageAdjust)
        );

        FlatcoinStructs.Position memory position = vault.getPosition(announcedAdjust.tokenId);

        (uint256 adjustPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
            maxAge: maxAge,
            priceDiffCheck: true
        });

        int256 cumulativeFunding = vault.cumulativeFundingRate();

        // Prevent adjustment if the position is underwater.
        if (
            PerpMath
                ._getPositionSummary({position: position, nextFundingEntry: cumulativeFunding, price: adjustPrice})
                .marginAfterSettlement <= 0
        ) revert FlatcoinErrors.ValueNotPositive("marginAfterSettlement");

        // Fees come out from the margin if the margin is being reduced or remains unchanged (meaning the size is being modified).
        int256 marginAdjustment = (announcedAdjust.marginAdjustment > 0)
            ? announcedAdjust.marginAdjustment
            : announcedAdjust.marginAdjustment - int256(announcedAdjust.totalFee);

        // This accounts for the profit loss and funding fees accrued till now.
        int256 newMargin = marginAdjustment + int256(position.marginDeposited);

        uint256 newAdditionalSize = (int256(position.additionalSize) + announcedAdjust.additionalSizeAdjustment)
            .toUint256();

        uint256 newEntryPrice;

        if (announcedAdjust.additionalSizeAdjustment >= 0) {
            // Size is being increased. Adjust the entry price to the average entry price.

            if (adjustPrice > announcedAdjust.fillPrice)
                revert FlatcoinErrors.HighSlippage(adjustPrice, announcedAdjust.fillPrice);

            newEntryPrice =
                (position.averagePrice *
                    position.additionalSize +
                    adjustPrice *
                    uint256(announcedAdjust.additionalSizeAdjustment)) /
                newAdditionalSize;

            // Given that the size of a position is being increased, it's necessary to check that
            // it doesn't exceed the max skew limit.
            vault.checkSkewMax({
                sizeChange: uint256(announcedAdjust.additionalSizeAdjustment),
                stableCollateralChange: int256(announcedAdjust.tradeFee)
            });
        } else {
            // Size is being decreased. Keep the same entry price.

            if (adjustPrice < announcedAdjust.fillPrice)
                revert FlatcoinErrors.HighSlippage(adjustPrice, announcedAdjust.fillPrice);

            int256 partialPnLEarned = (-announcedAdjust.additionalSizeAdjustment *
                (int256(adjustPrice) - int256(position.averagePrice))) / int256(adjustPrice);

            newMargin += partialPnLEarned;
            newEntryPrice = position.averagePrice;

            // The margin being updated in the global position should also account for the pnl being settled for
            // partial closure of the position.
            marginAdjustment += partialPnLEarned;

            // Since position size decrease is akin to partial closure of the position, we have to settle the profit loss
            // associated with this position size. The settlement involves increasing/decreasing the stable collateral total
            // as LPs are the counterparty to each leverage position.
            vault.updateStableCollateralTotal(-partialPnLEarned);
        }

        // Entry cumulative funding is adjusted to account for the new size.
        // So that the position accumulated funding is not affected after adjustment.
        int256 newEntryCumulativeFunding = position.entryCumulativeFunding +
            (((cumulativeFunding - position.entryCumulativeFunding) * announcedAdjust.additionalSizeAdjustment) /
                int256(newAdditionalSize));

        // Check that the leverage isn't too high.
        checkLeverageCriteria(newMargin.toUint256(), newAdditionalSize);

        vault.updateGlobalPositionData({
            price: (announcedAdjust.additionalSizeAdjustment < 0) ? position.averagePrice : adjustPrice,
            marginDelta: marginAdjustment,
            additionalSizeDelta: announcedAdjust.additionalSizeAdjustment
        });

        vault.setPosition(
            FlatcoinStructs.Position({
                averagePrice: newEntryPrice,
                marginDeposited: newMargin.toUint256(),
                additionalSize: newAdditionalSize,
                entryCumulativeFunding: newEntryCumulativeFunding
            }),
            announcedAdjust.tokenId
        );

        // Check that the new position isn't immediately liquidatable.
        if (
            ILiquidationModule(vault.moduleAddress(FlatcoinModuleKeys._LIQUIDATION_MODULE_KEY)).canLiquidate(
                announcedAdjust.tokenId,
                adjustPrice
            )
        ) revert FlatcoinErrors.PositionCreatesBadDebt();

        // Mint points.
        if (announcedAdjust.additionalSizeAdjustment > 0) {
            address positionOwner = ownerOf(announcedAdjust.tokenId);
            IPointsModule pointsModule = IPointsModule(vault.moduleAddress(FlatcoinModuleKeys._POINTS_MODULE_KEY));

            pointsModule.mintLeverageOpen(positionOwner, uint256(announcedAdjust.additionalSizeAdjustment));
        }

        if (announcedAdjust.tradeFee > 0) vault.updateStableCollateralTotal(int256(announcedAdjust.tradeFee));

        // Sending keeper fee from order contract to the executor.
        vault.sendCollateral({to: _keeper, amount: _order.keeperFee});

        if (announcedAdjust.marginAdjustment < 0) {
            // We send the user that much margin they requested during announceLeverageAdjust().
            // However their remaining margin is reduced by the fees.
            // It is accounted in announceLeverageAdjust().
            uint256 marginToWithdraw = uint256(announcedAdjust.marginAdjustment * -1);

            // Withdrawing margin from the vault and sending it to the user.
            vault.sendCollateral({to: _account, amount: marginToWithdraw});
        }

        emit FlatcoinEvents.LeverageAdjust(announcedAdjust.tokenId, newEntryPrice, adjustPrice);
    }

    /// @notice Leverage close function.
    /// @dev Needs to be used in conjunction with the DelayedOrder module.
    /// @dev Note that a check has to be made in the calling module to ensure that
    ///      the position exists before calling this function.
    /// @param _account The user account which has a pending close leverage order.
    /// @param _keeper The address of the keeper executing the order.
    /// @param _order The order to be executed.
    function executeClose(
        address _account,
        address _keeper,
        FlatcoinStructs.Order calldata _order
    ) external onlyAuthorizedModule returns (int256 settledMargin) {
        FlatcoinStructs.AnnouncedLeverageClose memory announcedClose = abi.decode(
            _order.orderData,
            (FlatcoinStructs.AnnouncedLeverageClose)
        );

        FlatcoinStructs.Position memory position = vault.getPosition(announcedClose.tokenId);

        // Make sure the oracle price is after the order executability time
        uint32 maxAge = _getMaxAge(_order.executableAtTime);

        // check that sell price doesn't exceed requested price
        (uint256 exitPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
            maxAge: maxAge,
            priceDiffCheck: true
        });
        if (exitPrice < announcedClose.minFillPrice)
            revert FlatcoinErrors.HighSlippage(exitPrice, announcedClose.minFillPrice);

        uint256 totalFee;
        FlatcoinStructs.PositionSummary memory positionSummary;
        {
            positionSummary = PerpMath._getPositionSummary(position, vault.cumulativeFundingRate(), exitPrice);

            settledMargin = positionSummary.marginAfterSettlement;
            totalFee = announcedClose.tradeFee + _order.keeperFee;

            if (settledMargin <= 0) revert FlatcoinErrors.ValueNotPositive("settledMargin");
            // Make sure there is enough margin in the position to pay the keeper fee
            if (settledMargin < int256(totalFee)) revert FlatcoinErrors.NotEnoughMarginForFees(settledMargin, totalFee);

            vault.updateStableCollateralTotal(int256(announcedClose.tradeFee) - positionSummary.profitLoss); // pay the trade fee to stable LPs

            vault.updateGlobalPositionData({
                price: position.averagePrice,
                marginDelta: -(int256(position.marginDeposited) + positionSummary.accruedFunding),
                additionalSizeDelta: -int256(position.additionalSize)
            });

            // Delete position storage
            vault.deletePosition(announcedClose.tokenId);
        }

        // Cancel any existing limit order on the position
        ILimitOrder(vault.moduleAddress(FlatcoinModuleKeys._LIMIT_ORDER_KEY)).cancelExistingLimitOrder(
            announcedClose.tokenId
        );

        burn(announcedClose.tokenId, FlatcoinModuleKeys._LEVERAGE_MODULE_KEY);

        // Settle the collateral.
        vault.sendCollateral({to: _keeper, amount: _order.keeperFee}); // pay the keeper their fee
        vault.sendCollateral({to: _account, amount: uint256(settledMargin) - totalFee}); // transfer remaining amount to the trader

        emit FlatcoinEvents.LeverageClose(announcedClose.tokenId, exitPrice, positionSummary);
    }

    /// @notice Burns the ERC721 token representing the leverage position.
    /// @dev This function unlocks the position before burning it.
    ///      This is to avoid the transfer to address(0) reversion.
    /// @param _tokenId The ERC721 token ID of the leverage position.
    /// @param _moduleKey The module key which is burning the token.
    function burn(uint256 _tokenId, bytes32 _moduleKey) public onlyAuthorizedModule {
        _clearAllLocks(_tokenId, _moduleKey);
        _burn(_tokenId);
    }

    /// @notice Locks the ERC721 token representing the leverage position.
    /// @param _tokenId The ERC721 token ID of the leverage position.
    /// @param _moduleKey The module key which is locking the token.
    function lock(uint256 _tokenId, bytes32 _moduleKey) public onlyAuthorizedModule {
        _lock(_tokenId, _moduleKey);
    }

    /// @notice Unlocks the ERC721 token representing the leverage position.
    /// @param _tokenId The ERC721 token ID of the leverage position.
    /// @param _moduleKey The module key which is unlocking the token.
    function unlock(uint256 _tokenId, bytes32 _moduleKey) public onlyAuthorizedModule {
        _unlock(_tokenId, _moduleKey);
    }

    /////////////////////////////////////////////
    //             View Functions              //
    /////////////////////////////////////////////

    /// @notice Returns the lock status of a leverage NFT position.
    /// @param _tokenId The ERC721 token ID of the leverage position.
    /// @return _lockStatus The lock status of the leverage position.
    function isLocked(uint256 _tokenId) public view override returns (bool _lockStatus) {
        return _lockCounter[_tokenId].lockCount > 0;
    }

    /// @notice Returns the lock status of a leverage NFT position by a module.
    /// @dev Note that when a position NFT is burned, the individual locks are not cleared.
    ///      Meaning, the lock count is set to 0 but individual lockedByModule statuses are not cleared.
    ///      So when lockedByModule is true but lock owner is address(0) then it means the position was deleted.
    /// @param _tokenId The ERC721 token ID of the leverage position.
    /// @param _moduleKey The module key to check if a module locked the NFT previously or not.
    /// @return _lockedByModuleStatus The lock status of the leverage position by the module.
    function isLockedByModule(
        uint256 _tokenId,
        bytes32 _moduleKey
    ) public view override returns (bool _lockedByModuleStatus) {
        return _lockCounter[_tokenId].lockedByModule[_moduleKey] && _ownerOf(_tokenId) != address(0);
    }

    /// @notice Returns a summary of a leverage position.
    /// @param _tokenId The ERC721 token ID of the leverage position.
    /// @return _positionSummary The summary of the leverage position.
    function getPositionSummary(
        uint256 _tokenId
    ) public view returns (FlatcoinStructs.PositionSummary memory _positionSummary) {
        FlatcoinStructs.Position memory position = vault.getPosition(_tokenId);
        FlatcoinStructs.VaultSummary memory vaultSummary = vault.getVaultSummary();

        (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice();

        // Get the nextFundingEntry for the market.
        int256 nextFundingEntry = PerpMath._nextFundingEntry(
            vaultSummary,
            vault.maxFundingVelocity(),
            vault.maxVelocitySkew()
        );

        return PerpMath._getPositionSummary(position, nextFundingEntry, currentPrice);
    }

    /// @notice Returns a summary of the market.
    /// @dev This includes all the parameters which are related mostly with the leverage traders.
    /// @return _marketSummary The summary of the market.
    function getMarketSummary() public view returns (FlatcoinStructs.MarketSummary memory _marketSummary) {
        FlatcoinStructs.VaultSummary memory vaultSummary = vault.getVaultSummary();

        (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice();

        return
            PerpMath._getMarketSummaryLongs(
                vaultSummary,
                vault.maxFundingVelocity(),
                vault.maxVelocitySkew(),
                currentPrice
            );
    }

    /// @notice Returns the total profit and loss of all the leverage positions.
    /// @dev Adjusts for the funding fees accrued.
    /// @return _fundingAdjustedPnL The total profit and loss of all the leverage positions.
    function fundingAdjustedLongPnLTotal() public view returns (int256 _fundingAdjustedPnL) {
        return fundingAdjustedLongPnLTotal({_maxAge: type(uint32).max, _priceDiffCheck: false});
    }

    /// @notice Returns the total profit and loss of all the leverage positions.
    /// @dev Adjusts for the funding fees accrued.
    /// @param _maxAge The maximum age of the oracle price to be used.
    /// @return _fundingAdjustedPnL The total profit and loss of all the leverage positions.
    function fundingAdjustedLongPnLTotal(
        uint32 _maxAge,
        bool _priceDiffCheck
    ) public view returns (int256 _fundingAdjustedPnL) {
        (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
            maxAge: _maxAge,
            priceDiffCheck: _priceDiffCheck
        });

        FlatcoinStructs.VaultSummary memory vaultSummary = vault.getVaultSummary();
        FlatcoinStructs.MarketSummary memory marketSummary = PerpMath._getMarketSummaryLongs(
            vaultSummary,
            vault.maxFundingVelocity(),
            vault.maxVelocitySkew(),
            currentPrice
        );

        return marketSummary.profitLossTotalByLongs + marketSummary.accruedFundingTotalByLongs;
    }

    /// @notice Asserts that the position to be opened meets margin and size criteria.
    /// @param _margin The margin to be deposited.
    /// @param _size The size of the position.
    function checkLeverageCriteria(uint256 _margin, uint256 _size) public view {
        uint256 leverage = ((_margin + _size) * 1e18) / _margin;

        if (leverage < leverageMin) revert FlatcoinErrors.LeverageTooLow(leverageMin, leverage);
        if (leverage > leverageMax) revert FlatcoinErrors.LeverageTooHigh(leverageMax, leverage);
        if (_margin < marginMin) revert FlatcoinErrors.MarginTooSmall(marginMin, _margin);
    }

    /// @notice Returns the trade fee for a given size.
    /// @param _size The size of the trade.
    /// @return _tradeFee The trade fee.
    function getTradeFee(uint256 _size) external view returns (uint256 _tradeFee) {
        return leverageTradingFee._multiplyDecimal(_size);
    }

    /////////////////////////////////////////////
    //       Internal/Private Functions        //
    /////////////////////////////////////////////

    /// @notice Handles incrementing the tokenIdNext and minting the nft
    /// @param _to the minter's address
    /// @return _tokenId the tokenId of the new NFT.
    function _mint(address _to) internal returns (uint256 _tokenId) {
        _tokenId = tokenIdNext;

        _safeMint(_to, tokenIdNext);

        tokenIdNext += 1;
    }

    /// @notice Returns the maximum age of the oracle price to be used.
    /// @param _executableAtTime The time at which the order is executable.
    /// @return _maxAge The maximum age of the oracle price to be used.
    function _getMaxAge(uint64 _executableAtTime) internal view returns (uint32 _maxAge) {
        return (block.timestamp - _executableAtTime).toUint32();
    }

    /////////////////////////////////////////////
    //             Owner Functions             //
    /////////////////////////////////////////////

    /// @notice Setter for the leverage open/close fee.
    /// @dev Fees can be set to 0 if needed.
    /// @param _leverageTradingFee The new leverage trading fee.
    function setLeverageTradingFee(uint256 _leverageTradingFee) public onlyOwner {
        // Set fee cap to max 1%.
        // This is to avoid fat fingering but if any change is needed, the owner needs to
        // upgrade this module.
        if (_leverageTradingFee > 0.01e18) revert FlatcoinErrors.InvalidFee(_leverageTradingFee);

        leverageTradingFee = _leverageTradingFee;
    }

    /// @notice Setter for the leverage position criteria limits.
    /// @dev The limits are used to ensure that the position is valuable and there is an incentive to liquidate it.
    /// @param _marginMin The new minimum margin limit.
    /// @param _leverageMin The new minimum leverage limit.
    /// @param _leverageMax The new maximum leverage limit.
    function setLeverageCriteria(uint256 _marginMin, uint256 _leverageMin, uint256 _leverageMax) public onlyOwner {
        if (_leverageMax <= _leverageMin) revert FlatcoinErrors.InvalidLeverageCriteria();

        marginMin = _marginMin;
        leverageMin = _leverageMin;
        leverageMax = _leverageMax;
    }
}
