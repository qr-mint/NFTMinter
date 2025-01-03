// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ImprovedNFTCollection is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _nextTokenId;

    // Mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Proxy operators
    mapping(address => bool) private _operators;

    // Reentrancy lock
    bool private _reentrancyLock;

    // Events
    event TokenMinted(address indexed to, uint256 tokenId);
    event TokenURIUpdated(uint256 indexed tokenId, string tokenURI);

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        _nextTokenId.increment(); // Start token IDs at 1
    }

    /**
     * @dev Modifier to prevent reentrancy
     */
    modifier nonReentrant() {
        require(!_reentrancyLock, "Reentrant call");
        _reentrancyLock = true;
        _;
        _reentrancyLock = false;
    }

    /**
     * @dev Modifier to restrict actions to operators or owner
     */
    modifier onlyOperator() {
        require(_operators[msg.sender] || owner() == msg.sender, "Not an operator");
        _;
    }

    /**
     * @dev Mint a new token to a specific address
     */
    function mintTo(address _to) public onlyOperator {
        uint256 currentTokenId = _nextTokenId.current();
        _nextTokenId.increment();
        _safeMint(_to, currentTokenId);
        emit TokenMinted(_to, currentTokenId);
    }

    /**
     * @dev Batch mint tokens
     */
    function batchMintTo(address _to, uint256 _count) public onlyOperator {
        require(_count > 0, "Count must be greater than zero");
        for (uint256 i = 0; i < _count; i++) {
            mintTo(_to);
        }
    }

    /**
     * @dev Set a custom URI for a token
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOperator {
        require(_exists(tokenId), "Token ID does not exist");
        _tokenURIs[tokenId] = _tokenURI;
        emit TokenURIUpdated(tokenId, _tokenURI);
    }

    /**
     * @dev Override tokenURI to include custom URIs
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");
        string memory customURI = _tokenURIs[tokenId];
        if (bytes(customURI).length > 0) {
            return customURI;
        }
        return string(abi.encodePacked(baseURI(), Strings.toString(tokenId)));
    }

    /**
     * @dev Batch transfer tokens
     */
    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds
    ) public {
        require(to != address(0), "Recipient address cannot be zero");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            transferFrom(from, to, tokenIds[i]);
        }
    }

    /**
     * @dev View tokens owned by an address
     */
    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    /**
     * @dev Add or remove an operator
     */
    function setOperator(address operator, bool approved) public onlyOwner {
        _operators[operator] = approved;
    }

    /**
     * @dev Check if an address is an operator
     */
    function isOperator(address operator) public view returns (bool) {
        return _operators[operator];
    }

    /**
     * @dev Returns base URI for the collection
     */
    function baseURI() internal pure returns (string memory) {
        return "https://example.com/api/token/";
    }
}
