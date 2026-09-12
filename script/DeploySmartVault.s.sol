// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {SmartVault} from "../src/SmartVault.sol";

contract DeploySmartVault is Script {
    function run() public {
        vm.startBroadcast();
        
        // Lock duration: 30 days
        SmartVault vault = new SmartVault(2592000);
        
        vm.stopBroadcast();

        console.log("SmartVault deployed at:", address(vault));
    }
}