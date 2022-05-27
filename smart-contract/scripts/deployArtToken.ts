import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  if (deployer === undefined) {
    throw new Error("Deployer is undefined.");
  }
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy Art Token Contract
  const ArtTokenFactory = await ethers.getContractFactory("ArtToken");
  const artToken = await ArtTokenFactory.deploy(
    "0x97Dee6068fDfD33e82385024B43018b476caD6F4",
    "Art Token",
    "ARTK",
    "https://ipfs.com/baseurl/",
    "https://ipfs.com/logo-url/",
    100,
    "100000000000000000"
  );
  await artToken.deployed();
  console.log("ArtToken deployed to:", artToken.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
