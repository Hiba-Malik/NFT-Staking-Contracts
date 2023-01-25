//const { ethers } = require('ethers');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Account balance:', (await deployer.getBalance()).toString());

  //* Get the ContractFactories and Signers here.
  //const NFTContract = await ethers.getContractFactory('NFTContract');
  //const Marketplace = await ethers.getContractFactory('Marketplace');
  const StakingContract = await ethers.getContractFactory('ERC721Staking');
  //const RewardToken = await ethers.getContractFactory('RewardToken');
  //* deploy contracts
  const stake = await StakingContract.deploy(
    '0xeF03D14b6e1C21Fd9BA2fccDE9842e2A42f36A5f',
    '0x916E02ffEb7c92D7e5eD51FAc6BAc8111D6B2546'
  );
  console.log('Staking contract address:', stake.address);
  //const reward = await RewardToken.deploy();
  //console.log('Reward Token Address: ', reward.address);
  //const nft = await NFTContract.deploy(
  //    '0x0FB918Da7dC7251a41266F638575398399DcC792'
  //);
  //const marketplace = await Marketplace.deploy();

  // console.log('NFT Mint Address: ', nft.address);

  //console.log('NFT Marketplace Address: ', marketplace.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// npx hardhat compile --all
// npx hardhat run src/backend/scripts/deploy.js --network <name> like rinkeby
// npx hardhat verify <contractAddress> <constructor params>

// DEPLOYED SUCCESSFULLY

// visit link - ignore errors. it's because of install extensions
// https://rinkeby.etherscan.io/address/0x9b88927231efcEA968D248BCC2582d3116a03F38#code

//
// nft contract 0x5CE0Fe4F04Ae49cB610A1de24BF9148Df43adfe2
// marketplace 0x9782bCbB4F604Ae243b47848E760dDece9d9fAee
// reward token 0x916E02ffEb7c92D7e5eD51FAc6BAc8111D6B2546
// staking contract 0x8323Cabc85B442d833a449b2cac82b34F1249C91
// 0x6f36981976f9a47e3e65ffe1edfdae7237bf502f;
