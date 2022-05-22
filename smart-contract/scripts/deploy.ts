import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners()
  if (deployer === undefined) {
      throw new Error('Deployer is undefined.')
  }
  console.log('Deploying contracts with the account:', deployer.address)
  console.log('Account balance:', (await deployer.getBalance()).toString())

  // We get the contract to deploy
  const ArtTokenManager = await ethers.getContractFactory("ArtTokenManager");
  const artTokenManager = await ArtTokenManager.deploy();
  await artTokenManager.deployed();
  console.log("ArtTokenManager deployed to:", artTokenManager.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
