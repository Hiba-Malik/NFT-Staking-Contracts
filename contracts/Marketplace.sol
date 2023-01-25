// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title ERC721 Marketplace contract
/// @notice You can use this contract for single & bulk Listing
/// @dev All function calls are currently implemented without side effects
/// @custom:practise This is a practice contract made for learning.
contract Marketplace is ReentrancyGuard {
    uint256 public itemCount; //Number of items

    struct Item {
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    //Indexed will alow us to use those fields as filters
    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );
    event BulkOffered(
        uint256 itemId,
        address indexed nft,
        uint256[] tokenId,
        uint256 price,
        address indexed seller
    );
    event Bought(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    mapping(uint256 => Item) public items;

    constructor() {}

    // Make item to offer on the marketplace
    /// @param _nft The nft contract instance
    /// @param _tokenId The token ID to list
    /// @param _price The price of the nft
    function listItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        // increment itemCount
        itemCount++;
        // transfer nft
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        // add new item to items mapping
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        // emit Offered event
        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    // Make multiple items to offer on the marketplace
    /// @param _nft The nft contract instance
    /// @param _tokenIds The array containing the specific token IDs to list
    /// @param _price The price of the nft
    function bulkListItems(
        IERC721 _nft,
        uint256[] calldata _tokenIds,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            // increment itemCount
            itemCount++;
            // transfer nft
            _nft.transferFrom(msg.sender, address(this), _tokenIds[i]);
            // add new item to items mapping
            items[itemCount] = Item(
                itemCount,
                _nft,
                _tokenIds[i],
                _price,
                payable(msg.sender),
                false
            );
            // emit Offered event
            emit BulkOffered(
                itemCount,
                address(_nft),
                _tokenIds,
                _price,
                msg.sender
            );
        }
    }

    /// @param _itemId The nft Id whose ownership to transfer
    function purchaseItem(uint256 _itemId) external payable nonReentrant {
        uint256 _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "0x0");
        require(msg.value >= _totalPrice, "0x1");
        require(!item.sold, "0x2");
        // pay seller and feeAccount
        item.seller.transfer(item.price);
        // update item to sold
        item.sold = true;
        // transfer nft to buyer
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        delete items[_itemId];
        // emit Bought event
        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    /// @param _itemId The nft id whose price is being queried
    /// @return Price Of the nft queried
    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((items[_itemId].price));
    }
}
