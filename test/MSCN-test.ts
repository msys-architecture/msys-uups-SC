import { ethers, upgrades } from "hardhat";

describe('MyToken', function () {
  it('deploys', async function () {
    const MyTokenV1 = await ethers.getContractFactory('MSCN',);
    await MyTokenV1.deploy();
  });
});