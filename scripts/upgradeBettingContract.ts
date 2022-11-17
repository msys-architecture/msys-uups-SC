// const { ethers, upgrades } = require("hardhat");
import { ethers, upgrades } from "hardhat";

const UPGRADEABLE_PROXY = "0xe41B69c827fEb57418e6F534b5DC7eE09ffA30d6";

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const BettingContractV2 = await ethers.getContractFactory("BettingContract");
   console.log("Upgrading BettingContractV1...");
   let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, BettingContractV2);
//    let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, BettingContractV2, {constructorArgs: ['0x94577E7E7fe756189304c4489E2c26cF47A91457']});
   console.log("BettingContractV1 Upgraded to BettingContractV2");
   console.log("BettingContractV2 Deployed To:", upgrade.address)
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });