import { ethers, upgrades } from "hardhat";
// const { ethers, upgrades } = require("hardhat");

// 0x13FC20d6AA539814fb624FbF832B480E68fc5758

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const UserContract = await ethers.getContractFactory("UserContract");
   console.log("Deploying UserContract...");
   const userContract = await upgrades.deployProxy(UserContract,['0x94577E7E7fe756189304c4489E2c26cF47A91457'],{ kind: 'uups' });
   await userContract.deployed();
   console.log("UserContract deployed to:", userContract.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });