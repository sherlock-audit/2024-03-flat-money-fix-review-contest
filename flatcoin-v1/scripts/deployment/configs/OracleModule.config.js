module.exports = {
    vault: "0x5A5d085656ABC42E7fA77A62357d5A44B4e778dF",
    collateral: "0xb4c62a433b64d7615ED68bd35Ebe6CF17D03F666", // TODO: rETH Base mainnet 0xb6fe221fe9eef5aba221c348ba20a1bf5e73624c
    onChainOracle: {
        chainlinkV3Aggregator: "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1", // TODO: dHEDGE rETH oracle Base mainnet 0x4aF79bbBd345ae56D9e9Af4482e77CB4EB98e85e
        chainlinkPriceExpiry: 86400,
    },
    offchainOracle: {
        pyth: "0xA2aa501b19aff244D90cc15a4Cf739D2725B5729", // TODO: Base mainnet contract 0x8250f4aF4B972684F7b336503E2D6dFeDeB1487a
        pythPriceFeedId: "0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace", // TODO: rETH ID 0xa0255134973f4fdf2f8f7808354274a3b1ebc6ee438be898d045e8b56ba1fe13
        pythMaxPriceAge: 86400,
        pythMinConfidenceRatio: 1000,
    },
    maxDiffPercent: "12500000000000000", // 1.25%
};
