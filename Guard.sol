// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecurityStore {
    bool private locked;
    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
}
