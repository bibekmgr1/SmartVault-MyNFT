// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    address public owner = address(0x123);
    address public user = address(0x456);

    // Runs before every test
    function setUp() public {
        vm.prank(owner);              // Deploy as owner
        nft = new MyNFT();            // Deploy contract
        vm.deal(user, 100 ether);     // Give user ETH to mint
    }

    // ============ FUZZ MINT (SUCCESS) ============
    function testFuzzMint(uint256 amount) public {
        // Amount must be >= mint price and <= 100 ether
        vm.assume(amount >= 0.01 ether);
        vm.assume(amount <= 100 ether);

        vm.deal(user, amount);        // Give user exact amount
        vm.prank(user);               // Prank set right before call
        nft.mint{value: amount}(user); // User mints NFT

        assertEq(nft.ownerOf(1), user);      // NFT #1 owned by user
        assertEq(nft.balanceOf(user), 1);    // User has 1 NFT
        assertEq(nft.tokenIdCounter(), 1);   // Counter incremented
    }

    // ============ FUZZ MINT (INSUFFICIENT PAYMENT) ============
    function testFuzzMintRevertsIfInsufficientPayment(uint256 amount) public {
        // Amount must be LESS than mint price
        vm.assume(amount < 0.01 ether);

        vm.deal(user, 1 ether);       // Give user plenty of ETH

        //  expectRevert FIRST
        vm.expectRevert(
            abi.encodeWithSelector(
                MyNFT.InsufficientPayment.selector,
                amount,               // Amount sent
                0.01 ether            // Amount required
            )
        );

        //  prank SECOND (right before call)
        vm.prank(user);
        nft.mint{value: amount}(user); // Should revert
    }
    function testFuzzWithdraw(uint256 amount) public {
        // Amount must be >= mint price and <= 100 ether
        vm.assume(amount >= 0.01 ether);
        vm.assume(amount <= 100 ether);

        // 1. User mints NFT (ETH goes into contract)
        vm.deal(user, amount);
        vm.prank(user);
        nft.mint{value: amount}(user);

        // 2. Record owner balance BEFORE withdraw
        uint256 ownerBalanceBefore = owner.balance;

        // 3. Owner withdraws
        vm.prank(owner);              // Prank set right before call
        nft.withdraw();               // Owner takes ETH

        // 4. Check balances
        assertEq(owner.balance, ownerBalanceBefore + amount); // Owner got ETH
        assertEq(address(nft).balance, 0);                    // Contract empty
    }

    
}