// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpecificNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    /**
     * @dev Минт нового токена с URI.
     * @param to адрес получателя
     * @param tokenURI URI метаданных токена
     */
    function mintToken(address to, string memory tokenURI) public onlyOwner {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _mint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
    }
}
