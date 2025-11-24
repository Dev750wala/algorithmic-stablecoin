// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {DeploySTC} from "../../script/DeploySTC.s.sol";
import {StableCoin} from "../../src/StableCoin.sol";
import {StableCoinEngine} from "../../src/StableCoinEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {console} from "forge-std/console.sol";

contract StableCoinEngineTest is Test {
    DeploySTC deployer;
    StableCoin stableCoin;
    StableCoinEngine stableCoinEngine;
    HelperConfig helperConfig;
    address wethUsdPriceFeed;
    address wbtcUsdPriceFeed;
    address weth;
    address wbtc;

    function setUp() public {
        deployer = new DeploySTC();
        (stableCoin, stableCoinEngine, helperConfig) = deployer.run();
        (wethUsdPriceFeed,, weth,,) = helperConfig.activeNetworkConfig();
    }

    function testGetUsdValue() public view {
        uint256 amountWeth = 15e18;
        uint256 expectedPrice = 30000e18;
        uint256 actualUsd = stableCoinEngine.getUsdValue(weth, amountWeth);

        console.log("Actual USD Value:", actualUsd);
        console.log("Expected USD value:", expectedPrice);

        assertEq(expectedPrice, actualUsd);
    }
}
