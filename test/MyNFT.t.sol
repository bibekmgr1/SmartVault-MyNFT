// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    address public owner = address(0x123);
    address public user = address(0x456);

    function setUp() public {
        vm.prank(owner);             
        nft = new MyNFT();           
        vm.deal(user, 100 ether);    
    }

    function testFuzzMint(uint256 amount) public {
        vm.assume(amount >= 0.01 ether);
        vm.assume(amount <= 100 ether);

        vm.deal(user, amount);       
        vm.prank(user);               
        nft.mint{value: amount}(user); 

        assertEq(nft.ownerOf(1), user);      
        assertEq(nft.balanceOf(user), 1);    
        assertEq(nft.tokenIdCounter(), 1);   
    }

    function testFuzzMintRevertsIfInsufficientPayment(uint256 amount) public {
        vm.assume(amount < 0.01 ether);
        vm.deal(user, 1 ether);      
        vm.expectRevert(
            abi.encodeWithSelector(
                MyNFT.InsufficientPayment.selector,
                amount,               
                0.01 ether            
            )
        );

        vm.prank(user);
        nft.mint{value: amount}(user); 
    }

    function testFuzzWithdraw(uint256 amount) public {
        vm.assume(amount >= 0.01 ether);
        vm.assume(amount <= 100 ether);

        vm.deal(user, amount);
        vm.prank(user);
        nft.mint{value: amount}(user);

        uint256 ownerBalanceBefore = owner.balance;

        vm.prank(owner);             
        nft.withdraw();               

        assertEq(owner.balance, ownerBalanceBefore + amount); 
        assertEq(address(nft).balance, 0);                   
    }    
}
