// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Errors} from "./Errors.sol";
import {StableCoin} from "./StableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract StableCoinEngine is ReentrancyGuard {
    using Errors for *;

    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    StableCoin private immutable i_stableCoin;
    uint256 private constant ADDITIONAL_FEED_PRECISSION = 1e10;
    uint256 private constant PRECISSION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 200% overcollateralized
    uint256 private constant LIQUIDATION_PRECISSION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 stableCoinMinted) private s_stableCoinMinted;
    address[] private s_collateralTokens;

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
            s_collateralTokens.push(tokens[i]);
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

    // check if collateral > StableCoin amount
    function mintDsc(uint256 amountStcToMint) external moreThanZero(amountStcToMint) nonReentrant {
        s_stableCoinMinted[msg.sender] += amountStcToMint;
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalStcMinted, uint256 collateralValueUsd)
    {
        totalStcMinted = s_stableCoinMinted[user];
        collateralValueUsd = getCollateralValueInUsd(user);
    }

    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totalStcMinted, uint256 collateralValueUsd) = _getAccountInformation(user);

        uint256 collateralAdjustedForThreshold = (collateralValueUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISSION;

        return (collateralAdjustedForThreshold * PRECISSION) / totalStcMinted;
    }

    function revertIfHealthFactorIsBroken(address user) internal view {
        uint256 healthFactor = _healthFactor(user);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert Errors.StableCoin__HealthFactorIsBroken(healthFactor);
        }
    }

    function getCollateralValueInUsd(address user) public view returns (uint256 totalValueUsd) {
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalValueUsd += getUsdValue(token, amount);
        }
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);

        (, int256 price,,,) = priceFeed.latestRoundData();

        // price has 8 decimals, amount has 18 decimals,
        // eg. 1eth = 1000usd, then price = 1000 * 1e8
        // amount = 5 * 1e18
        // then usdValue = (1000 * 1e8 * 1e10) * (5 * 1e18) / 1e18 = 5000 * 1e18
        // we will get
        return (uint256(price) * ADDITIONAL_FEED_PRECISSION * amount) / PRECISSION;
    }
}
