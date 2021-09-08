require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();

//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.6",
  defaultNetwork:'hardhat',
  networks:{
    hardhat:{},
    fantom:{
      url:"https://rpc.ftm.tools/",
      chainId:250,
      gasPrice:61*10**9,
      accounts:[`0x${process.env.PRD_PRIVATE_KEY}`]
    }
  },
  etherscan:{
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  additionalNetworks:{
    fantom:process.env.FTMSCAN_API_KEY
  }
};
