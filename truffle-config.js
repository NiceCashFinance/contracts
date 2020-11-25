"use strict";
const ApiKey = process.env.INFURA_API_KEY;
const Infura = {
  Mainnet: "https://mainnet.infura.io/v3/" + ApiKey,
  Ropsten: "https://ropsten.infura.io/v3/" + ApiKey,
  Rinkeby: "https://rinkeby.infura.io/v3/" + ApiKey,
  Kovan: "https://kovan.infura.io/v3/" + ApiKey
};


module.exports = {
  networks: {
    test: {
      host: "127.0.0.1",
      port: 8545,
      network_id: 5777, // Match Ganache(Truffle) network id
      gas: 6500000,
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // reporter: 'eth-gas-reporter',
    //     reporterOptions : {
    //         currency: 'USD',
    //         gasPrice: 5
    //     }
  },
  compilers: {
    solc: {
      version: "0.6.6",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 999
       },
      //  evmVersion: "byzantium"
      }
    },
  },
};
