// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VaultSecurityGuard
 * @dev Secure vault with ReentrancyGuard and withdrawal limits.
 */
contract VaultSecurityGuard {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) public lastWithdrawTime;
    
    uint256 public constant WITHDRAW_LIMIT = 1 ether;
    uint256 public constant COOLDOWN_PERIOD = 24 hours;
    
    bool private _locked;

    modifier noReentrant() {
        require(!_locked, "Security: Reentrant call detected");
        _locked = true;
        _;
        _locked = false;
    }

    function deposit() external payable {
        _balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external noReentrant {
        require(_balances[msg.sender] >= amount, "Security: Insufficient balance");
        require(amount <= WITHDRAW_LIMIT, "Security: Exceeds daily limit");
        require(block.timestamp >= lastWithdrawTime[msg.sender] + COOLDOWN_PERIOD, "Security: Cooldown active");

        _balances[msg.sender] -= amount;
        lastWithdrawTime[msg.sender] = block.timestamp;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Security: Transfer failed");
    }

    function getBalance(address account) public view returns (uint256) {
        return _balances[account];
    }
}
