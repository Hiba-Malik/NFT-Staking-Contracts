// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @title ERC721 Staking contract
/// @notice You can use this contract for staking NFTs
/// @dev All function calls are currently implemented without side effects
contract ERC721Staking is ReentrancyGuard {
    // Interfaces for ERC20 and ERC721
    IERC721 public immutable nftCollection;
    IERC20 public immutable rewardTokens;
    uint256 itemCount;

    struct StakedToken {
        address staker;
        uint256 tokenId;
        uint256 stakedId;
        uint256 startingTime;
        uint256 stakingTime;
        uint256 timeOfLastUpdate;
        uint256 rewardsEarned;
        uint256 amountStaked;
    }

    uint256 miniStakingTime = 30;
    uint256 constant apy = 2;
    uint256 month = 2629743;
    uint256 day = 86400; //one-day
    uint256 cycle = 60;

    // Mapping of Token Id to StakedToken
    mapping(uint256 => StakedToken) public StakedTokens;

    //Keep track of how many nfts are staked, stakedId => tokenID
    uint256[] TotalTokens;

    // Constructor function to set the NFT collection address
    constructor(IERC721 _nftCollection, IERC20 _rewardTokens) {
        nftCollection = _nftCollection;
        rewardTokens = _rewardTokens;
    }

    // @param _tokenId The nft to stake tokenId
    // @param _finish The time of how long to stake
    function stake(uint256 _tokenId, uint256 _finish) external nonReentrant {
        //@ Starting time must be less than finish time
        //require(block.timestamp > _finish, "0x00");
        //@ Transfer the token from the wallet to the Smart contract
        nftCollection.transferFrom(msg.sender, address(this), _tokenId);

        itemCount++;
        // Create StakedToken
        StakedTokens[_tokenId] = StakedToken(
            msg.sender,
            _tokenId,
            itemCount,
            block.timestamp,
            _finish,
            block.timestamp,
            0,
            1
        );

        TotalTokens.push(_tokenId);
    }

    // When user tries to retrieve token before minimum time to earn reward has been reached
    // As such they wont earn any rewards
    // @param _tokenId The nft to stake tokenId
    function unStake(uint256 _tokenId) external nonReentrant {
        require(
            block.timestamp - StakedTokens[_tokenId].startingTime <
                miniStakingTime,
            "0x01"
        );
        require(msg.sender == StakedTokens[_tokenId].staker, "0x02");
        // Set this token's .isStaked to false
        //StakedTokens[_tokenId].isStaked = false;

        // Transfer the token back to the withdrawer
        nftCollection.transferFrom(address(this), msg.sender, _tokenId);
        delete StakedTokens[_tokenId];
        TotalTokens.push(_tokenId);
        itemCount--;
    }

    // @param _tokenId The nft to stake tokenId
    function withdraw(uint256 _tokenId) external nonReentrant {
        // Wallet must own the token they are trying to withdraw
        require(StakedTokens[_tokenId].staker == msg.sender, "0x03");
        //Check that it hasn't been more than one day since we last calculated the rewards
        require(
            block.timestamp - StakedTokens[_tokenId].timeOfLastUpdate <= 120,
            "0x04"
        );

        //Reward Staker
        rewardTokens.transfer(msg.sender, StakedTokens[_tokenId].rewardsEarned);

        // Transfer the token back to the withdrawer
        nftCollection.transferFrom(address(this), msg.sender, _tokenId);
        delete StakedTokens[_tokenId];
        TotalTokens.push(_tokenId);
        itemCount--;
    }

    // @param _tokenId The nft to stake tokenId
    function calculateRewards(uint256 _tokenId) public returns (uint256) {
        uint256 amount = 0;
        uint256 _days = (block.timestamp -
            StakedTokens[_tokenId].startingTime) / cycle;
        //require(_days < miniStakingTime,"0x04");

        // amount = (_days * apy * StakedTokens[_tokenId].amountStaked) / (259200000);
        amount = (_days * apy * 1) / 1 seconds;
        StakedTokens[_tokenId].rewardsEarned = amount;
        StakedTokens[_tokenId].timeOfLastUpdate = block.timestamp;
        return amount;
    }

    function totalSupply() public view returns (uint256) {
        return itemCount;
    }
}
