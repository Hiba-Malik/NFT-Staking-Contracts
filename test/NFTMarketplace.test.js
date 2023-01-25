const { expect } = require('chai');

const toWei = (num) => ethers.utils.parseEther(num.toString());
const fromWei = (num) => ethers.utils.formatEther(num);

describe('NFTMarketPlace', function () {
  let NFT;
  let nft;
  let Marketplace;
  let marketplace;
  let deployer;
  let addr1;
  let addr2;
  let addrs;
  let feePercent = 1;
  let URI = 'sample URI';
  let bulkURI = 'sample Bulk URI';

  beforeEach(async function () {
    // Get Contract Factories & Signers first
    NFT = await ethers.getContractFactory('NFTContract');
    Marketplace = await ethers.getContractFactory('Marketplace');
    [deployer, addr1] = await ethers.getSigners();
    //.log('deployer:', addr1.address);

    // deploy contracts
    nft = await NFT.deploy(deployer.address);
    marketplace = await Marketplace.deploy();
  });

  describe('Deployment', function () {
    it('Should track name and symbol of the nft collection', async function () {
      const nftName = 'Testing NFT';
      const nftSymbol = 'TNFT';
      expect(await nft.name()).to.equal(nftName);
      expect(await nft.symbol()).to.equal(nftSymbol);
    });
  });

  describe('Minting NFTs', function () {
    it('Should track each single minted NFT', async function () {
      // addr1 mints an nft
      // const test = await (
      //   await nft.singleMint(URI, marketplace.address)
      // ).wait();
      // const owner = await nft.ownerOf(1);
      // console.log(owner);
      // console.log('Address: ', addr1.address);

      // addr1 mints an nft
      const test = await nft.singleMint(URI, marketplace.address);
      console.log(await nft.balanceOf(deployer.address));

      expect(await nft.totalSupply()).to.equal(1);
      //expect(await nft.balanceOf(addr1.address)).to.equal(1);
      //expect(await nft.ownerOf(1)).to.equal(addr1.address);
      expect(await nft.tokenURI(1)).to.equal(URI);
    });

    it('Should track all bulk minted NFTs', async function () {
      // addr1 mints an nft
      await nft.mintAllowList(3, bulkURI, marketplace.address);
      expect(await nft.totalSupply()).to.equal(3);
      //expect(await nft.balanceOf(addr1.address)).to.equal(1);
      //expect(await nft.ownerOf(2)).to.equal(addr1.address);
      expect(await nft.tokenURI(3)).to.equal(bulkURI);
    });
  });

  describe('Making marketplace items', function () {
    let price = 0.0001;
    let result;
    beforeEach(async function () {
      // addr1 single mints an nft
      await nft.singleMint(URI, marketplace.address);
      // addr1 bulk mints nfts
      await nft.mintAllowList(3, bulkURI, marketplace.address);
    });

    it('Should track newly created item, transfer NFT from seller to marketplace and emit Offered event', async function () {
      // addr1 offers their nft at a price of 1 ether
      await expect(
        marketplace.connect(deployer).listItem(nft.address, 1, toWei(price))
      )
        .to.emit(marketplace, 'Offered')
        .withArgs(4, nft.address, 1, toWei(price), addr1.address);
      // Owner of NFT should now be the marketplace
      expect(await nft.ownerOf(1)).to.equal(marketplace.address);
      // Item count should now equal 1
      expect(await marketplace.itemCount()).to.equal(1);
      // Get item from items mapping then check fields to ensure they are correct
      const item = await marketplace.items(1);
      expect(item.itemId).to.equal(1);
      expect(item.nft).to.equal(nft.address);
      expect(item.tokenId).to.equal(1);
      expect(item.price).to.equal(toWei(price));
      expect(item.sold).to.equal(false);
    });

    it('Should fail if price is set to zero', async function () {
      await expect(marketplace.makeItem(nft.address, 1, 0)).to.be.revertedWith(
        'Price must be greater than zero'
      );
    });
  });
});
