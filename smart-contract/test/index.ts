import { expect } from "chai";
import { ethers } from "hardhat";

describe("ArtToken", function () {
  it("Should deploy ArtToken successfully", async function () {
    const ArtTokenFactory = await ethers.getContractFactory("ArtToken");
    const artToken = await ArtTokenFactory.deploy(
      "0x97Dee6068fDfD33e82385024B43018b476caD6F4",
      "Art Token",
      "ARTK",
      "https://jfmc-api-hxs7r5kyjq-uc.a.run.app/"
    );
    await artToken.deployed();
  });
});

describe("ArtTokenManager", function () {
  it("Should deploy ArtTokenManager successfully", async function () {
    const ArtTokenManagerFactory = await ethers.getContractFactory(
      "ArtTokenManager"
    );
    const artTokenManager = await ArtTokenManagerFactory.deploy();
    await artTokenManager.deployed();

    await expect(artTokenManager.deployCollection("Art Token", "ARTK", "", ""))
      .to.not.be.reverted;
  });
});
