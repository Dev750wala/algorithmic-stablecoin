// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {StableCoinEngine} from "../src/StableCoinEngine.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeploySTC is Script {
    function run() external returns (StableCoin, StableCoinEngine) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        StableCoin stableCoin = new StableCoin();

        StableCoinEngine stableCoinEngine = new StableCoinEngine(
            [networkConfig.weth, networkConfig.wbtc],
            [networkConfig.wethUsdPriceFeed, networkConfig.wbtcUsdPriceFeed],
            address(stableCoin)
        );
        vm.stopBroadcast();
    }
}
