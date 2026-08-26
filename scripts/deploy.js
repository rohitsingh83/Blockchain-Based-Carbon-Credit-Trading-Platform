const hre = require("hardhat");

async function main() {
  const marketplace = await hre.ethers.deployContract("CarbonCreditMarketplace");
  await marketplace.waitForDeployment();
  console.log(`CarbonCreditMarketplace deployed to ${await marketplace.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
