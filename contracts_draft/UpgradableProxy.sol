// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Proxy.sol";

abstract contract UpgradableProxy is Proxy {
    address public upgradedToken;

    event Upgraded(address indexed upgradedContract);

    function deprecated() public view returns (bool) {
        return (upgradedToken != address(0));
    }

    function _upgradeContract(address upgradedContract) internal {
        require(upgradedContract != address(0));
        upgradedToken = upgradedContract;
    }

    function _implementation() internal view override returns (address) {
        if (deprecated()) {
            return upgradedToken;
        } else {
            return address(this);
        }
    }

    fallback() external payable override {
        _fallback();
    }

    receive() external payable {}
}
