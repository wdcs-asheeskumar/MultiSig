// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

contract Multisig {
    uint256 public noOfConfirmations;
    uint256 public totalConfirmations;
    bool public result = false;
    address[] internal ownerList;
    struct Transaction {
        address to;
        uint256 value;
        uint256 numOfConfirmations;
        bool transactionExecuted;
    }
    Transaction[] public transaction;
    mapping(address => bool) public listOfOwners;
    mapping(uint256 => mapping(address => bool)) public transactionList;

    modifier onlyOwner() {
        require(listOfOwners[msg.sender] == true, "Not an owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _noOfConfirmations) {
        for (uint256 i = 0; i < _owners.length; i++) {
            listOfOwners[_owners[i]] = true;
            ownerList.push(_owners[i]);
        }
        noOfConfirmations = _noOfConfirmations;
    }

    function submitTransactions(address _to, uint256 _value) public {
        uint256 txIndex = transaction.length;
        transaction.push(
            Transaction({
                to: _to,
                value: _value,
                numOfConfirmations: 0,
                transactionExecuted: false
            })
        );
    }

    function confirmTransaction(uint256 _txIndex) public onlyOwner {
        Transaction storage trans = transaction[_txIndex];
        trans.numOfConfirmations = trans.numOfConfirmations + 1;
        totalConfirmations = trans.numOfConfirmations;
        if (totalConfirmations >= noOfConfirmations) {
            executeTransaction(trans.to, trans.value);
            transactionList[_txIndex][trans.to] = true;
        }
    }

    function executeTransaction(address _address, uint256 _value)
        internal
        onlyOwner
    {
        (bool success, ) = _address.call{value: _value}("");
        require(success, "Transaction failed");
    }
}