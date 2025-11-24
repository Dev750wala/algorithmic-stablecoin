// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {StableCoinEngine} from "../src/StableCoinEngine.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeploySTC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;


    function run() external returns (StableCoin, StableCoinEngine, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        StableCoin stableCoin = new StableCoin();
        
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        StableCoinEngine stableCoinEngine = new StableCoinEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(stableCoin)
        );

        stableCoin.transferOwnership(address(stableCoinEngine));
        vm.stopBroadcast();

        return (stableCoin, stableCoinEngine, helperConfig);
    }
}
