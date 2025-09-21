// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "./AddressNFTv1.sol";
import "./AddressNFTv2.sol";
import "./AddressNFTv3.sol";
import "./AddressNFTv5.sol";

contract Collection is Ownable, IERC2981  {
    uint256 public royaltyFee;
    address public royaltyRecipient;
    uint256 public nftVersion;

    address[] public allTokens; // Храним адреса созданных токенов

    event TokenCreated(address indexed tokenAddress, address indexed owner);

    constructor(uint256 _royaltyFee, address _royaltyRecipient, address initialOwner, uint256 version) 
        Ownable(initialOwner)
    {
        require(version >= 1 && version <= 5, "Invalid NFT version");
        royaltyFee = _royaltyFee;
        royaltyRecipient = _royaltyRecipient;
        nftVersion = version;
    }

    function getNftAddress(uint256 index) public view returns (address) {
        return allTokens[index];
    }

    function mintNFT(
        uint256 contractId,
        address collectionAddress,
        address nftOwner,
        string memory metadata_url,
        uint256 commission,
        address commissionWallet
    ) external onlyOwner returns (address) {
        if (nftVersion == 1) {
            AddressNFTv1 newToken = new AddressNFTv1(
                contractId,
                collectionAddress,
                nftOwner, // Владелец нового токена
                metadata_url,
                commission,
                commissionWallet
            );
            allTokens.push(address(newToken));
            emit TokenCreated(address(newToken), msg.sender);
        
            return address(newToken);
        }  else if (nftVersion == 2) {
            AddressNFTv2 newToken = new AddressNFTv2(
                contractId,
                collectionAddress,
                nftOwner,
                metadata_url
            );
            allTokens.push(address(newToken));
            emit TokenCreated(address(newToken), msg.sender);
        
            return address(newToken);
        } else if (nftVersion == 3) {
            AddressNFTv3 newToken = new AddressNFTv3(
                contractId,
                collectionAddress,
                nftOwner,
                metadata_url
            );
            allTokens.push(address(newToken));
            emit TokenCreated(address(newToken), msg.sender);
        
            return address(newToken);
        } else if (nftVersion == 5) {
            AddressNFTv5 newToken = new AddressNFTv5(
                contractId,
                collectionAddress,
                nftOwner,
                metadata_url,
                commission,
                commissionWallet
            );
            allTokens.push(address(newToken));
            emit TokenCreated(address(newToken), msg.sender);
        
            return address(newToken);
        }
        revert("Unsupported version");
    }

    function setRoyaltyInfo(address _recipient, uint256 _fee) external onlyOwner {
        require(_fee <= 10000, "Royalty fee too high");
        royaltyRecipient = _recipient;
        royaltyFee = _fee;
    }

    function royaltyInfo(uint256, uint256 salePrice) 
        external 
        view 
        override 
        returns (address receiver, uint256 royaltyAmount) 
    {
        return (royaltyRecipient, (salePrice * royaltyFee) / 10000);
    }

    function supportsInterface(bytes4 interfaceId) 
        public 
        pure 
        override(IERC165) 
        returns (bool) 
    {
        return 
            interfaceId == type(IERC2981).interfaceId || 
            interfaceId == type(IERC165).interfaceId;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdraw failed");
    }
}
