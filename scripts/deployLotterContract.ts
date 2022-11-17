import { ethers, upgrades } from "hardhat";
// const { ethers, upgrades } = require("hardhat");

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const LotteryContract = await ethers.getContractFactory("LotteryContract");
   console.log("Deploying LotteryContract...");
   const lotteryContract = await upgrades.deployProxy(LotteryContract, ['0x13FC20d6AA539814fb624FbF832B480E68fc5758'],{ kind: 'uups' });
   await lotteryContract.deployed();
   console.log("LotteryContract deployed to:", lotteryContract.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });