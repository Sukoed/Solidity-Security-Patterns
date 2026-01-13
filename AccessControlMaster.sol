// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AccessControlMaster
 * @dev implementation of role-based access control with emergency stops.
 */
contract AccessControlMaster {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    mapping(bytes32 => mapping(address => bool)) private _roles;
    bool public paused;

    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);
    event EmergencyPaused(address account);

    modifier onlyRole(bytes32 role) {
        require(_roles[role][msg.sender], "AccessControl: account lacks role");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() {
        _roles[ADMIN_ROLE][msg.sender] = true;
    }

    function grantRole(bytes32 role, address account) public onlyRole(ADMIN_ROLE) {
        _roles[role][account] = true;
        emit RoleGranted(role, account);
    }

    function revokeRole(bytes32 role, address account) public onlyRole(ADMIN_ROLE) {
        _roles[role][account] = false;
        emit RoleRevoked(role, account);
    }

    function setPaused(bool _paused) public onlyRole(ADMIN_ROLE) {
        paused = _paused;
        if (_paused) emit EmergencyPaused(msg.sender);
    }

    function importantFunction() public whenNotPaused onlyRole(OPERATOR_ROLE) {
        // Complex logic here
    }
}
