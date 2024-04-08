module.exports = {
    owner: "0x917A19E71a2811504C4f64aB33c132063B5772a5", // TODO: change to Base mainnet multisig address
    collateral: "0xb4c62a433b64d7615ED68bd35Ebe6CF17D03F666" // TODO: change to 0xb6fe221fe9eef5aba221c348ba20a1bf5e73624c rETH on Base mainnet
    maxFundingVelocity: "1000000000000000", // 0.1% value rate change per day.
    maxVelocitySkew: "100000000000000000", // Max velocity at +-10% skew.
    skewFractionMax: "1200000000000000000", // 120% => 1.2
    stableCollateralCap: "1000000000000000000000", // 1000 rETH ~$3.8M.
    minExecutabilityAge: 5, // min order pending time in seconds.
    maxExecutabilityAge: 45, // order expiry time in seconds.
};
