import { expect } from "chai";
import { ethers } from "hardhat";
import { randomBytes } from "crypto";

describe("ArtToken", function () {
  it("Should deploy ArtToken successfully", async function () {
    const ArtTokenFactory = await ethers.getContractFactory("ArtToken");
    const artToken = await ArtTokenFactory.deploy(
      "Art Token",
      "ARTK",
      "https://ipfs.com/baseurl/",
      "https://ipfs.com/logo-url/",
      "100",
      "100000000000000000"
    );
    await artToken.deployed();

    // Check RoyaltyInfo
    const metadataId = "0x" + randomBytes(32).toString("hex");
    await expect(artToken.publicMint(metadataId, "500", {
      value: "100000000000000000",
    })).to.emit(artToken, "TokenMinted");

    const [royaltyReceiver, royaltyFraction] = await artToken.royaltyInfo("1", "10000");
    expect(royaltyReceiver).to.be.eq("0x97Dee6068fDfD33e82385024B43018b476caD6F4");
    expect(royaltyFraction).to.be.eq("500");
  });
});

describe.skip("ArtTokenManager", function () {
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
        "100",
        "100000000000000000"
      )
    ).to.emit(artTokenManager, "CollectionDeployed");
  });
});
