// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMinter is ERC721URIStorage {
    address public owner;
    uint256 public nextTokenId;

    constructor() ERC721("API NFT", "APINFT") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function mintNFT(address recipient, string memory metadataURI) public onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, metadataURI);
        nextTokenId++;
        return tokenId;
    }
}
