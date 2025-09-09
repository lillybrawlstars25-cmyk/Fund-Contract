const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Fund Contract, Converting Coin/Token Value To Usd + Transactions", function() {

    //Give It Enough Time
    this.timeout(0);

    //Before The First Test Create a New Contract
    let fund;
    let owner, addr1;
    let ethSentInUsd;

    //Before The First Test Create a New Contract and Assign The Wallets Used
    before(async function() {
        
        [owner, addr1] = await ethers.getSigners();

        const Fund = await ethers.getContractFactory("Fund");
        fund = await Fund.deploy();
        await fund.waitForDeployment();
        
    });

    //It Tests If The Contract Can Succesfully Convert Token/Coin Value In Usd
    it("Should Succesfully Convert Coin/Token Value In Usd", async function() {

        const ethSentInTransaction = ethers.parseEther("0.0001");
        const ethSentInTransactionValueInUsd = await fund.connect(addr1).getEthTokensGivenValueInUsd(ethSentInTransaction);
        const formatedTransactionInUsd = ethers.formatUnits(ethSentInTransactionValueInUsd, 18);

        console.log(`0.0001 ETH: ${formatedTransactionInUsd}$`);
        await expect(
            fund.connect(addr1).getEthTokensGivenValueInUsd(0)
        ).to.be.revertedWithCustomError(fund, "InvalidValue");
        expect(ethSentInTransactionValueInUsd).to.be.greaterThan(0);

    });

    //It Tests If The Transaction Reverts If Not Enough Eth Is Sent
    it("Should Revert If Not Enough Eth Is Sent", async function() {

        const ethSent = ethers.parseEther("0.000001");
        const ethSentInUsd = await fund.connect(addr1).getEthTokensGivenValueInUsd(ethSent);
        const minimumEthInUsd = await fund.MINIMUM_ETH_IN_USD();

        await expect(
            fund.connect(addr1).fundContract( { value: ethSent } )
        ).to.be.revertedWithCustomError(fund, "NotEnoughEthSent").withArgs(ethSentInUsd, minimumEthInUsd);

    });

    //It Tests If The Transaction Passes If Enough Eth Is Sent
    it("Should Pass If Enough Eth Is Sent", async function() {

        const ethSent = ethers.parseEther("0.0001");
        ethSentInUsd = await fund.getEthTokensGivenValueInUsd(ethSent);
        const tx = await fund.connect(addr1).fundContract( { value: ethSent } );
        const receipt = await tx.wait();

        expect(receipt.status).to.equal(1);

    });

    //It Should Retrieve All Address and Balance Of Funder
    it("Should Retrieve The Address and Amount Funded Of The Funder", async function() {

        const address = await fund.connect(addr1).retrieveFunderAddressByAmount(ethSentInUsd);
        const firstAddress = address[0];
        const balance = await fund.connect(addr1).retrieveFundedAmountByAddress(firstAddress);

        expect(balance).to.equal(ethSentInUsd);

    });

    //It Tests If The Contract Reverts If Non-Owner Tries To Withdraw
    it("Should Revert If Non-Owner Tries To Withdraw", async function() {
        
        await expect(
            fund.connect(addr1).withdraw()
        ).to.be.revertedWithCustomError(fund, "NotOwner").withArgs(owner);

    });

    it("Should Withdraw Funds and Clean Data If Owner Withdraws", async function() {

        const tx = await fund.connect(owner).withdraw();
        const receipt = await tx.wait();

        expect(receipt.status).to.equal(1);

    });

});

describe("Mock Funding Contract, Testing The Mock Aggregator", function() {

    //Give It Enough Time
    this.timeout(0);
    
    let mock;
    let owner, addr1;

    //Before The First Test Assign The Wallets Needed For The Test
    before(async function() {
        [owner, addr1] = await ethers.getSigners();
    });

    //Before Each Test Create a New Contract
    beforeEach(async function(){

        const Mock = await ethers.getContractFactory("MockFunding");
        mock = await Mock.deploy();
        await mock.waitForDeployment();

    });

    //It Tests If The Contract Can Succesfully Convert Token/Coin Value In Usd
    it("Should Succesfully Convert Coin/Token Value In Usd", async function() {

        const ethSent = ethers.parseEther("0.0001");
        const ethPriceInUsd = await mock.connect(owner).getEthPriceInUsd(ethSent);
        const formatedEthPriceInUsd = ethers.formatUnits(ethPriceInUsd, 18);

        console.log(`0.0001 ETH: ${formatedEthPriceInUsd}$`);
        await expect(
            mock.connect(owner).getEthPriceInUsd(0)
        ).to.be.revertedWithCustomError(mock, "InvalidValueForMock").withArgs(0);
        expect(ethPriceInUsd).to.be.greaterThan(0);

    });

});