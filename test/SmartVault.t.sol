// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SmartVault} from "../src/SmartVault.sol";

contract SmartVaultTest is Test {

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EthSent(address indexed from, address indexed to, uint256 amount);

    SmartVault public vault;
    address public owner = address(0x123);
    address public user = address(0x456);
    address public friend = address(0x789);
    uint256 public lockDuration = 7 days;

    function setUp() public {
        vm.prank(owner);
        vault = new SmartVault(lockDuration);
        vm.deal(user, 10 ether);
        vm.deal(owner, 10 ether);
    }

    function testFuzzDeposit(uint256 amount) public {
        vm.assume(amount >= 0.001 ether);
        vm.assume(amount <= 10 ether);

        vm.expectEmit(true, false, false, true);
        emit Deposited(user, amount);

        assertEq(vault.balances(user), 0);
        assertEq(vault.getContractBalance(), 0);

        vm.deal(user, amount);
        vm.startPrank(user);
        vault.deposit{value: amount}();
        vm.stopPrank();

        assertEq(vault.balances(user), amount);
        assertEq(vault.getContractBalance(), amount);
    }

    function testFuzzWithdraw(uint256 amount) public {
        vm.assume(amount >= 0.001 ether);
        vm.assume(amount <= 10 ether);

        vm.deal(user, amount);
        vm.startPrank(user);
        vault.deposit{value: amount}();
        vm.stopPrank();

        vm.warp(block.timestamp + vault.lockDuration() + 1);

        vm.expectEmit(true, false, false, true);
        emit Withdrawn(user, amount);

        vm.startPrank(user);
        vault.withdraw(amount);
        vm.stopPrank();

        assertEq(vault.balances(user), 0);
        assertEq(vault.getContractBalance(), 0);
    }

    function testFuzzSendEth(uint256 amount) public {
        vm.assume(amount >= 0.002 ether);
        vm.assume(amount <= 10 ether);

        vm.deal(user, amount);
        vm.startPrank(user);
        vault.deposit{value: amount}();
        vm.stopPrank();

        uint256 friendBalanceBefore = friend.balance;
        uint256 sendAmount = amount / 2;
        uint256 expectRemaining = amount - sendAmount;

        vm.expectEmit(true, true, false, true);
        emit EthSent(user, friend, sendAmount);

        vm.startPrank(user);
        vault.sendEth(friend, sendAmount);
        vm.stopPrank();

        assertEq(vault.balances(user), expectRemaining);
        assertEq(vault.balances(friend), 0);
        assertEq(friend.balance, friendBalanceBefore + sendAmount);
    }

    function testFuzzReceive(uint256 amount) public {
        vm.assume(amount >= 0.01 ether);
        vm.assume(amount <= 10 ether);

        assertEq(vault.balances(user), 0);
        assertEq(vault.getContractBalance(), 0);

        vm.expectEmit(true, false, false, true);
        emit Deposited(user, amount);

        vm.deal(user, amount);
        vm.startPrank(user);
        (bool success, ) = address(vault).call{value: amount}("");
        require(success, "Direct transfer failed");
        vm.stopPrank();

        assertEq(vault.balances(user), amount);
        assertEq(vault.getContractBalance(), amount);
    }
}
