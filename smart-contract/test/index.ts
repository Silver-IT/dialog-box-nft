import { expect } from "chai";
import { ethers } from "hardhat";

let artTokenAddress = '';

describe("ArtToken", function () {
  it("Should deploy ArtToken successfully", async function () {
    const ArtToken = await ethers.getContractFactory("ArtToken");
    const artToken = await ArtToken.deploy();
    await artToken.deployed();
    artTokenAddress = artToken.address;
  });
});


describe("ArtMarketplace", function () {
  it("Should deploy ArtMarketplace successfully", async function () {
    const ArtMarketplace = await ethers.getContractFactory("ArtMarketplace");
    const artMarketplace = await ArtMarketplace.deploy(artTokenAddress);
    await artMarketplace.deployed();
  });
});
