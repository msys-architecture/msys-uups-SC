import { ethers, upgrades } from "hardhat";
// const { ethers, upgrades } = require("hardhat");

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const MsysERC20 = await ethers.getContractFactory("MsysERC20");
   console.log("Deploying MsysERC20...");
   const msysERC20 = await upgrades.deployProxy(MsysERC20, { kind: 'uups' });
   await msysERC20.deployed();
   console.log("MsysERC20 deployed to:", msysERC20.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });