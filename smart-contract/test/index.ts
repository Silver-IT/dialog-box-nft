import { expect } from "chai";
import { ethers } from "hardhat";

let artTokenAddress = '';

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});

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
