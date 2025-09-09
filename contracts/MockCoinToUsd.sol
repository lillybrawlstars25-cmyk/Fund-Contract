// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library MockCoinToUsd {

    //Getting The Mock Price Feed (1ETH = ?$, 1BNB = ?$, etc)
    function getMockPriceFeed() internal pure returns(uint256) {

        int256 price = 200018367547;
        uint8 decimals = 8;

        return uint256(price) * (10 ** (18 - decimals));
    }

    //Get Mock Conversion Rate (Coin/Token Given = ?$)
    function getMockConversionRate(uint256 tokenAmount) internal pure returns(uint256) {

        uint256 price = getMockPriceFeed();
        uint256 priceInUsd = (price * tokenAmount) / 1e18;

        return priceInUsd;

    }

}