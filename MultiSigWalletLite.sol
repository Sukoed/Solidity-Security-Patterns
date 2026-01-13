// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWalletLite {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredSignatures;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 approvals;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isApproved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required signatures");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            isOwner[owner] = true;
            owners.push(owner);
        }
        requiredSignatures = _required;
    }

    function submitTransaction(address _to, uint256 _value) public onlyOwner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            executed: false,
            approvals: 0
        }));
    }

    function approveTransaction(uint256 _txId) public onlyOwner {
        require(!isApproved[_txId][msg.sender], "Tx already approved");
        require(!transactions[_txId].executed, "Tx already executed");

        isApproved[_txId][msg.sender] = true;
        transactions[_txId].approvals += 1;
    }

    function executeTransaction(uint256 _txId) public onlyOwner {
        Transaction storage txn = transactions[_txId];
        require(txn.approvals >= requiredSignatures, "Not enough approvals");
        require(!txn.executed, "Already executed");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}("");
        require(success, "Tx failed");
    }
}
