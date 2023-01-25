const { ethers } = require('ethers');

require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');

require('dotenv').config();
const { PRIVATE_KEY } = process.env;
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  defaultNetwork: 'rinkeby',
  networks: {
    hardhat: {},
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/093b4fa91bff4c14b88d04dccdb94bee',
      accounts: [PRIVATE_KEY],
    },
    goerli: {
      url: 'https://goerli.infura.io/v3/093b4fa91bff4c14b88d04dccdb94bee',
      accounts: [PRIVATE_KEY],
    },
    mumbai: {
      url: 'https://polygon-mumbai.g.alchemy.com/v2/RGYs6b1Ynxzx_NUlIN8BU5yrV50oee13',
      accounts: [PRIVATE_KEY],
    },
    matic: {
      url: 'https://rpc-mumbai.maticvigil.com',
      accounts: [PRIVATE_KEY],
    },
  },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    artifacts: './src/backend/artifacts',
    sources: './src/backend/contracts',
    cache: './src/backend/cache',
    tests: './src/backend/test',
  },
  // mocha: {
  //   timeout: 40000,
  // },
  etherscan: {
    apiKey: 'ZZNYA7JY49DW31IFZYR58QQU37SBF7ZXPS', // for ethereum
  },
  // etherscan: {
  //   apiKey: {
  //     polygonMumbai: 'GTSCQ1A3N2TUUF3G69WQ63NGQ7KWW4Z1JB',
  //   },
  // },
};
