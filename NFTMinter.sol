// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollectionMinter is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;
    
    struct Collection {
        string name;
        string symbol;
        address creator;
        uint256 supplyLimit;
        uint256 mintedCount;
    }

    // Маппинг коллекций
    mapping(uint256 => Collection) public collections;
    mapping(uint256 => uint256) public tokenToCollection;

    event CollectionCreated(uint256 collectionId, string name, string symbol, uint256 supplyLimit);
    event MintedInCollection(address recipient, uint256 tokenId, uint256 collectionId, string metadataURI);

    constructor() ERC721("NFTCollectionMinter", "NCM") {}

    // Создание коллекции
    function createCollection(string memory name, string memory symbol, uint256 supplyLimit) external onlyOwner returns (uint256) {
        uint256 collectionId = uint256(keccak256(abi.encodePacked(name, symbol, block.timestamp)));
        
        // Проверка, чтобы коллекция не существовала
        require(collections[collectionId].creator == address(0), "Collection already exists");

        collections[collectionId] = Collection({
            name: name,
            symbol: symbol,
            creator: msg.sender,
            supplyLimit: supplyLimit,
            mintedCount: 0
        });

        emit CollectionCreated(collectionId, name, symbol, supplyLimit);
        return collectionId;
    }

    // Минтинг NFT в указанной коллекции
    function mintNFT(uint256 collectionId, address recipient, string memory metadataURI) external returns (uint256) {
        Collection storage collection = collections[collectionId];

        // Проверка на существование коллекции и лимит выпуска
        require(collection.creator != address(0), "Collection does not exist");
        require(collection.mintedCount < collection.supplyLimit, "Supply limit reached");

        uint256 tokenId = nextTokenId;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, metadataURI);

        // Привязка токена к коллекции
        tokenToCollection[tokenId] = collectionId;

        collection.mintedCount++;
        nextTokenId++;

        emit MintedInCollection(recipient, tokenId, collectionId, metadataURI);
        return tokenId;
    }

    // Получение информации о коллекции
    function getCollectionInfo(uint256 collectionId) external view returns (string memory name, string memory symbol, uint256 supplyLimit, uint256 mintedCount) {
        Collection storage collection = collections[collectionId];
        return (collection.name, collection.symbol, collection.supplyLimit, collection.mintedCount);
    }

    // Получение коллекции для конкретного токена
    function getCollectionForToken(uint256 tokenId) external view returns (uint256) {
        return tokenToCollection[tokenId];
    }
}
