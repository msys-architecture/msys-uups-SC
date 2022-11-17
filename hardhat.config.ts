import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-etherscan"
import dotenv from "dotenv"
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades"

dotenv.config()

const config: HardhatUserConfig = {
  defaultNetwork: "matic",
  networks: {
    hardhat: {
    },
    matic: {
      // url: "https://rpc-mumbai.maticvigil.com",
      url: "https://matic-mumbai.chainstacklabs.com",
      accounts: [process.env.PRIVATE_KEY!]
    }
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
}

export default config;

// import { HardhatUserConfig } from "hardhat/config";
// import "@nomicfoundation/hardhat-toolbox";
// import "@nomiclabs/hardhat-ethers"
// import "@openzeppelin/hardhat-upgrades"
// import "@nomiclabs/hardhat-etherscan"

// const config: HardhatUserConfig = {
//   solidity: "0.8.17",
//   networks: {
//     mumbai: {
//       url: "localhost",
//       accounts: ["0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e"],
//     },
//   },
//   etherscan: {
//     apiKey: process.env.ETHERSCAN_API_KEY,
//   }
// };

// export default config;


// // require('dotenv').config()

// // module.exports = {
// //   solidity: "0.8.4",
// //   networks: {
// //     mumbai: {
// //       url: process.env.RPC_URL,
// //       accounts: [process.env.PRIVATE_KEY],
// //     },
// //   },
// //   etherscan: {
// //     apiKey: process.env.ETHERSCAN_API_KEY,
// //   }
// // };