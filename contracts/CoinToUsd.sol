// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

//Importing The Aggregator
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library CoinToUsd {

    //Get The Price Feed (1 ETH, 1 BNB, ETC = ?)
    error InvalidValueForPriceFeed(int256 price);
    function getPriceFeed(AggregatorV3Interface priceFeed) internal view returns(uint256) {

        (,int256 price,,,) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();

        if (price <= 0) {
            revert InvalidValueForPriceFeed(price);
        }
        return uint256(price) * (10 ** (18 - decimals));

    }

    //Get Conversion Rate (Coin/Token Given = $?)
    function getConversionRate(uint256 tokenAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {

        uint256 price = getPriceFeed(priceFeed);
        uint256 priceOfTokensGivenInUsd = (price * tokenAmount) / 1e18;

        return priceOfTokensGivenInUsd;
        
    }

}