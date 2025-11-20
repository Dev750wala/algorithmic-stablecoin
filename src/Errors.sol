// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

library Errors {
    error StableCoin__MustBeMoreThanZero();
    error StableCoin__BurnAmountExceedsBalance();
    error StableCoin__ZeroAddressProvided();
    error StableCoin__TokenAddressesAndPriceFeedAddressesMustBeOfSameLength();
    error StableCoin__TokenNotAllowed();
    error StableCoin__TransferFailed();
    error StableCoin__HealthFactorIsBroken(uint256 healthFactor);
    error StableCoin__MintFailed();
}
