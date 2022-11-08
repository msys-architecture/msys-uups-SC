import { ethers, upgrades } from "hardhat";
// const { ethers, upgrades } = require("hardhat");

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const LotteryContract = await ethers.getContractFactory("LotteryContract");
   console.log("Deploying LotteryContract...");
   const lotteryContract = await upgrades.deployProxy(LotteryContract, ['0x94577E7E7fe756189304c4489E2c26cF47A91457'],{ kind: 'uups' });
   await lotteryContract.deployed();
   console.log("LotteryContract deployed to:", lotteryContract.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });