
# Flat Money Fix Review Contest contest details

- Join [Sherlock Discord](https://discord.gg/MABEWyASkp)
- Submit findings using the issue page in your private contest repo (label issues as med or high)
- [Read for more details](https://docs.sherlock.xyz/audits/watsons)

# Q&A

### Q: On what chains are the smart contracts going to be deployed?
Base
___

### Q: If you are integrating tokens, are you allowing only whitelisted tokens to work with the codebase or any complying with the standard? Are they assumed to have certain properties, e.g. be non-reentrant? Are there any types of <a href="https://github.com/d-xo/weird-erc20" target="_blank" rel="noopener noreferrer">weird tokens</a> you want to integrate?
External ERC20: rETH on Base
___

### Q: Are the admins of the protocols your contracts integrate with (if any) TRUSTED or RESTRICTED? If these integrations are trusted, should auditors also assume they are always responsive, for example, are oracles trusted to provide non-stale information, or VRF providers to respond within a designated timeframe?
Trusted:
- rETH token
- Pyth network oracle for rETH and onchain (Chainlink) oracle for rETH.
___

### Q: Are there any protocol roles? Please list them and provide whether they are TRUSTED or RESTRICTED, or provide a more comprehensive description of what a role can and can't do/impact.
Trusted owner role. Owner is a Gnosis Safe multisig.
___

### Q: For permissioned functions, please list all checks and requirements that will be made before calling the function.
The only permissioned functions are related to owner-only setter functions. These are usually clearly defined as the last section of functions in all modules.
___

### Q: Is the codebase expected to comply with any EIPs? Can there be/are there any deviations from the specification?
No compliance is necessary. We have a special implementation for ERC20 and ERC721 for stable side tokens (UNIT) and leverage positions (leverage NFTs) respectively but we are not strict about adhering to these ERCs ourselves.
___

### Q: Are there any off-chain mechanisms or off-chain procedures for the protocol (keeper bots, arbitrage bots, etc.)?
- There are keepers for order execution and liquidations. As long as the Pyth price they are using is fresh enough (as defined in the OracleModule), we are ok with any arbitrage issues that might occur. Ultimately, we want the feasibility of these arbitrage attacks to be high and likely to occur often.

- Pyth network oracles for rETH price updates.
___

### Q: Are there any hardcoded values that you intend to change before (some) deployments?
N/A
___

### Q: If the codebase is to be deployed on an L2, what should be the behavior of the protocol in case of sequencer issues (if applicable)? Should Sherlock assume that the Sequencer won't misbehave, including going offline?
Base L2. We don't consider that sequencer issues such as downtime are relevant or valid issues. There is very little we can do about the sequencer being down as someone will always be affected in the two-sided market of our protocol.
___

### Q: Should potential issues, like broken assumptions about function behavior, be reported if they could pose risks in future integrations, even if they might not be an issue in the context of the scope? If yes, can you elaborate on properties/invariants that should hold?
- Yes any broken function assumptions should be reported.

- The protocol has hardcoded invariant checks in `InvariantChecks.sol`. If these can be made to revert, then we should know about it.
___

### Q: Please discuss any design choices you made.
Can refer to the previous audit issues for details.
___

### Q: Please list any known issues/acceptable risks that should not result in a valid finding.
UNIT can decrease in dollar value when funding rates are negative and protocol fees don't cover the losses. This is acceptable.

UNIT can be net short and ETH goes up 5x in a short period of time, potentially leading to UNIT going to 0.
The UNIT holders should be mostly delta neutral, but they may be up to 20% short in certain market conditions (`skewFractionMax` parameter).
The funding rate should balance this out, but theoretically, if ETH price increases by 5x in a short period of time whilst the UNIT holders are 20% short, it's possible for UNIT value to go to 0. This scenario is deemed to be extremely unlikely and the funding rate is able to move quickly enough to bring the UNIT holders back to delta neutral.

When long max skew (`skewFractionMax`) is reached, UNIT holders cannot withdraw, and no new leverage positions can be opened.
This is to prevent the UNIT holders being increasingly short. This is temporary because the funding rate will bring the skew back to 0 and create more room for UNIT holders to withdraw and leverage traders to open positions.
___

### Q: We will report issues where the core protocol functionality is inaccessible for at least 7 days. Would you like to override this value?
No, we agree with the reasoning provided in the question explanation.
___

### Q: Please provide links to previous audits (if any).
https://audits.sherlock.xyz/contests/132
___

### Q: Please list any relevant protocol resources.
Flat Money docs: https://docs.flat.money
RocketPool depository: https://github.com/rocket-pool/rocketpool/tree/master
rETH token on Base: https://basescan.org/token/0xb6fe221fe9eef5aba221c348ba20a1bf5e73624c#code
___

### Q: Additional audit information.
Intent is to focus on the fixes from the previous Sherlock audit.

The following diff contains all changes since the last Sherlock Audit.

```diff
diff --git a/src/DelayedOrder.sol b/src/DelayedOrder.sol
index c5964bf..abe09cd 100644
--- a/src/DelayedOrder.sol
+++ b/src/DelayedOrder.sol
@@ -1,10 +1,10 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {SafeERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
-import {ReentrancyGuardUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
-import {IERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/interfaces/IERC20Upgradeable.sol";
-import {SignedMath} from "openzeppelin-contracts/contracts/utils/math/SignedMath.sol";
+import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
+import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
+import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
+import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
 
 import {FlatcoinStructs} from "./libraries/FlatcoinStructs.sol";
 import {FlatcoinErrors} from "./libraries/FlatcoinErrors.sol";
@@ -33,8 +33,8 @@ contract DelayedOrder is
     InvariantChecks,
     OracleModifiers
 {
-    using SafeERC20Upgradeable for IERC20Upgradeable;
-    using SafeERC20Upgradeable for IStableModule;
+    using SafeERC20 for IERC20;
+    using SafeERC20 for IStableModule;
     using SignedMath for int256;
 
     /// @notice Minimum deposit amount for stable LP collateral.
@@ -115,7 +115,7 @@ contract DelayedOrder is
         uint64 executableAtTime = _prepareAnnouncementOrder(keeperFee);
 
         IStableModule stableModule = IStableModule(vault.moduleAddress(FlatcoinModuleKeys._STABLE_MODULE_KEY));
-        uint256 lpBalance = IERC20Upgradeable(stableModule).balanceOf(msg.sender);
+        uint256 lpBalance = IERC20(stableModule).balanceOf(msg.sender);
 
         if (lpBalance < withdrawAmount)
             revert FlatcoinErrors.NotEnoughBalanceForWithdraw(msg.sender, lpBalance, withdrawAmount);
@@ -390,16 +390,16 @@ contract DelayedOrder is
         updatePythPrice(vault, msg.sender, priceUpdateData)
         orderInvariantChecks(vault)
     {
-        // Settle funding fees before executing any order.
-        // This is to avoid error related to max caps or max skew reached when the market has been skewed to one side for a long time.
-        // This is more important in case the we allow for limit orders in the future.
-        vault.settleFundingFees();
-
         FlatcoinStructs.OrderType orderType = _announcedOrder[account].orderType;
 
         // If there is no order in store, just return.
         if (orderType == FlatcoinStructs.OrderType.None) return;
 
+        // Settle funding fees before executing any order.
+        // This is to avoid error related to max caps or max skew reached when the market has been skewed to one side for a long time.
+        // This is more important in case the we allow for limit orders in the future.
+        vault.settleFundingFees();
+
         if (orderType == FlatcoinStructs.OrderType.StableDeposit) {
             _executeStableDeposit(account);
         } else if (orderType == FlatcoinStructs.OrderType.StableWithdraw) {
diff --git a/src/FlatcoinVault.sol b/src/FlatcoinVault.sol
index 23c5c22..1043a6c 100644
--- a/src/FlatcoinVault.sol
+++ b/src/FlatcoinVault.sol
@@ -1,10 +1,10 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
-import {SafeERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
-import {SafeCastUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/utils/math/SafeCastUpgradeable.sol";
-import {IERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";
+import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
+import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
+import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
+import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
 
 import {FlatcoinErrors} from "./libraries/FlatcoinErrors.sol";
 import {FlatcoinStructs} from "./libraries/FlatcoinStructs.sol";
@@ -18,11 +18,11 @@ import {IFlatcoinVault} from "./interfaces/IFlatcoinVault.sol";
 /// @dev Holds the stable LP deposits and leverage traders' collateral amounts.
 ///      Also stores other related contract address pointers.
 contract FlatcoinVault is IFlatcoinVault, OwnableUpgradeable {
-    using SafeCastUpgradeable for *;
-    using SafeERC20Upgradeable for IERC20Upgradeable;
+    using SafeCast for *;
+    using SafeERC20 for IERC20;
 
     /// @notice The collateral token address.
-    IERC20Upgradeable public collateral;
+    IERC20 public collateral;
 
     /// @notice The last market skew recomputation timestamp.
     uint64 public lastRecomputedFundingTimestamp;
@@ -98,7 +98,6 @@ contract FlatcoinVault is IFlatcoinVault, OwnableUpgradeable {
     }
 
     /// @notice Function to initialize this contract.
-    /// @param _owner The owner of this contract.
     /// @param _collateral The collateral token address.
     /// @param _maxFundingVelocity The maximum funding velocity used to limit the funding rate fluctuations.
     /// @param _maxVelocitySkew The skew percentage at which the funding rate velocity is at its maximum.
@@ -107,8 +106,7 @@ contract FlatcoinVault is IFlatcoinVault, OwnableUpgradeable {
     /// @param _minExecutabilityAge The minimum time that needs to expire between trade announcement and execution.
     /// @param _maxExecutabilityAge The maximum amount of time that can expire between trade announcement and execution.
     function initialize(
-        address _owner,
-        IERC20Upgradeable _collateral,
+        IERC20 _collateral,
         uint256 _maxFundingVelocity,
         uint256 _maxVelocitySkew,
         uint256 _skewFractionMax,
@@ -117,17 +115,21 @@ contract FlatcoinVault is IFlatcoinVault, OwnableUpgradeable {
         uint64 _maxExecutabilityAge
     ) external initializer {
         if (address(_collateral) == address(0)) revert FlatcoinErrors.ZeroAddress("collateral");
+        if (_skewFractionMax < 1e18) revert FlatcoinErrors.InvalidSkewFractionMax(_skewFractionMax);
+        if (_maxVelocitySkew > 1e18 || _maxVelocitySkew == 0)
+            revert FlatcoinErrors.InvalidMaxVelocitySkew(_maxVelocitySkew);
+        if (_minExecutabilityAge == 0 || _maxExecutabilityAge == 0)
+            revert FlatcoinErrors.ZeroValue("minExecutabilityAge|maxExecutabilityAge");
 
-        __Ownable_init();
-        _transferOwnership(_owner);
+        __Ownable_init(msg.sender);
 
         collateral = _collateral;
-
-        setMaxFundingVelocity(_maxFundingVelocity);
-        setMaxVelocitySkew(_maxVelocitySkew);
-        setStableCollateralCap(_stableCollateralCap);
-        setSkewFractionMax(_skewFractionMax);
-        setExecutabilityAge(_minExecutabilityAge, _maxExecutabilityAge);
+        maxFundingVelocity = _maxFundingVelocity;
+        maxVelocitySkew = _maxVelocitySkew;
+        stableCollateralCap = _stableCollateralCap;
+        skewFractionMax = _skewFractionMax;
+        minExecutabilityAge = _minExecutabilityAge;
+        maxExecutabilityAge = _maxExecutabilityAge;
     }
 
     /////////////////////////////////////////////
@@ -426,8 +428,8 @@ contract FlatcoinVault is IFlatcoinVault, OwnableUpgradeable {
     /// @param _minExecutabilityAge The minimum time that needs to expire between trade announcement and execution.
     /// @param _maxExecutabilityAge The maximum amount of time that can expire between trade announcement and execution.
     function setExecutabilityAge(uint64 _minExecutabilityAge, uint64 _maxExecutabilityAge) public onlyOwner {
-        if (_minExecutabilityAge == 0) revert FlatcoinErrors.ZeroValue("minExecutabilityAge");
-        if (_maxExecutabilityAge == 0) revert FlatcoinErrors.ZeroValue("maxExecutabilityAge");
+        if (_minExecutabilityAge == 0 || _maxExecutabilityAge == 0)
+            revert FlatcoinErrors.ZeroValue("minExecutabilityAge|maxExecutabilityAge");
 
         minExecutabilityAge = _minExecutabilityAge;
         maxExecutabilityAge = _maxExecutabilityAge;
diff --git a/src/LeverageModule.sol b/src/LeverageModule.sol
index 11457da..746d42b 100644
--- a/src/LeverageModule.sol
+++ b/src/LeverageModule.sol
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {SafeCastUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/utils/math/SafeCastUpgradeable.sol";
+import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
 import {ERC721LockableEnumerableUpgradeable} from "./misc/ERC721LockableEnumerableUpgradeable.sol";
 
 import {DecimalMath} from "./libraries/DecimalMath.sol";
@@ -24,7 +24,7 @@ import {ILimitOrder} from "./interfaces/ILimitOrder.sol";
 /// @notice Contains functions to create/manage leverage positions.
 /// @dev This module shouldn't hold any funds but can direct the vault to transfer funds.
 contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnumerableUpgradeable {
-    using SafeCastUpgradeable for *;
+    using SafeCast for *;
     using DecimalMath for uint256;
 
     /// @notice ERC721 token ID increment on mint.
@@ -60,7 +60,7 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
         uint256 _leverageMax
     ) external initializer {
         __Module_init(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY, _vault);
-        __ERC721_init("Flatmoney Leveraged Positions", "LEV");
+        __ERC721_init("Flat Money Leveraged Positions", "LEV");
 
         setLeverageTradingFee(_levTradingFee);
         setLeverageCriteria(_marginMin, _leverageMin, _leverageMax);
@@ -92,7 +92,8 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
 
         // Check that buy price doesn't exceed requested price.
         (uint256 entryPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
-            maxAge: maxAge
+            maxAge: maxAge,
+            priceDiffCheck: true
         });
 
         if (entryPrice > announcedOpen.maxFillPrice)
@@ -164,7 +165,8 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
         FlatcoinStructs.Position memory position = vault.getPosition(announcedAdjust.tokenId);
 
         (uint256 adjustPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
-            maxAge: maxAge
+            maxAge: maxAge,
+            priceDiffCheck: true
         });
 
         int256 cumulativeFunding = vault.cumulativeFundingRate();
@@ -286,7 +288,7 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
             vault.sendCollateral({to: _account, amount: marginToWithdraw});
         }
 
-        emit FlatcoinEvents.LeverageAdjust(announcedAdjust.tokenId, adjustPrice);
+        emit FlatcoinEvents.LeverageAdjust(announcedAdjust.tokenId, newEntryPrice, adjustPrice);
     }
 
     /// @notice Leverage close function.
@@ -313,7 +315,8 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
 
         // check that sell price doesn't exceed requested price
         (uint256 exitPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
-            maxAge: maxAge
+            maxAge: maxAge,
+            priceDiffCheck: true
         });
         if (exitPrice < announcedClose.minFillPrice)
             revert FlatcoinErrors.HighSlippage(exitPrice, announcedClose.minFillPrice);
@@ -380,14 +383,6 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
         _unlock(_tokenId, _moduleKey);
     }
 
-    /// @notice Clears all locks of a token ID.
-    /// @dev Warning:
-    /// @param _tokenId The ERC721 token ID of the leverage position.
-    /// @param _moduleKey The module key which is unlocking the token.
-    function clearAllLocks(uint256 _tokenId, bytes32 _moduleKey) public onlyAuthorizedModule {
-        _clearAllLocks(_tokenId, _moduleKey);
-    }
-
     /////////////////////////////////////////////
     //             View Functions              //
     /////////////////////////////////////////////
@@ -399,6 +394,20 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
         return _lockCounter[_tokenId].lockCount > 0;
     }
 
+    /// @notice Returns the lock status of a leverage NFT position by a module.
+    /// @dev Note that when a position NFT is burned, the individual locks are not cleared.
+    ///      Meaning, the lock count is set to 0 but individual lockedByModule statuses are not cleared.
+    ///      So when lockedByModule is true but lock owner is address(0) then it means the position was deleted.
+    /// @param _tokenId The ERC721 token ID of the leverage position.
+    /// @param _moduleKey The module key to check if a module locked the NFT previously or not.
+    /// @return _lockedByModuleStatus The lock status of the leverage position by the module.
+    function isLockedByModule(
+        uint256 _tokenId,
+        bytes32 _moduleKey
+    ) public view override returns (bool _lockedByModuleStatus) {
+        return _lockCounter[_tokenId].lockedByModule[_moduleKey] && _ownerOf(_tokenId) != address(0);
+    }
+
     /// @notice Returns a summary of a leverage position.
     /// @param _tokenId The ERC721 token ID of the leverage position.
     /// @return _positionSummary The summary of the leverage position.
@@ -450,7 +459,8 @@ contract LeverageModule is ILeverageModule, ModuleUpgradeable, ERC721LockableEnu
     /// @return _fundingAdjustedPnL The total profit and loss of all the leverage positions.
     function fundingAdjustedLongPnLTotal(uint32 _maxAge) public view returns (int256 _fundingAdjustedPnL) {
         (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
-            maxAge: _maxAge
+            maxAge: _maxAge,
+            priceDiffCheck: true
         });
 
         FlatcoinStructs.VaultSummary memory vaultSummary = vault.getVaultSummary();
diff --git a/src/LimitOrder.sol b/src/LimitOrder.sol
index 2fc9853..9385b59 100644
--- a/src/LimitOrder.sol
+++ b/src/LimitOrder.sol
@@ -1,10 +1,8 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {SafeERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
-import {ReentrancyGuardUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
-import {IERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/interfaces/IERC20Upgradeable.sol";
-import {SignedMath} from "openzeppelin-contracts/contracts/utils/math/SignedMath.sol";
+import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
+import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
 
 import {FlatcoinStructs} from "./libraries/FlatcoinStructs.sol";
 import {FlatcoinErrors} from "./libraries/FlatcoinErrors.sol";
@@ -17,7 +15,6 @@ import {InvariantChecks} from "./misc/InvariantChecks.sol";
 import {ILimitOrder} from "./interfaces/ILimitOrder.sol";
 import {IFlatcoinVault} from "./interfaces/IFlatcoinVault.sol";
 import {ILeverageModule} from "./interfaces/ILeverageModule.sol";
-import {IStableModule} from "./interfaces/IStableModule.sol";
 import {IOracleModule} from "./interfaces/IOracleModule.sol";
 import {IKeeperFee} from "./interfaces/IKeeperFee.sol";
 
@@ -25,10 +22,10 @@ import {IKeeperFee} from "./interfaces/IKeeperFee.sol";
 /// @author dHEDGE
 /// @notice Module to create limit orders.
 contract LimitOrder is ILimitOrder, ModuleUpgradeable, ReentrancyGuardUpgradeable, InvariantChecks, OracleModifiers {
-    using SafeERC20Upgradeable for IERC20Upgradeable;
-    using SafeERC20Upgradeable for IStableModule;
     using SignedMath for int256;
 
+    mapping(uint256 tokenId => FlatcoinStructs.Order order) internal _limitOrderClose;
+
     /// @dev To prevent the implementation contract from being used, we invoke the _disableInitializers
     ///      function in the constructor to automatically lock it when it is deployed.
     /// @custom:oz-upgrades-unsafe-allow constructor
@@ -36,8 +33,6 @@ contract LimitOrder is ILimitOrder, ModuleUpgradeable, ReentrancyGuardUpgradeabl
         _disableInitializers();
     }
 
-    mapping(uint256 tokenId => FlatcoinStructs.Order order) internal _limitOrderClose;
-
     /// @notice Function to initialize this contract.
     function initialize(IFlatcoinVault _vault) external initializer {
         __Module_init(FlatcoinModuleKeys._LIMIT_ORDER_KEY, _vault);
@@ -71,11 +66,12 @@ contract LimitOrder is ILimitOrder, ModuleUpgradeable, ReentrancyGuardUpgradeabl
             executableAtTime: executableAtTime
         });
 
+        ILeverageModule leverageModule = ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY));
+
         // Lock the NFT belonging to this position so that it can't be transferred to someone else.
-        ILeverageModule(vault.moduleAddress(FlatcoinModuleKeys._LEVERAGE_MODULE_KEY)).lock(
-            tokenId,
-            FlatcoinModuleKeys._LIMIT_ORDER_KEY
-        );
+        // Since this function is also used to modify an existing limit order, we need to check if it's already locked.
+        if (!leverageModule.isLockedByModule(tokenId, FlatcoinModuleKeys._LIMIT_ORDER_KEY))
+            leverageModule.lock(tokenId, FlatcoinModuleKeys._LIMIT_ORDER_KEY);
 
         emit FlatcoinEvents.LimitOrderAnnounced({
             account: positionOwner,
diff --git a/src/LiquidationModule.sol b/src/LiquidationModule.sol
index bcbc2de..987d980 100644
--- a/src/LiquidationModule.sol
+++ b/src/LiquidationModule.sol
@@ -1,8 +1,7 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
-import {ReentrancyGuardUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
+import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
 
 import {ModuleUpgradeable} from "./abstracts/ModuleUpgradeable.sol";
 import {OracleModifiers} from "./abstracts/OracleModifiers.sol";
@@ -24,7 +23,6 @@ import {ILimitOrder} from "./interfaces/ILimitOrder.sol";
 /// @notice Module for liquidating leveraged positions.
 contract LiquidationModule is
     ILiquidationModule,
-    Initializable,
     ModuleUpgradeable,
     OracleModifiers,
     ReentrancyGuardUpgradeable,
@@ -62,6 +60,7 @@ contract LiquidationModule is
         uint256 _liquidationFeeUpperBound
     ) external initializer {
         __Module_init(FlatcoinModuleKeys._LIQUIDATION_MODULE_KEY, _vault);
+        __ReentrancyGuard_init();
 
         setLiquidationFeeRatio(_liquidationFeeRatio);
         setLiquidationBufferRatio(_liquidationBufferRatio);
@@ -85,7 +84,10 @@ contract LiquidationModule is
     function liquidate(uint256 tokenId) public nonReentrant whenNotPaused liquidationInvariantChecks(vault, tokenId) {
         FlatcoinStructs.Position memory position = vault.getPosition(tokenId);
 
-        (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice();
+        (uint256 currentPrice, ) = IOracleModule(vault.moduleAddress(FlatcoinModuleKeys._ORACLE_MODULE_KEY)).getPrice({
+            maxAge: 86_400,
+            priceDiffCheck: true
+        });
 
         // Settle funding fees accrued till now.
         vault.settleFundingFees();
diff --git a/src/OracleModule.sol b/src/OracleModule.sol
index b8d42fb..e60ea4f 100644
--- a/src/OracleModule.sol
+++ b/src/OracleModule.sol
@@ -1,11 +1,9 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {ReentrancyGuardUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
-import {SafeERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
-import {SafeCastUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/utils/math/SafeCastUpgradeable.sol";
-import {IERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/interfaces/IERC20Upgradeable.sol";
-import {SignedMath} from "openzeppelin-contracts/contracts/utils/math/SignedMath.sol";
+import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
+import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
+import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
 import {PythStructs} from "pyth-sdk-solidity/PythStructs.sol";
 
 import {FlatcoinErrors} from "./libraries/FlatcoinErrors.sol";
@@ -23,8 +21,7 @@ import {IChainlinkAggregatorV3} from "./interfaces/IChainlinkAggregatorV3.sol";
 /// @notice Can query collateral oracle price.
 /// @dev Interfaces with onchain and offchain oracles (eg. Chainlink and Pyth network).
 contract OracleModule is IOracleModule, ModuleUpgradeable, ReentrancyGuardUpgradeable {
-    using SafeCastUpgradeable for *;
-    using SafeERC20Upgradeable for IERC20Upgradeable;
+    using SafeCast for *;
     using SignedMath for int256;
 
     address public asset; // Asset to price
@@ -81,15 +78,15 @@ contract OracleModule is IOracleModule, ModuleUpgradeable, ReentrancyGuardUpgrad
     /// @return price The latest 18 decimal price of asset.
     /// @return timestamp The timestamp of the latest price.
     function getPrice() public view returns (uint256 price, uint256 timestamp) {
-        (price, timestamp) = _getPrice(type(uint32).max);
+        (price, timestamp) = _getPrice(type(uint32).max, false);
     }
 
     /// @notice The same as getPrice() but it includes maximum acceptable oracle timestamp input parameter.
     /// @param maxAge Oldest acceptable oracle price.
     /// @return price The latest 18 decimal price of asset.
     /// @return timestamp The timestamp of the latest price.
-    function getPrice(uint32 maxAge) public view returns (uint256 price, uint256 timestamp) {
-        (price, timestamp) = _getPrice(maxAge);
+    function getPrice(uint32 maxAge, bool priceDiffCheck) public view returns (uint256 price, uint256 timestamp) {
+        (price, timestamp) = _getPrice(maxAge, priceDiffCheck);
     }
 
     /////////////////////////////////////////////
@@ -100,15 +97,20 @@ contract OracleModule is IOracleModule, ModuleUpgradeable, ReentrancyGuardUpgrad
     /// @dev It verifies the Pyth network price against Chainlink price (ensure that it is within a threshold).
     /// @return price The latest 18 decimal price of asset.
     /// @return timestamp The timestamp of the latest price.
-    function _getPrice(uint32 maxAge) internal view returns (uint256 price, uint256 timestamp) {
+    function _getPrice(uint32 maxAge, bool priceDiffCheck) internal view returns (uint256 price, uint256 timestamp) {
         (uint256 onchainPrice, uint256 onchainTime) = _getOnchainPrice(); // will revert if invalid
         (uint256 offchainPrice, uint256 offchainTime, bool offchainInvalid) = _getOffchainPrice();
         bool offchain;
 
         if (offchainInvalid == false) {
-            uint256 priceDiff = (int256(onchainPrice) - int256(offchainPrice)).abs();
-            uint256 diffPercent = (priceDiff * 1e18) / (onchainPrice < offchainPrice ? onchainPrice : offchainPrice);
-            if (diffPercent > maxDiffPercent) revert FlatcoinErrors.PriceMismatch(diffPercent);
+            if (priceDiffCheck) {
+                // If the price is not time sensitive (not used for order exeucution),
+                // then we don't need to check the price difference between onchain and offchain
+                uint256 priceDiff = (int256(onchainPrice) - int256(offchainPrice)).abs();
+                uint256 diffPercent = (priceDiff * 1e18) /
+                    (onchainPrice < offchainPrice ? onchainPrice : offchainPrice);
+                if (diffPercent > maxDiffPercent) revert FlatcoinErrors.PriceMismatch(diffPercent);
+            }
 
             // return the freshest price
             if (offchainTime >= onchainTime) {
diff --git a/src/PointsModule.sol b/src/PointsModule.sol
index 6d17917..d5d4d69 100644
--- a/src/PointsModule.sol
+++ b/src/PointsModule.sol
@@ -1,8 +1,8 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
-import {SafeCastUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/utils/math/SafeCastUpgradeable.sol";
+import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
+import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
 
 import {ModuleUpgradeable} from "./abstracts/ModuleUpgradeable.sol";
 import {DecimalMath} from "./libraries/DecimalMath.sol";
@@ -17,10 +17,15 @@ import {IFlatcoinVault} from "./interfaces/IFlatcoinVault.sol";
 /// @author dHEDGE
 /// @notice Module for awarding points as an incentive.
 contract PointsModule is ModuleUpgradeable, ERC20LockableUpgradeable {
-    using SafeCastUpgradeable for uint256;
+    using SafeCast for uint256;
     using DecimalMath for uint256;
     using Math for uint64;
 
+    struct MintPoints {
+        address to;
+        uint256 amount;
+    }
+
     address public treasury;
 
     /// @notice The duration of the unlock tax vesting period
@@ -40,11 +45,6 @@ contract PointsModule is ModuleUpgradeable, ERC20LockableUpgradeable {
 
     uint256 public minMintAmount; // not constant in case we decide to change it in the future
 
-    struct MintPoints {
-        address to;
-        uint256 amount;
-    }
-
     /// @dev To prevent the implementation contract from being used, we invoke the _disableInitializers
     ///      function in the constructor to automatically lock it when it is deployed.
     /// @custom:oz-upgrades-unsafe-allow constructor
diff --git a/src/StableModule.sol b/src/StableModule.sol
index 1fe9923..f2f7bd3 100644
--- a/src/StableModule.sol
+++ b/src/StableModule.sol
@@ -1,9 +1,7 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {SafeERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
-import {SafeCastUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/utils/math/SafeCastUpgradeable.sol";
-import {IERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/interfaces/IERC20Upgradeable.sol";
+import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
 import {ERC20LockableUpgradeable} from "./misc/ERC20LockableUpgradeable.sol";
 
 import {PerpMath} from "./libraries/PerpMath.sol";
@@ -22,8 +20,7 @@ import {IPointsModule} from "./interfaces/IPointsModule.sol";
 /// @author dHEDGE
 /// @notice Contains functions to handle stable LP deposits and withdrawals.
 contract StableModule is IStableModule, ModuleUpgradeable, ERC20LockableUpgradeable {
-    using SafeCastUpgradeable for *;
-    using SafeERC20Upgradeable for IERC20Upgradeable;
+    using SafeCast for *;
     using PerpMath for int256;
     using PerpMath for uint256;
 
@@ -43,7 +40,7 @@ contract StableModule is IStableModule, ModuleUpgradeable, ERC20LockableUpgradea
     /// @notice Function to initialize this contract.
     function initialize(IFlatcoinVault _vault, uint256 _stableWithdrawFee) external initializer {
         __Module_init(FlatcoinModuleKeys._STABLE_MODULE_KEY, _vault);
-        __ERC20_init("Flatmoney", "UNIT");
+        __ERC20_init("Flat Money", "UNIT");
 
         setStableWithdrawFee(_stableWithdrawFee);
     }
diff --git a/src/abstracts/ModuleUpgradeable.sol b/src/abstracts/ModuleUpgradeable.sol
index 678807d..a99b14f 100644
--- a/src/abstracts/ModuleUpgradeable.sol
+++ b/src/abstracts/ModuleUpgradeable.sol
@@ -1,14 +1,15 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
+import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
+import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
 import {FlatcoinErrors} from "../libraries/FlatcoinErrors.sol";
 import {IFlatcoinVault} from "../interfaces/IFlatcoinVault.sol";
 
 /// @title ModuleUpgradeable
 /// @author dHEDGE
 /// @notice This is the base contract for all upgradeable modules in the Flatcoin system.
-abstract contract ModuleUpgradeable {
+abstract contract ModuleUpgradeable is Initializable {
     /// @notice The bytes32 encoded key of the module.
     /// @dev Note that this shouldn't change ever for existing modules.
     ///      Due to this module being upgradeable, we can't use immutable here.
diff --git a/src/abstracts/OracleModifiers.sol b/src/abstracts/OracleModifiers.sol
index b4cd685..a199a58 100644
--- a/src/abstracts/OracleModifiers.sol
+++ b/src/abstracts/OracleModifiers.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 import {IFlatcoinVault} from "../interfaces/IFlatcoinVault.sol";
 import {IOracleModule} from "../interfaces/IOracleModule.sol";
diff --git a/src/interfaces/IChainlinkAggregatorV3.sol b/src/interfaces/IChainlinkAggregatorV3.sol
index cfc7919..7afd860 100644
--- a/src/interfaces/IChainlinkAggregatorV3.sol
+++ b/src/interfaces/IChainlinkAggregatorV3.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: AGPL-3.0-only
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 interface IChainlinkAggregatorV3 {
     function decimals() external view returns (uint8 decimals);
diff --git a/src/interfaces/IDelayedOrder.sol b/src/interfaces/IDelayedOrder.sol
index 730f51c..f8b294d 100644
--- a/src/interfaces/IDelayedOrder.sol
+++ b/src/interfaces/IDelayedOrder.sol
@@ -1,5 +1,5 @@
-// SPDX-License-Identifier: UNLICENSED
-pragma solidity ^0.8.18;
+// SPDX-License-Identifier: SEE LICENSE IN LICENSE
+pragma solidity ^0.8.20;
 
 import {FlatcoinStructs} from "../libraries/FlatcoinStructs.sol";
 
diff --git a/src/interfaces/IFlatcoinVault.sol b/src/interfaces/IFlatcoinVault.sol
index 0c7e326..66f4635 100644
--- a/src/interfaces/IFlatcoinVault.sol
+++ b/src/interfaces/IFlatcoinVault.sol
@@ -1,11 +1,11 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity ^0.8.18;
+pragma solidity ^0.8.20;
 
-import {IERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/interfaces/IERC20Upgradeable.sol";
+import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 import {FlatcoinStructs} from "../libraries/FlatcoinStructs.sol";
 
 interface IFlatcoinVault {
-    function collateral() external view returns (IERC20Upgradeable collateral);
+    function collateral() external view returns (IERC20 collateral);
 
     function lastRecomputedFundingTimestamp() external view returns (uint64 lastRecomputedFundingTimestamp);
 
diff --git a/src/interfaces/IGasPriceOracle.sol b/src/interfaces/IGasPriceOracle.sol
index a06b769..45b025e 100644
--- a/src/interfaces/IGasPriceOracle.sol
+++ b/src/interfaces/IGasPriceOracle.sol
@@ -1,5 +1,5 @@
-// SPDX-License-Identifier: UNLICENSED
-pragma solidity 0.8.18;
+// SPDX-License-Identifier: SEE LICENSE IN LICENSE
+pragma solidity ^0.8.20;
 
 interface IGasPriceOracle {
     function baseFee() external view returns (uint256 _baseFee);
diff --git a/src/interfaces/IKeeperFee.sol b/src/interfaces/IKeeperFee.sol
index 3dc129b..63b1295 100644
--- a/src/interfaces/IKeeperFee.sol
+++ b/src/interfaces/IKeeperFee.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity ^0.8.18;
+pragma solidity ^0.8.20;
 
 interface IKeeperFee {
     function getKeeperFee() external view returns (uint256 keeperFee);
diff --git a/src/interfaces/ILeverageModule.sol b/src/interfaces/ILeverageModule.sol
index 34fcd9e..7b8f675 100644
--- a/src/interfaces/ILeverageModule.sol
+++ b/src/interfaces/ILeverageModule.sol
@@ -1,16 +1,10 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity ^0.8.18;
+pragma solidity ^0.8.20;
 
-import {IERC721EnumerableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/interfaces/IERC721EnumerableUpgradeable.sol";
+import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
 import {FlatcoinStructs} from "../libraries/FlatcoinStructs.sol";
 
-interface ILeverageModule is IERC721EnumerableUpgradeable {
-    function getPositionSummary(
-        uint256 tokenId
-    ) external view returns (FlatcoinStructs.PositionSummary memory positionSummary);
-
-    function isLocked(uint256 tokenId) external view returns (bool lockStatus);
-
+interface ILeverageModule is IERC721Enumerable {
     function executeOpen(
         address account,
         address keeper,
@@ -31,7 +25,13 @@ interface ILeverageModule is IERC721EnumerableUpgradeable {
 
     function unlock(uint256 tokenId, bytes32 moduleKey) external;
 
-    function clearAllLocks(uint256 tokenId, bytes32 moduleKey) external;
+    function isLocked(uint256 tokenId) external view returns (bool lockStatus);
+
+    function isLockedByModule(uint256 _tokenId, bytes32 _moduleKey) external view returns (bool _lockedByModuleStatus);
+
+    function getPositionSummary(
+        uint256 tokenId
+    ) external view returns (FlatcoinStructs.PositionSummary memory positionSummary);
 
     function fundingAdjustedLongPnLTotal() external view returns (int256 _fundingAdjustedPnL);
 
diff --git a/src/interfaces/ILimitOrder.sol b/src/interfaces/ILimitOrder.sol
index 047ffbc..6803a96 100644
--- a/src/interfaces/ILimitOrder.sol
+++ b/src/interfaces/ILimitOrder.sol
@@ -1,5 +1,5 @@
-// SPDX-License-Identifier: UNLICENSED
-pragma solidity ^0.8.18;
+// SPDX-License-Identifier: SEE LICENSE IN LICENSE
+pragma solidity ^0.8.20;
 
 import {FlatcoinStructs} from "../libraries/FlatcoinStructs.sol";
 
diff --git a/src/interfaces/ILiquidationModule.sol b/src/interfaces/ILiquidationModule.sol
index e27bda2..5a8e4a7 100644
--- a/src/interfaces/ILiquidationModule.sol
+++ b/src/interfaces/ILiquidationModule.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity ^0.8.18;
+pragma solidity ^0.8.20;
 
 interface ILiquidationModule {
     function canLiquidate(uint256 tokenId) external view returns (bool liquidatable);
diff --git a/src/interfaces/IOracleModule.sol b/src/interfaces/IOracleModule.sol
index 2ebca00..7a78e75 100644
--- a/src/interfaces/IOracleModule.sol
+++ b/src/interfaces/IOracleModule.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity ^0.8.18;
+pragma solidity ^0.8.20;
 
 import {IChainlinkAggregatorV3} from "./IChainlinkAggregatorV3.sol";
 
@@ -8,7 +8,7 @@ interface IOracleModule {
 
     function getPrice() external view returns (uint256 price, uint256 timestamp);
 
-    function getPrice(uint32 maxAge) external view returns (uint256 price, uint256 timestamp);
+    function getPrice(uint32 maxAge, bool priceDiffCheck) external view returns (uint256 price, uint256 timestamp);
 
     function updatePythPrice(address sender, bytes[] calldata priceUpdateData) external payable;
 }
diff --git a/src/interfaces/IPointsModule.sol b/src/interfaces/IPointsModule.sol
index 4a12053..165296b 100644
--- a/src/interfaces/IPointsModule.sol
+++ b/src/interfaces/IPointsModule.sol
@@ -1,5 +1,5 @@
-// SPDX-License-Identifier: UNLICENSED
-pragma solidity ^0.8.18;
+// SPDX-License-Identifier: SEE LICENSE IN LICENSE
+pragma solidity ^0.8.20;
 
 interface IPointsModule {
     struct MintPoints {
diff --git a/src/interfaces/IStableModule.sol b/src/interfaces/IStableModule.sol
index b7cc395..931e53e 100644
--- a/src/interfaces/IStableModule.sol
+++ b/src/interfaces/IStableModule.sol
@@ -1,11 +1,10 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity ^0.8.18;
+pragma solidity ^0.8.20;
 
-import {IERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/interfaces/IERC20Upgradeable.sol";
-import {IERC20MetadataUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
+import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
 import {FlatcoinStructs} from "../libraries/FlatcoinStructs.sol";
 
-interface IStableModule is IERC20Upgradeable, IERC20MetadataUpgradeable {
+interface IStableModule is IERC20Metadata {
     function stableCollateralPerShare() external view returns (uint256 collateralPerShare);
 
     function executeDeposit(
diff --git a/src/libraries/DecimalMath.sol b/src/libraries/DecimalMath.sol
index 6b4ebcf..a0b04de 100644
--- a/src/libraries/DecimalMath.sol
+++ b/src/libraries/DecimalMath.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: MIT
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 /// @title DecimalMath
 /// @author dHEDGE
@@ -7,7 +7,7 @@ pragma solidity 0.8.18;
 ///         and  <https://github.com/Synthetixio/synthetix/blob/cbd8666f4331ee95fcc667ec7345d13c8ba77efb/contracts/SafeDecimalMath.sol>
 /// @notice Library for fixed point math.
 // TODO: Explore if Solmate FixedPointMathLib can be used instead. <https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol>
-// solhint-disable named-return-values
+// solhint-disable gas-named-return-values
 library DecimalMath {
     /* Number of decimal places in the representations. */
     uint8 public constant DECIMALS = 18;
diff --git a/src/libraries/FlatcoinErrors.sol b/src/libraries/FlatcoinErrors.sol
index d208498..a1bfcb1 100644
--- a/src/libraries/FlatcoinErrors.sol
+++ b/src/libraries/FlatcoinErrors.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 library FlatcoinErrors {
     enum PriceSource {
diff --git a/src/libraries/FlatcoinEvents.sol b/src/libraries/FlatcoinEvents.sol
index ba38de4..b5f9ece 100644
--- a/src/libraries/FlatcoinEvents.sol
+++ b/src/libraries/FlatcoinEvents.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 import {FlatcoinStructs} from "./FlatcoinStructs.sol";
 
@@ -16,7 +16,7 @@ library FlatcoinEvents {
 
     event LeverageOpen(address account, uint256 tokenId, uint256 entryPrice);
 
-    event LeverageAdjust(uint256 tokenId, uint256 lastPrice);
+    event LeverageAdjust(uint256 tokenId, uint256 averagePrice, uint256 adjustPrice);
 
     event LeverageClose(uint256 tokenId, uint256 closePrice, FlatcoinStructs.PositionSummary positionSummary);
 
diff --git a/src/libraries/FlatcoinModuleKeys.sol b/src/libraries/FlatcoinModuleKeys.sol
index 9bf8f02..313cd69 100644
--- a/src/libraries/FlatcoinModuleKeys.sol
+++ b/src/libraries/FlatcoinModuleKeys.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 library FlatcoinModuleKeys {
     bytes32 internal constant _STABLE_MODULE_KEY = bytes32("stableModule");
diff --git a/src/libraries/FlatcoinStructs.sol b/src/libraries/FlatcoinStructs.sol
index 4b214b8..823a100 100644
--- a/src/libraries/FlatcoinStructs.sol
+++ b/src/libraries/FlatcoinStructs.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 import {IChainlinkAggregatorV3} from "../interfaces/IChainlinkAggregatorV3.sol";
 import {IPyth} from "pyth-sdk-solidity/IPyth.sol";
diff --git a/src/libraries/PerpMath.sol b/src/libraries/PerpMath.sol
index 6a2df9f..7ccccab 100644
--- a/src/libraries/PerpMath.sol
+++ b/src/libraries/PerpMath.sol
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {SignedMath} from "openzeppelin-contracts/contracts/utils/math/SignedMath.sol";
+import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
 import {DecimalMath} from "../libraries/DecimalMath.sol";
 import {FlatcoinStructs} from "../libraries/FlatcoinStructs.sol";
 
@@ -203,16 +203,14 @@ library PerpMath {
         int256 nextFundingEntry
     ) internal pure returns (int256 accruedFunding) {
         int256 net = _netFundingPerUnit(position.entryCumulativeFunding, nextFundingEntry);
-        int256 accruedFundingTimesTen = int256(position.additionalSize * 10)._multiplyDecimal(net);
 
-        if (accruedFundingTimesTen % 10 != 0) {
-            return accruedFundingTimesTen / 10 - 1;
-        } else {
-            return accruedFundingTimesTen / 10;
-        }
+        return int256(position.additionalSize)._multiplyDecimal(net);
     }
 
     /// @dev Calculates the funding fees accrued by the global position (all leverage traders).
+    ///      To avoid rounding errors when individual positions close and the global `marginDepositedTotal` is updated,
+    ///      we add 1 wei to the total accrued funding by longs. This also means that there might be some amount left in the
+    ///      vault belonging to the longs which is not distributed. This is insignificant and is a trade-off to avoid rounding errors.
     /// @param globalPosition The global position to calculate the funding fees accrued for.
     /// @param unrecordedFunding The sum of the unrecorded funding rates since the last funding re-computation.
     /// @return accruedFundingLongs The funding fees accrued by the global position (all leverage traders).
@@ -220,7 +218,9 @@ library PerpMath {
         FlatcoinStructs.GlobalPositions memory globalPosition,
         int256 unrecordedFunding
     ) internal pure returns (int256 accruedFundingLongs) {
-        return -int256(globalPosition.sizeOpenedTotal)._multiplyDecimal(unrecordedFunding);
+        int256 accruedFundingTotal = -int256(globalPosition.sizeOpenedTotal)._multiplyDecimal(unrecordedFunding);
+
+        return (accruedFundingTotal != 0) ? accruedFundingTotal + 1 : accruedFundingTotal;
     }
 
     /// @dev Summarises a positions' earnings/losses.
diff --git a/src/misc/ERC20LockableUpgradeable.sol b/src/misc/ERC20LockableUpgradeable.sol
index 0ba738f..c0a588b 100644
--- a/src/misc/ERC20LockableUpgradeable.sol
+++ b/src/misc/ERC20LockableUpgradeable.sol
@@ -1,17 +1,16 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {ERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
-import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
+import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
 
 // solhint-disable reason-string
-// solhint-disable custom-errors
-contract ERC20LockableUpgradeable is Initializable, ERC20Upgradeable {
+// solhint-disable gas-custom-errors
+contract ERC20LockableUpgradeable is ERC20Upgradeable {
+    mapping(address account => uint256 lockedAmount) internal _lockedAmount;
+
     event Locked(address indexed account, uint256 amount);
     event Unlocked(address indexed account, uint256 amount);
 
-    mapping(address account => uint256 lockedAmount) internal _lockedAmount;
-
     // solhint-disable-next-line func-name-mixedcase
     function __ERC20LockableUpgradeable_init()
         internal
@@ -42,7 +41,7 @@ contract ERC20LockableUpgradeable is Initializable, ERC20Upgradeable {
         emit Unlocked(account, amount);
     }
 
-    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
+    function _update(address from, address to, uint256 amount) internal virtual override {
         // Make sure the sender has enough unlocked tokens.
         // Note: the below requirement is not needed when minting tokens in which case the `from` address is 0x0.
         if (from != address(0)) {
@@ -52,7 +51,7 @@ contract ERC20LockableUpgradeable is Initializable, ERC20Upgradeable {
             );
         }
 
-        super._beforeTokenTransfer(from, to, amount);
+        super._update(from, to, amount);
     }
 
     uint256[49] private __gap;
diff --git a/src/misc/ERC721LockableEnumerableUpgradeable.sol b/src/misc/ERC721LockableEnumerableUpgradeable.sol
index ee87173..b2cb05b 100644
--- a/src/misc/ERC721LockableEnumerableUpgradeable.sol
+++ b/src/misc/ERC721LockableEnumerableUpgradeable.sol
@@ -1,15 +1,11 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {ERC721EnumerableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
+import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
 
 // solhint-disable reason-string
-// solhint-disable custom-errors
+// solhint-disable gas-custom-errors
 contract ERC721LockableEnumerableUpgradeable is ERC721EnumerableUpgradeable {
-    event Locked(uint256 indexed tokenId, bytes32 indexed moduleKey);
-    event Unlocked(uint256 indexed tokenId, bytes32 indexed moduleKey);
-    event UnlockedAllLocks(uint256 tokenId, bytes32 indexed moduleKey);
-
     struct LockData {
         uint8 lockCount;
         mapping(bytes32 moduleKeys => bool locked) lockedByModule;
@@ -19,6 +15,10 @@ contract ERC721LockableEnumerableUpgradeable is ERC721EnumerableUpgradeable {
     ///      A `tokenId` is locked if the `lockData.lockCount` value is greater than 0.
     mapping(uint256 tokenId => LockData lockData) internal _lockCounter;
 
+    event Locked(uint256 indexed tokenId, bytes32 indexed moduleKey);
+    event Unlocked(uint256 indexed tokenId, bytes32 indexed moduleKey);
+    event UnlockedAllLocks(uint256 tokenId, bytes32 indexed moduleKey);
+
     // solhint-disable-next-line func-name-mixedcase
     function __ERC721LockableEnumerableUpgradeable_init()
         internal
@@ -70,31 +70,25 @@ contract ERC721LockableEnumerableUpgradeable is ERC721EnumerableUpgradeable {
     }
 
     /// @notice Function to clear all locks of a token ID.
-    /// @dev Warning: This function has to be used with extreme caution and one of the places it can be used is when a token is being burned.
+    /// @dev Warning: This function should only be used before burning the token.
     /// @dev This function doesn't check if there are any locks or not as there is no point in doing so as we are going to clear all locks anyway.
     /// @dev We just emit the `moduleKey` which called this function for tracking purposes.
     function _clearAllLocks(uint256 tokenId, bytes32 moduleKey) internal virtual {
-        delete _lockCounter[tokenId];
+        _lockCounter[tokenId].lockCount = 0;
 
         emit UnlockedAllLocks(tokenId, moduleKey);
     }
 
     /// @notice Before token transfer hook.
     /// @dev Reverts if the token is locked. Make sure that when minting/burning a token it is unlocked.
-    /// @param from The address to transfer tokens from.
     /// @param to The address to transfer tokens to.
     /// @param tokenId The ERC721 token ID to transfer.
-    /// @param batchSize The number of tokens to transfer.
-    function _beforeTokenTransfer(
-        address from,
-        address to,
-        uint256 tokenId,
-        uint256 batchSize
-    ) internal virtual override {
+    /// @param auth See OZ _update function.
+    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address from) {
         // Make sure the token is not locked.
         require(_lockCounter[tokenId].lockCount == 0, "ERC721LockableEnumerableUpgradeable: token is locked");
 
-        super._beforeTokenTransfer(from, to, tokenId, batchSize);
+        return super._update(to, tokenId, auth);
     }
 
     uint256[49] private __gap;
diff --git a/src/misc/InvariantChecks.sol b/src/misc/InvariantChecks.sol
index 92c5c3f..70444e0 100644
--- a/src/misc/InvariantChecks.sol
+++ b/src/misc/InvariantChecks.sol
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
 import {FlatcoinErrors} from "../libraries/FlatcoinErrors.sol";
 import {FlatcoinModuleKeys} from "../libraries/FlatcoinModuleKeys.sol";
@@ -91,7 +91,6 @@ abstract contract InvariantChecks {
     /// @dev Returns the difference between actual total collateral balance in the vault vs tracked collateral
     ///      Tracked collateral should be updated when depositing to stable LP (stableCollateralTotal) or
     ///      opening leveraged positions (marginDepositedTotal).
-    /// TODO: Account for margin of error due to rounding.
     function _getCollateralNet(IFlatcoinVault vault) private view returns (int256 netCollateral) {
         int256 collateralBalance = int256(vault.collateral().balanceOf(address(vault)));
         int256 trackedCollateral = int256(vault.stableCollateralTotal()) +
@@ -109,7 +108,10 @@ abstract contract InvariantChecks {
 
     /// @dev Collateral balance changes should match tracked collateral changes
     function _collateralNetBalanceRemainsUnchanged(int256 netBefore, int256 netAfter) private pure {
-        if (netBefore != netAfter) revert FlatcoinErrors.InvariantViolation("collateralNet2");
+        // Note: +1e6 to account for rounding errors.
+        // This means we are ok with a small margin of error such that netAfter - 1e6 <= netBefore <= netAfter.
+        if (netBefore > netAfter || netAfter > netBefore + 1e6)
+            revert FlatcoinErrors.InvariantViolation("collateralNet2");
     }
 
     /// @dev Stable LPs should never lose value (can only gain on trading fees)
diff --git a/src/misc/KeeperFee.sol b/src/misc/KeeperFee.sol
index c383c1a..0adf222 100644
--- a/src/misc/KeeperFee.sol
+++ b/src/misc/KeeperFee.sol
@@ -1,8 +1,8 @@
 // SPDX-License-Identifier: MIT
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
-import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
+import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
+import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
 
 import {FlatcoinErrors} from "../libraries/FlatcoinErrors.sol";
 import {FlatcoinModuleKeys} from "../libraries/FlatcoinModuleKeys.sol";
@@ -48,10 +48,7 @@ contract KeeperFee is Ownable {
         uint256 gasUnitsL1,
         uint256 gasUnitsL2,
         uint256 stalenessPeriod
-    ) {
-        // Do not call Ownable constructor which sets the owner to the msg.sender and set it to _owner.
-        _transferOwnership(owner);
-
+    ) Ownable(owner) {
         // contracts
         _ethOracle = IChainlinkAggregatorV3(ethOracle);
         _oracleModule = IOracleModule(oracleModule);
diff --git a/src/misc/Viewer.sol b/src/misc/Viewer.sol
index b982da0..df8dd4c 100644
--- a/src/misc/Viewer.sol
+++ b/src/misc/Viewer.sol
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: SEE LICENSE IN LICENSE
-pragma solidity 0.8.18;
+pragma solidity 0.8.20;
 
-import {SignedMath} from "openzeppelin-contracts/contracts/utils/math/SignedMath.sol";
+import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
 import {DecimalMath} from "../libraries/DecimalMath.sol";
 import {IFlatcoinVault} from "../interfaces/IFlatcoinVault.sol";
 import {ILeverageModule} from "../interfaces/ILeverageModule.sol";
```

___



# Audit scope


[flatcoin-v1 @ ff4d191ac6766bc695e96657899e85446ec858b1](https://github.com/dhedge/flatcoin-v1/tree/ff4d191ac6766bc695e96657899e85446ec858b1)
- [flatcoin-v1/src/DelayedOrder.sol](flatcoin-v1/src/DelayedOrder.sol)
- [flatcoin-v1/src/FlatcoinVault.sol](flatcoin-v1/src/FlatcoinVault.sol)
- [flatcoin-v1/src/LeverageModule.sol](flatcoin-v1/src/LeverageModule.sol)
- [flatcoin-v1/src/LimitOrder.sol](flatcoin-v1/src/LimitOrder.sol)
- [flatcoin-v1/src/LiquidationModule.sol](flatcoin-v1/src/LiquidationModule.sol)
- [flatcoin-v1/src/OracleModule.sol](flatcoin-v1/src/OracleModule.sol)
- [flatcoin-v1/src/PointsModule.sol](flatcoin-v1/src/PointsModule.sol)
- [flatcoin-v1/src/StableModule.sol](flatcoin-v1/src/StableModule.sol)
- [flatcoin-v1/src/abstracts/ModuleUpgradeable.sol](flatcoin-v1/src/abstracts/ModuleUpgradeable.sol)
- [flatcoin-v1/src/abstracts/OracleModifiers.sol](flatcoin-v1/src/abstracts/OracleModifiers.sol)
- [flatcoin-v1/src/libraries/DecimalMath.sol](flatcoin-v1/src/libraries/DecimalMath.sol)
- [flatcoin-v1/src/libraries/FlatcoinErrors.sol](flatcoin-v1/src/libraries/FlatcoinErrors.sol)
- [flatcoin-v1/src/libraries/FlatcoinEvents.sol](flatcoin-v1/src/libraries/FlatcoinEvents.sol)
- [flatcoin-v1/src/libraries/FlatcoinModuleKeys.sol](flatcoin-v1/src/libraries/FlatcoinModuleKeys.sol)
- [flatcoin-v1/src/libraries/FlatcoinStructs.sol](flatcoin-v1/src/libraries/FlatcoinStructs.sol)
- [flatcoin-v1/src/libraries/PerpMath.sol](flatcoin-v1/src/libraries/PerpMath.sol)
- [flatcoin-v1/src/misc/ERC20LockableUpgradeable.sol](flatcoin-v1/src/misc/ERC20LockableUpgradeable.sol)
- [flatcoin-v1/src/misc/ERC721LockableEnumerableUpgradeable.sol](flatcoin-v1/src/misc/ERC721LockableEnumerableUpgradeable.sol)
- [flatcoin-v1/src/misc/InvariantChecks.sol](flatcoin-v1/src/misc/InvariantChecks.sol)
- [flatcoin-v1/src/misc/KeeperFee.sol](flatcoin-v1/src/misc/KeeperFee.sol)
- [flatcoin-v1/src/misc/Viewer.sol](flatcoin-v1/src/misc/Viewer.sol)


