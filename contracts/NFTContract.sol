// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//  @title ERC721 contract
//  @notice You can use this contract for single & bulk minting
//  @dev All function calls are currently implemented without side effects
//  @custom:practise This is a practice contract made for learning.

contract NFTContract is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    mapping(address => bool) public _allowList;
    event mintedId(uint256 updatedTokenId);

    /// @param admin the initial admin to whitelist when contract is deployed.
    constructor(address admin) ERC721("Testing NFT", "TNFT") {
        _allowList[admin] = true;
    }

    /// @param walletAddress The wallet address to whitelist.
    function whitelistAdmins(address walletAddress) public {
        _allowList[walletAddress] = true;
    }

    /// @return TotalCount in integer
    function totalSupply() public view returns (uint256) {
        return _tokenIds;
    }

    // bulk minting
    /// @param numberOfTokens Number of tokens to mint
    /// @param _tokenUri The token URI passed
    function mintAllowList(uint8 numberOfTokens, string memory _tokenUri)
        external
    {
        require(_allowList[msg.sender] == true, "Invalid Minter");
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _tokenIds++;
            _safeMint(msg.sender, _tokenIds);
            _setTokenURI(_tokenIds, _tokenUri);
        }
    }

    /// @param _tokenUri The token URI passed
    /// @return TotalCount
    function singleMint(string memory _tokenUri) external returns (uint256) {
        _tokenIds++;
        _safeMint(msg.sender, _tokenIds);
        _setTokenURI(_tokenIds, _tokenUri);
        emit mintedId(_tokenIds);
        return _tokenIds;
    }
}
