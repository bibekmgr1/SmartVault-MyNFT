// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {

    error InsufficientPayment(uint256 sent, uint256 required); 
    error MaxSupplyReached(uint256 current, uint256 max);     
    error NoETHToWithdraw();                                 
    error TransferFailed();                                    

    uint256 public tokenIdCounter;
    uint256 public constant MAX_SUPPLY = 10000;      
    uint256 public constant MINT_PRICE = 0.01 ether; 

     constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

      function mint(address _to) public payable {
        if (msg.value < MINT_PRICE) {
            revert InsufficientPayment(msg.value, MINT_PRICE);
        }

        if (tokenIdCounter >= MAX_SUPPLY) {
            revert MaxSupplyReached(tokenIdCounter, MAX_SUPPLY);
        }
 
        unchecked {
            tokenIdCounter++; 
        }

        _safeMint(_to, tokenIdCounter); 
    }


    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        if (balance == 0) {
            revert NoETHToWithdraw();
        }

        (bool success, ) = payable(owner()).call{value: balance}("");

        if (!success) {
            revert TransferFailed();
        }
    }
}
