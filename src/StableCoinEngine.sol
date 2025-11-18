// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Errors} from "./Errors.sol";
import {StableCoin} from "./StableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StableCoinEngine is ReentrancyGuard {
    using Errors for *;

    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    StableCoin private immutable i_stableCoin;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Errors.StableCoin__MustBeMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert Errors.StableCoin__TokenNotAllowed();
        }
        _;
    }

    constructor(address[] memory tokens, address[] memory priceFeeds, address stcAddress) {
        // USD pricefeeds
        if (tokens.length != priceFeeds.length) {
            revert Errors.StableCoin__TokenAddressesAndPriceFeedAddressesMustBeOfSameLength();
        }
        for (uint256 i = 0; i < tokens.length; i++) {
            s_priceFeeds[tokens[i]] = priceFeeds[i];
        }
        i_stableCoin = StableCoin(stcAddress);
    }

    function depositCollateralAndMintDsc() external {}

    function depositCollateral(address tokenCollateral, uint256 amount)
        external
        moreThanZero(amount)
        isAllowedToken(tokenCollateral)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateral] += amount;
        emit CollateralDeposited(msg.sender, tokenCollateral, amount);
        bool success = IERC20(tokenCollateral).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert Errors.StableCoin__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
