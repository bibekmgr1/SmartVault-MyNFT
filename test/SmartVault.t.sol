// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SmartVault} from "../src/SmartVault.sol";


contract SmartVaultTest is Test {
     
     // declare events
     event Deposited(address indexed user, uint256 amount);
     event Withdrawn(address indexed user, uint256 amount);
     event EthSent(address indexed from, address indexed to, uint256 amount);

    // 1. Declare variables

    SmartVault public vault;
    address public owner = address(0x123);
    address public user = address(0x456);
    address public friend = address(0x789);
    uint256 public lockDuration = 7 days;

    // 2. setUp runs before every Test

    function setUp() public {
        vm.prank(owner); // uses owner variable
        vault = new SmartVault(lockDuration);
        vm.deal(user, 10 ether);
        vm.deal(owner, 10 ether);
        vm.deal(owner, 10 ether);
        
    }

    function testFuzzDeposit(uint256 amount) public {
        vm.assume(amount >= 0.001 ether);
        vm.assume(amount <= 10 ether);

        // 2. listen for event first 
        vm.expectEmit(true, false, false, true);
        emit Deposited(user, amount);

        // 3. check initial state
        assertEq(vault.balances(user), 0);
        assertEq(vault.getContractBalance(), 0);

        // 4. perform the action

        vm.deal(user, amount);
        vm.startPrank(user);
        vault.deposit{value: amount}();
        vm.stopPrank();

        // 5. check all state changes

        assertEq(vault.balances(user), amount);
        assertEq(vault.getContractBalance(), amount);

    }

       function testFuzzWithdraw(uint256 amount) public {
         vm.assume(amount > 0);
        vm.assume(amount >= 0);
        vm.assume(amount <= 10 ether);

        // setup deposit
        vm.deal(user, amount);
        vm.startPrank(user);
        vault.deposit{value: amount}();
        vm.stopPrank();

        // jump time time
        vm.warp(block.timestamp + vault.lockDuration() + 1);

        //listen event first 
        vm.expectEmit(true, false, false, true);
        emit Withdrawn(user, amount);

        // withdraw
        vm.startPrank(user);
        vault.withdraw(amount);
        vm.stopPrank();

        // check 
        assertEq(vault.balances(user), 0);
        assertEq(vault.getContractBalance(), 0);
       }

       // send Eth test 
       function testFuzzSendEth(uint256 amount) public {
        vm.assume(amount >= 0.002 ether);
        vm.assume(amount <= 10 ether);

        // 1. Deposit
        vm.deal(user, amount);
        vm.startPrank(user);
        vault.deposit{value: amount}();
        vm.stopPrank();

        uint256 friendBalanceBefore = friend.balance;
        uint256 sendAmount = amount / 2;
        uint256 expectRemaining = amount - sendAmount;

        // event tests 
        vm.expectEmit(true, true, false, true);
        emit EthSent(user, friend, sendAmount);
        vm.stopPrank();


        // 
        vm.startPrank(user);
        vault.sendEth(friend, sendAmount);
        vm.stopPrank();

        // always keep checks
        assertEq(vault.balances(user), expectRemaining);
        assertEq(vault.balances(friend), 0);
        assertEq(friend.balance, friendBalanceBefore + sendAmount);
        }


        // receive fuzz test

        function testFuzzReceive(uint256 amount) public {
            vm.assume(amount >= 0.01 ether);
            vm.assume(amount <= 10 ether);

            // 1. check initial state
            assertEq(vault.balances(user), 0);
            assertEq(vault.getContractBalance(), 0);

            // 2. listen for events 
            vm.expectEmit(true, false, false, true);
            emit Deposited(user, amount);

            // 3. use low level call 
            vm.deal(user, amount);
            vm.startPrank(user);
            (bool success, ) = address(vault).call{value: amount}("");
            require(success, "Direct transfer failed");
            vm.stopPrank();

            // check state changes
            assertEq(vault.balances(user), amount);
            assertEq(vault.getContractBalance(), amount);
        }
   
}