import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  if (deployer === undefined) {
    throw new Error("Deployer is undefined.");
  }
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy Art Token Manager Contract
  const ArtTokenManagerFactory = await ethers.getContractFactory(
    "ArtTokenManager"
  );
  const artTokenManager = await ArtTokenManagerFactory.deploy();
  await artTokenManager.deployed();
  console.log("ArtTokenManager deployed to:", artTokenManager.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
