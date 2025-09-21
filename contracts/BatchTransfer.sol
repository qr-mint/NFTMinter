// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BatchTransfer {
  error ArraysLengthMismatch(uint256 recipientsLength, uint256 amountsLength);

  event ERC20Transfer(address indexed token, 
                      address indexed from, 
                      address indexed to, 
                      uint256 amount);
  event NativeTransfer(address indexed from, 
                       address indexed to, 
                       uint256 amount);

  function batchTransfer(
     address[] calldata recipients,
     uint256[] calldata amounts,
     address tokenAddress
   ) external payable {
     if(recipients.length != amounts.length) {
       revert ArraysLengthMismatch(recipients.length, amounts.length);
     }

     if (tokenAddress == address(0)) {
        for (uint256 i = 0; i < recipients.length; i++) {
           address recipient = recipients[i];
           payable(recipient).transfer(amounts[i]);
           emit NativeTransfer(msg.sender, recipient, amounts[i]);
        }
      } else {
         IERC20 token = IERC20(tokenAddress);

         for (uint256 i = 0; i < recipients.length; i++) {
           address recipient = recipients[i];
           token.transferFrom(msg.sender, recipient, amounts[i]);
           emit ERC20Transfer(tokenAddress, msg.sender, recipient, amounts[i]);
          }
       }

       if(address(this).balance > 0) {
         payable(msg.sender).transfer(address(this).balance);
       }
    }
}