import { expect } from "chai";
import { ethers } from "hardhat";

describe("ArtToken", function () {
  it("Should deploy ArtToken successfully", async function () {
    const ArtTokenFactory = await ethers.getContractFactory("ArtToken");
    const artToken = await ArtTokenFactory.deploy(
      "Art Token",
      "ARTK",
      "https://ipfs.com/baseurl/",
      "https://ipfs.com/logo-url/",
      100,
      "100000000000000000"
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

    await expect(
      artTokenManager.deployCollection(
        "Art Token",
        "ARTK",
        "https://ipfs.com/baseurl/",
        "https://ipfs.com/logo-url/",
        100,
        "100000000000000000"
      )
    ).to.emit(artTokenManager, "CollectionDeployed");
  });
});
