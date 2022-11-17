// const { ethers, upgrades } = require("hardhat");
import { ethers, upgrades } from "hardhat";

const UPGRADEABLE_PROXY = "0x5e621564bce1646b8e75B6BD13715b51DC19c54d";
const MSCNToken_Address = "0x94577E7E7fe756189304c4489E2c26cF47A91457";
const UserContract_Address = "0xB77406b8cA1602C10b1B787Efd48126B7eb261C7";

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const LotteryContractV2 = await ethers.getContractFactory("LotteryContractV2");
   console.log("Upgrading LotteryContractV2.1...");
   let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, LotteryContractV2,{call : { fn : "upgradeV2", args : [MSCNToken_Address,UserContract_Address] }});
//    let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, LotteryContractV2, {constructorArgs: ['0x94577E7E7fe756189304c4489E2c26cF47A91457']});
   console.log("LotteryContractV2 Upgraded to LotteryContractV2.1");
   console.log("LotteryContractV2.1 Deployed To:", upgrade.address)
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });