// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {StableCoinEngine} from "../src/StableCoinEngine.sol";
import {StableCoin} from "../src/StableCoin.sol";

contract DeploySTC is Script {
    function run() external returns (StableCoin, StableCoinEngine) {
        vm.startBroadcast();
        StableCoin stableCoin = new StableCoin();

        StableCoinEngine stableCoinEngine = new StableCoinEngine([], [], address(stableCoin));
        vm.stopBroadcast();
    }
}
