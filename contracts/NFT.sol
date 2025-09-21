// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

interface I4907 {
    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) external;

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) external view returns(address);

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) external view returns(uint256);
}

contract QRMintNFT is ERC721A, Ownable, IERC2981, I4907  {
    string private baseTokenURI;
    uint256 public royaltyFee;
    address public royaltyRecipient;
    mapping(uint256 => address) private _users;
    mapping(uint256 => uint64) private _expires;

    mapping(uint256 => string) private customURIs;

    constructor(string memory initialBaseURI, string memory contractName, uint256 _royaltyFee, address _royaltyRecipient, address initialOwner) 
        ERC721A(contractName, contractName)
        Ownable(initialOwner)
    {
        baseTokenURI = initialBaseURI;
        royaltyFee = _royaltyFee;
        royaltyRecipient = _royaltyRecipient;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    function setCustomURI(uint256 tokenId, string memory newURI) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        customURIs[tokenId] = newURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return bytes(customURIs[tokenId]).length > 0
            ? customURIs[tokenId]
            : string(abi.encodePacked(baseTokenURI, _toString(tokenId)));
    }

    function mintNFT(address to, uint256 quantity, string[] calldata metadataURIs) external onlyOwner {
        require(metadataURIs.length == quantity, "Invalid metadata URIs length");
        uint256 tokenId = _nextTokenId();
        _safeMint(to, quantity);
        _users[tokenId] = to;
        for (uint256 i = 0; i < quantity; i++) {
          customURIs[tokenId + i] = metadataURIs[i];
        }
    }

    function setUser(uint256 tokenId, address user, uint64 expires) public override onlyOwner {
      require(_exists(tokenId), "Token does not exist");
      _users[tokenId] = user;
      _expires[tokenId] = expires;
    }

    function userOf(uint256 tokenId) public view override returns (address) {
      require(_exists(tokenId), "Token does not exist");
      if (_expires[tokenId] >= block.timestamp) {
        return _users[tokenId];
      }
      return address(0);
    }

    function userExpires(uint256 tokenId) public view override returns (uint256) {
      require(_exists(tokenId), "Token does not exist");
      return _expires[tokenId];
    }

    function burnNFT(uint256 tokenId) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _burn(tokenId, false);
        delete customURIs[tokenId];
        delete _users[tokenId];
        delete _expires[tokenId];

    }

    /*** ERC-2981 Royalty Logic ***/
    function royaltyInfo(uint256, uint256 salePrice) 
        external 
        view 
        override 
        returns (address receiver, uint256 royaltyAmount) 
    {
        return (royaltyRecipient, (salePrice * royaltyFee) / 10000);
    }

    function setRoyaltyInfo(address _recipient, uint256 _fee) external onlyOwner {
        require(_fee <= 10000, "Royalty fee too high");
        royaltyRecipient = _recipient;
        royaltyFee = _fee;
    }

    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        override(ERC721A, IERC165) 
        returns (bool) 
    {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdraw failed");
    }
}
