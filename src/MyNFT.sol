// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {

    // CUSTOM ERRORS (Gas Saving - cheaper than require strings)
    error InsufficientPayment(uint256 sent, uint256 required); // When user pays less than MINT_PRICE
    error MaxSupplyReached(uint256 current, uint256 max);      // When all 10,000 NFTs are minted
    error NoETHToWithdraw();                                   // When contract has no ETH
    error TransferFailed();                                    // When ETH transfer fails

    // Variables
    uint256 public tokenIdCounter; // Tracks next NFT ID -> Starts at 0, goes to 1, 2, 3...
                                   // Each NFT gets a unique number: NFT #1, NFT #2, NFT #3

    // CONSTANTS (ALL CAPS - baked into bytecode, saves ~2,100 gas per read)
    uint256 public constant MAX_SUPPLY = 10000;      // Maximum NFTs -> Only 10,000 can ever exist
    uint256 public constant MINT_PRICE = 0.01 ether; // Cost to mint -> Users pay 0.01 ETH per NFT

    // Constructor
    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}
    // Sets collection name: "MyNFT"
    // Sets collection symbol: "MNFT"
    // Sets deployer as owner

    // Mint function
    function mint(address _to) public payable {
        // CUSTOM ERROR: Check if user sent enough ETH
        if (msg.value < MINT_PRICE) {
            revert InsufficientPayment(msg.value, MINT_PRICE);
        }

        // CUSTOM ERROR: Check if max supply reached
        if (tokenIdCounter >= MAX_SUPPLY) {
            revert MaxSupplyReached(tokenIdCounter, MAX_SUPPLY);
        }

        // UNCHECKED BLOCK: Safe because counter can't overflow (max 10,000)
        unchecked {
            tokenIdCounter++; // Get next unique ID (1, 2, 3...)
        }

        _safeMint(_to, tokenIdCounter); // Create NFT and send to user
    }

    // Withdraw function
    function withdraw() public onlyOwner {
        // onlyOwner -> Only contract owner can call this

        uint256 balance = address(this).balance; // Get contract's ETH balance

        // CUSTOM ERROR: Check if contract has ETH
        if (balance == 0) {
            revert NoETHToWithdraw();
        }

        // Send all ETH to owner
        (bool success, ) = payable(owner()).call{value: balance}("");

        // CUSTOM ERROR: Check if transfer worked
        if (!success) {
            revert TransferFailed();
        }
    }
}