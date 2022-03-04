import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners()
  if (deployer === undefined) {
      throw new Error('Deployer is undefined.')
  }
  console.log('Deploying contracts with the account:', deployer.address)
  console.log('Account balance:', (await deployer.getBalance()).toString())

  // We get the contract to deploy
  const ArtToken = await ethers.getContractFactory("ArtToken");
  const artToken = await ArtToken.deploy();
  await artToken.deployed();
  console.log("ArtToken deployed to:", artToken.address);

  const ArtMarketplace = await ethers.getContractFactory("ArtMarketplace");
  const artMarketplace = await ArtMarketplace.deploy(artToken.address);
  await artMarketplace.deployed();

  console.log("ArtMarketplace deployed to:", artMarketplace.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
