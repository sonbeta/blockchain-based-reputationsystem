// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./01_Transaction.sol";
contract System{
    mapping(address => bool) public verifiedUsers;
    mapping(address => string) public addressPublicKey;
    mapping(address => uint) public userVerificationDate;
    mapping(string => address) public usernamesFromString;
    mapping(address => string) public usernamesFromAddress;
    Transaction[] public transactionHistory;
    address[] public verifiedUsersList;
    function addUsername(string memory _username) public{
        require(verifiedUsers[msg.sender] == true, "Not verified.");
        require(keccak256(abi.encodePacked(usernamesFromAddress[msg.sender]))
            == keccak256(abi.encodePacked("")), "Sender username exists already.");
        require(usernamesFromString[_username] == address(0), "Username is taken.");
        usernamesFromAddress[msg.sender] = _username;
        usernamesFromString[_username] = msg.sender;
    }
    function addPublicKey(string memory _publickey) public{
        require(verifiedUsers[msg.sender] == true, "Not verified.");
        addressPublicKey[msg.sender] = _publickey;
    }
    function verify() public {
        require(verifiedUsers[msg.sender] == false, "Already verified.");
        verifiedUsers[msg.sender] = true;
        userVerificationDate[msg.sender] = block.timestamp;
        verifiedUsersList.push(msg.sender);
    }
    function createTransaction(address _serviceCustomerAddress, 
        uint _deadlinePayment, uint _amountPerformanceBasedPayment, 
        uint _amountNonPerformanceBasedPayment, 
        string memory _metadataSC, string memory _metadataSP, 
        string memory _serviceType, string memory _productType) public{
    require(verifiedUsers[msg.sender] == true, "Not verified.");
    require(verifiedUsers[_serviceCustomerAddress] == true, "SC not verified.");
    require(_serviceCustomerAddress != msg.sender, "SP and SC must differ.");
    Transaction t = new Transaction(msg.sender, _serviceCustomerAddress, 
                        _deadlinePayment, _amountPerformanceBasedPayment, 
                        _amountNonPerformanceBasedPayment, _metadataSC, 
                        _metadataSP, _serviceType, _productType);
    transactionHistory.push(t);
    }
}