require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); // Import dotenv pour charger les variables du fichier .env

const { PRIVATE_KEY, ALCHEMY_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.18",
  networks: {
    holesky: {
      url: `https://eth-holesky.g.alchemy.com/v2/${ALCHEMY_KEY}`,
      accounts: [PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};
