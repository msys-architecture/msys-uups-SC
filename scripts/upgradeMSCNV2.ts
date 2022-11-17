// const { ethers, upgrades } = require("hardhat");
import { ethers, upgrades } from "hardhat";

const UPGRADEABLE_PROXY = "0x94577E7E7fe756189304c4489E2c26cF47A91457";

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const MsysERC20V2 = await ethers.getContractFactory("MsysERC20V2");
   console.log("Upgrading MsysERC20V2.1...");
   let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, MsysERC20V2);
   console.log("MsysERC20V2 Upgraded to MsysERC20V2.1");
   console.log("MsysERC20V2.1 Deployed To:", upgrade.address)
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });