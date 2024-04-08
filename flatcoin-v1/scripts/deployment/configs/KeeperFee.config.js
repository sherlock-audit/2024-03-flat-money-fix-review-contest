module.exports = {
    owner: "0x917A19E71a2811504C4f64aB33c132063B5772a5", // TODO: change to Base mainnet multisig address
    ethOracle: "0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1", // Base mainnet ETH Chainlink oracle 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70
    oracleModule: "0x0e67B60EF53b6C41133686C285d72783F7A6346b",
    assetToPayWith: "0xb4c62a433b64d7615ED68bd35Ebe6CF17D03F666", // TODO: Base mainnet 0xb6fe221fe9eef5aba221c348ba20a1bf5e73624c
    profitMarginUSD: "1000000000000000000", // $1
    profitMarginPercent: "300000000000000000", // 30%
    keeperFeeUpperBound: "30000000000000000000", // $30
    keeperFeeLowerBound: "1000000000000000000", // $1
    gasUnitsL1: 30000,
    gasUnitsL2: 1200000,
    stalenessPeriod: 1200, // 20 minutes in seconds.
};

/* Contract initialization parameters:

    address owner,
    address ethOracle,
    address oracleModule,
    address assetToPayWith,
    uint256 profitMarginUSD,
    uint256 profitMarginPercent,
    uint256 keeperFeeUpperBound,
    uint256 keeperFeeLowerBound,
    uint256 gasUnitsL1,
    uint256 gasUnitsL2,
    uint256 stalenessPeriod
*/
