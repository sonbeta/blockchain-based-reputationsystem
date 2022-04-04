/// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Transaction{
  address public serviceCustomerAddress;
  address public serviceProviderAddress;
  uint public dateCreation;
  uint public datePaymentPerformanceBased; //Rating
  uint public datePaymentNonPerformanceBased; 
  uint public dateFulfillment;
  uint public dateCounterRating;
  uint public deadlineFulfillment;
  uint public deadlinePayment;
  uint public deadlineRating;
  uint public lastUpdate;
  string public status;
  string public metadataSP;
  string public metadataSC;
  string public productType;
  string public serviceType;
  uint public amountPerformanceBasedPayment;
  uint public amountNonPerformanceBasedPayment;   
  uint public counterRating = 0; 
  constructor (address _serviceProviderAddress, 
        address _serviceCustomerAddress, uint _deadlinePayment, 
        uint _amountPerformanceBasedPayment, 
        uint _amountNonPerformanceBasedPayment, 
        string memory _metadataSC, string memory _metadataSP, 
        string memory _serviceType, string memory _productType){
    dateCreation = block.timestamp;
    lastUpdate = dateCreation;
    status = "Created";
    deadlinePayment = dateCreation + _deadlinePayment*24*60*60; 
    serviceProviderAddress = _serviceProviderAddress;
    serviceCustomerAddress = _serviceCustomerAddress;
    amountPerformanceBasedPayment = _amountPerformanceBasedPayment;
    amountNonPerformanceBasedPayment = _amountNonPerformanceBasedPayment;
    metadataSC = _metadataSC;
    metadataSP = _metadataSP;
    serviceType = _serviceType;
    productType = _productType;
  }
  modifier onlyStatus(string memory _status){
    require(keccak256(abi.encodePacked(status)) 
        == keccak256(abi.encodePacked(_status)), "No permission.");
    _;
  }
  function payNonPerformanceBased() public payable onlyStatus("Created"){
    require(msg.sender == serviceCustomerAddress, "No access.");
    require(msg.value == amountNonPerformanceBasedPayment, "Wrong amount.");
    require(block.timestamp < deadlinePayment, "Deadline reached.");
    datePaymentNonPerformanceBased = block.timestamp;
    lastUpdate = datePaymentNonPerformanceBased;
    deadlineFulfillment = block.timestamp + 14*24*60*60;
    status = "Paid";
  }
  function setFulfilled() public onlyStatus("Paid"){
    require (msg.sender == serviceProviderAddress, "No access.");
    require(block.timestamp < deadlineFulfillment, "Deadline reached.");
    dateFulfillment = block.timestamp;
    lastUpdate = dateFulfillment;
    status = "Fulfilled";
    deadlineRating = block.timestamp + 3*24*60*60;
  }
  function payPerformanceBased() public payable onlyStatus("Fulfilled"){
    require(msg.sender == serviceCustomerAddress, "No access.");
    require(msg.value == amountPerformanceBasedPayment, "Wrong amount.");
    require(block.timestamp < deadlineRating, "Deadline reached.");
    datePaymentPerformanceBased = block.timestamp;
    lastUpdate = datePaymentPerformanceBased;
    status = "Rated";
  }
  function rateBack(uint _counterRating) public onlyStatus("Fulfilled"){
    require(msg.sender == serviceProviderAddress, "No access.");
    require(block.timestamp > deadlineRating, "Deadline not reached.");
    require(_counterRating <= 5 && _counterRating >= 1, "Wrong number scale.");
    counterRating = _counterRating;
    dateCounterRating = block.timestamp;
    lastUpdate = dateCounterRating; 
    status = "Counterrated";
  }
  function withDraw() public {
    require(msg.sender == serviceProviderAddress, "No access.");
    payable(msg.sender).transfer(address(this).balance);
  }
  function getBalance() public view returns (uint){
    require(msg.sender == serviceProviderAddress 
        || msg.sender == serviceCustomerAddress, "No access.");
    return address(this).balance;
  }
  function getMetaData() public view returns (string memory){
    if (msg.sender == serviceCustomerAddress){
        return metadataSC;
    }else if (msg.sender == serviceProviderAddress){
        return metadataSP;
    }else{
        return "Access denied.";
    }
  }
}