// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./UpgradableProxy.sol";
// import "./SimpleAccessControl.sol";
import "./Regulated.sol";

abstract contract StandartToken {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual {
        require(to != address(0));
        _transfer(msg.sender, to, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(to != address(this));
        require(_balances[from] >= value);
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual {
        require(spender != address(0));
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual {
        require((from != address(0)) && (to != address(0)));
        require(_allowances[from][msg.sender] >= value);
        _transfer(from, to, value);
        _allowances[from][msg.sender] -= value;
    }
}

contract RuthenToken is StandartToken, UpgradableProxy, Ownable2Step {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals;

    string public constant VERSION = "0.0.1";

    event Issue(uint256 value);
    event Redeem(uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        uint8 _decimals,
        address initialOwner
    ) Ownable(initialOwner) {
        name = _name;
        symbol = _symbol;
        totalSupply = initialSupply;
        decimals = _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (deprecated()) {
            return StandartToken(upgradedToken).balanceOf(account);
        } else {
            return super.balanceOf(account);
        }
    }

    function transfer(address to, uint256 value) public override {
        if (deprecated()) {
            StandartToken(upgradedToken).transfer(to, value);
        } else {
            super.transfer(to, value);
        }
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        if (deprecated()) {
            return StandartToken(upgradedToken).allowance(owner, spender);
        } else {
            return super.allowance(owner, spender);
        }
    }

    function approve(address spender, uint256 value) public override {
        if (deprecated()) {
            StandartToken(upgradedToken).approve(spender, value);
        } else {
            super.approve(spender, value);
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override {
        if (deprecated()) {
            StandartToken(upgradedToken).transferFrom(from, to, value);
        } else {
            super.transferFrom(from, to, value);
        }
    }

    function upgradeContract(address upgradedContract) external onlyOwner {
        _upgradeContract(upgradedContract);
    }

    function issue(address account, uint256 value) external {
        totalSupply += value;
        emit Issue(value);
        _transfer(address(this), account, value);
    }

    function redeem(uint256 value) external {
        totalSupply -= value;
        emit Redeem(value);
        _transfer(msg.sender, address(this), value);
    }
}
