// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract DeployMyNFT is Script {
    function run() public {
        vm.startBroadcast();
        MyNFT nft = new MyNFT();
        vm.stopBroadcast();
        console.log("MyNFT deployed at:", address(nft));
    }
}