// const { ethers, upgrades } = require("hardhat");
import { ethers, upgrades } from "hardhat";

const UPGRADEABLE_PROXY = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const V2Contract = await ethers.getContractFactory("V2");
   console.log("Upgrading V1Contract...");
   let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, V2Contract, {
      gasPrice: gas
   });
   console.log("V1 Upgraded to V2");
   console.log("V2 Contract Deployed To:", upgrade.address)
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });