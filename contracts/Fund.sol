// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

//Importing The Price Converter
import { CoinToUsd } from "./CoinToUsd.sol";

//Importing The Aggregator
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//Custom Errors
error NotOwner(address owner);
error InvalidValue(uint256 priceInUsd);
error NotEnoughEthSent(uint256 ethSentInUsd, uint256 minimum);
error somethingWentWrongInWithdrawingFunds(bool sendSuccess);

contract Fund {

    using CoinToUsd for uint256;

    address public immutable i_owner;
    AggregatorV3Interface internal constant ethPriceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    uint256 public constant MINIMUM_ETH_IN_USD = 1e17;

    address[] public listOfFunders;
    uint256[] public listOfAmountFunded;

    mapping (address => uint256) public addressToAmount;
    mapping (uint256 => address[]) public amountToAddress;

    constructor() {

        i_owner = msg.sender;

    }

    //Revert If Sender Is Not Owner
    modifier onlyOwner() {

        if (msg.sender != i_owner) {
            revert NotOwner(i_owner);
        }

        _;

    }

    //Handle External Transactions
    receive() external payable {
        fundContract();
    }
    fallback() external payable {
        fundContract();
    }

    //Get Value Of Ethereum Given (Eth Amount = $?)
    function getEthTokensGivenValueInUsd(uint256 ethAmount) public view returns(uint256) {

        uint256 priceInUsd = ethAmount.getConversionRate(ethPriceFeed);

        if (priceInUsd == 0) {
            revert InvalidValue(priceInUsd);
        }
        return priceInUsd;
        
    }

    //Allow Users To Fund The Contract
    function fundContract() public payable {

        uint256 ethSent = msg.value;
        uint256 ethSentInUsd = ethSent.getConversionRate(ethPriceFeed);
        address addressOfFunder = msg.sender;

        if (ethSentInUsd < MINIMUM_ETH_IN_USD) {
            revert NotEnoughEthSent(ethSentInUsd, MINIMUM_ETH_IN_USD);
        }

        //Store Every Funders Address In a List
        listOfFunders.push(addressOfFunder);

        //Store Every Funded Amount In Usd
        listOfAmountFunded.push(ethSentInUsd);

        //Look Up The Address To The Amount
        addressToAmount[addressOfFunder] += ethSentInUsd;

        //Look Up The Amount To The Address
        amountToAddress[ethSentInUsd].push(addressOfFunder);
        
    }

    //Retrieves The Funders Address By The Amount (amount funded => address)
    function retrieveFunderAddressByAmount(uint256 usd) public view returns(address[] memory) {

        address[] memory addressOfFunder = amountToAddress[usd];
        return addressOfFunder;

    }

    //Retrieves The Funded Amount By Address (address => amount funded)
    function retrieveFundedAmountByAddress(address addressOfFunder) public view returns(uint256 amount) {

        uint256 amountFundedInUsd = addressToAmount[addressOfFunder];
        return amountFundedInUsd;

    }

    //Lets The Owner Withdraw The Funds In The Contract
    function withdraw() public onlyOwner {

        for (uint256 i = 0; i < listOfFunders.length; i++) {

            address funderAddress = listOfFunders[i];
            addressToAmount[funderAddress] = 0;

        }
        listOfFunders = new address[](0);

        (bool sendSuccess,) = payable(msg.sender).call{ value: address(this).balance }("");
        
        if (!sendSuccess) {
            revert somethingWentWrongInWithdrawingFunds(sendSuccess);
        }

    }

}