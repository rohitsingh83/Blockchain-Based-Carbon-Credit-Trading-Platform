const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CarbonCreditMarketplace", function () {
  async function deployed() {
    const [issuer, buyer, retiree] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("CarbonCreditMarketplace");
    const market = await Factory.deploy();
    await market.createProject("Mangrove Restoration", "SIM-2026-001", "ipfs://simulated-project");
    await market.issueCredits(1, issuer.address, 1000);
    return { market, issuer, buyer, retiree };
  }

  it("allows only the issuer to create and issue simulated projects", async function () {
    const { market, issuer, buyer } = await deployed();
    await expect(market.connect(buyer).issueCredits(1, buyer.address, 1)).to.be.revertedWith("only issuer");
    expect(await market.balances(1, issuer.address)).to.equal(1000);
  });

  it("transfers credits between wallets", async function () {
    const { market, issuer, buyer } = await deployed();
    await market.transferCredits(1, buyer.address, 125);
    expect(await market.balances(1, buyer.address)).to.equal(125);
    expect(await market.balances(1, issuer.address)).to.equal(875);
  });

  it("escrows credits and settles a fixed-price purchase", async function () {
    const { market, issuer, buyer } = await deployed();
    await market.connect(issuer).createListing(1, 200, ethers.parseEther("0.01"));
    await market.connect(buyer).buyCredits(1, 75, { value: ethers.parseEther("0.75") });
    expect(await market.balances(1, buyer.address)).to.equal(75);
    expect((await market.listings(1)).amount).to.equal(125);
    expect(await market.proceeds(issuer.address)).to.equal(ethers.parseEther("0.75"));
  });

  it("retires credits permanently and records the reason", async function () {
    const { market, buyer } = await deployed();
    await market.transferCredits(1, buyer.address, 80);
    await expect(market.connect(buyer).retireCredits(1, 80, "Student portfolio demonstration"))
      .to.emit(market, "CreditsRetired").withArgs(1, buyer.address, 80, "Student portfolio demonstration");
    expect(await market.balances(1, buyer.address)).to.equal(0);
    expect((await market.projects(1)).totalRetired).to.equal(80);
  });
});
