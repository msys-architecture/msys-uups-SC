import { ethers, upgrades } from "hardhat";
// const { ethers, upgrades } = require("hardhat");

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const BettingContract = await ethers.getContractFactory("BettingContract");
   console.log("Deploying BettingContract...");
   const bettingContract = await upgrades.deployProxy(BettingContract, ['0x94577E7E7fe756189304c4489E2c26cF47A91457'],{ kind: 'uups' });
   await bettingContract.deployed();
   console.log("BettingContract deployed to:", bettingContract.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });