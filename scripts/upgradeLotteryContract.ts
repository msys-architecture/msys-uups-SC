// const { ethers, upgrades } = require("hardhat");
import { ethers, upgrades } from "hardhat";

const UPGRADEABLE_PROXY = "0x5e621564bce1646b8e75B6BD13715b51DC19c54d";

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const LotteryContractV2 = await ethers.getContractFactory("LotteryContract");
   console.log("Upgrading LotteryContractV1...");
   let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, LotteryContractV2);
//    let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, LotteryContractV2, {constructorArgs: ['0x94577E7E7fe756189304c4489E2c26cF47A91457']});
   console.log("LotteryContractV1 Upgraded to LotteryContractV2");
   console.log("LotteryContractV2 Deployed To:", upgrade.address)
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });