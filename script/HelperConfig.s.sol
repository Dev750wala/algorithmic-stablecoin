// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed; 
        address weth;
        address wbtc;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {}

    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
                wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
                weth: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9,
                wbtc: 0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.wethUsdPriceFeed != address(0)) {
            return activeNetworkConfig;
        }

        console.log("Deploying mocks...");

        vm.startBroadcast();
        address wethUsdPriceFeed = address(new MockV3Aggregator(18, 2000e18));
        address wbtcUsdPriceFeed = address(new MockV3Aggregator(8, 30000e8));
        address weth = address(new MockWETH());
        address wbtc = address(new MockWBTC());
        vm.stopBroadcast();

        return
            NetworkConfig({
                wethUsdPriceFeed: wethUsdPriceFeed,
                wbtcUsdPriceFeed: wbtcUsdPriceFeed,
                weth: weth,
                wbtc: wbtc,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }
}
