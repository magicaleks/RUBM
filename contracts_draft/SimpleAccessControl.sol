// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract SimpleAccessControl is Ownable2Step {
    mapping(address => bytes32) public authorizedAccounts;

    bytes32 public constant MINTER = keccak256("MINTER");

    modifier accessOnly(bytes32 access) {
        require(hasRole(msg.sender, access));
        _;
    }

    function hasRole(address account, bytes32 access)
        public
        view
        returns (bool)
    {
        return authorizedAccounts[account] == access;
    }

    function grantRole(address account, bytes32 access) public onlyOwner() {
        require(!hasRole(account, access));
        authorizedAccounts[account] = access;
    }

    function revokeRole(address account, bytes32 access) public onlyOwner() {
        require(hasRole(account, access));
        delete authorizedAccounts[account];
    }
}
