// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

//Importing The Price Converter
import { MockCoinToUsd } from "./MockCoinToUsd.sol";

contract MockFunding {

    using MockCoinToUsd for uint256;

    //Get The Eth Amount Price In Usd
    error InvalidValueForMock(uint256 priceInUsd);
    function getEthPriceInUsd(uint256 ethAmount) public pure returns(uint256) {

        uint256 priceInUsd = ethAmount.getMockConversionRate();

        if (priceInUsd == 0) {
            revert InvalidValueForMock(priceInUsd);
        }
        return priceInUsd;

    }

}