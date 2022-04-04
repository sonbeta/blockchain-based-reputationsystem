// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "./TransactionWithoutConstructor.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testTransaction is TransactionWithoutConstructor{

    address acc0;
    address acc1;
    address acc2;

    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);     

        dateCreation = block.timestamp;
        lastUpdate = dateCreation;
        status = "Created";
        deadlinePayment = block.timestamp + 1*24*60*60; 
        serviceProviderAddress = acc0;
        serviceCustomerAddress = acc1;
        amountPerformanceBasedPayment = 100;
        amountNonPerformanceBasedPayment = 900;
        metadataSC = "metadataSC";
        metadataSP = "metadataSP";
        serviceType = "serviceType";
        productType = "productType"; 
    }

    // IMPORTANT NOTICE
    // for the testsuite inheriting classes with constructors that have parameters does crash the Unit Testing Plugin
    // Therefore the Transaction-class was replaced with a modified Transaction class "TransactionWithoutConstructor"
    function checkTransactionData() public{
        Assert.ok(serviceProviderAddress == acc0, "");
        Assert.ok(serviceCustomerAddress == acc1, "");
        Assert.ok(amountNonPerformanceBasedPayment == 900, "");
        Assert.ok(amountPerformanceBasedPayment == 100, "");
        Assert.equal(metadataSC, "metadataSC", "");
        Assert.equal(metadataSP, "metadataSP", "");
        Assert.equal(serviceType, "serviceType", "");
        Assert.equal(productType, "productType", "");
    }

    /// #sender: account-1
    /// #value: 900
    function checkPayNonPerformanceBased() public payable{       
        //require(msg.sender == serviceCustomerAddress, "No access.");          
        // msg.sender is address(this)
        Assert.notEqual(address(this), serviceCustomerAddress, "");  
        try (this).payNonPerformanceBased(){

        }catch Error(string memory message){
            Assert.equal(message, "No access.", "");
        }

        //require(msg.value == amountNonPerformanceBasedPayment, "Wrong amount.");
        // msg.sender is address(this)
        serviceCustomerAddress = address(this);
        Assert.equal(address(this), serviceCustomerAddress, "");
        try (this).payNonPerformanceBased{value: 899}(){

        }catch Error(string memory message){
            Assert.equal(message, "Wrong amount.", "");
            serviceCustomerAddress = acc1;
        }
        //require(block.timestamp < deadlinePayment, "Deadline reached.");
        // msg.sender is address(this)
        serviceCustomerAddress = address(this);
        uint256 temp = deadlinePayment;
        deadlinePayment = block.timestamp-1;
        Assert.equal(address(this), serviceCustomerAddress, "");
        Assert.ok(block.timestamp > deadlinePayment, "");
        try (this).payNonPerformanceBased{value: 900}(){

        }catch Error(string memory message){
            Assert.equal(message, "Deadline reached.", "");
            deadlinePayment = temp;
            serviceCustomerAddress = acc1;
        }

        // every requirement is met
        Assert.equal(serviceCustomerAddress, acc1, "");
        Assert.equal(status, "Created", "");
        Assert.equal(msg.value, amountNonPerformanceBasedPayment, "");

        payNonPerformanceBased();

        // check correctness of changes
        Assert.equal(lastUpdate, block.timestamp, "");
        Assert.equal(datePaymentNonPerformanceBased, block.timestamp, "");
        Assert.equal(deadlineFulfillment, block.timestamp + 14*24*60*60, "");
        Assert.equal(status, "Paid", "");
        Assert.equal(getBalance(), 900, "");

        // modifier onlyStatus("Created")
        // function only callable if status is "Created"
        // msg.sender is address(this)
        serviceCustomerAddress = address(this);
        Assert.notEqual(status, "Created", "");
        try (this).payNonPerformanceBased{value: 900}(){

        }catch Error(string memory message){
            Assert.equal(message, "No permission.", "");
            serviceCustomerAddress = acc1;
        }
    }

    /// #sender: account-0
    function checkSetFulfilled() public{
        // require (msg.sender == serviceProviderAddress, "No access.");
        // msg.sender is address(this)
        Assert.notEqual(address(this), serviceProviderAddress, "");
        try (this).setFulfilled(){

        }catch Error(string memory message){
            Assert.equal(message, "No access.", "");
        }

        // require(block.timestamp < deadlineFulfillment, "Deadline reached.");        
        // msg.sender is address(this)
        serviceProviderAddress = address(this);
        uint256 temp = deadlineFulfillment;
        deadlineFulfillment = block.timestamp-1;
        Assert.equal(address(this), serviceProviderAddress, "");
        Assert.ok(block.timestamp > deadlineFulfillment, "");
        try (this).setFulfilled(){

        }catch Error(string memory message){
            Assert.equal(message, "Deadline reached.", "");
            deadlineFulfillment = temp;
            serviceProviderAddress = acc0;
        }

        // all requirements are met
        Assert.equal(status, "Paid", "");
        Assert.equal(msg.sender, serviceProviderAddress, "");
        Assert.ok(block.timestamp < deadlineFulfillment, "");

        setFulfilled();       

        // check changes if correct
        Assert.equal(lastUpdate, block.timestamp, "");
        Assert.equal(dateFulfillment, block.timestamp, "");
        Assert.equal(status, "Fulfilled", "");
        Assert.equal(deadlineRating, block.timestamp + 3*24*60*60, "");

        // modifier onlyStatus("Paid")
        // function only callable if status is "Paid"
        serviceProviderAddress = address(this);
        Assert.equal(serviceProviderAddress, address(this), "");
        Assert.ok(block.timestamp < deadlineFulfillment, "");
        Assert.notEqual(status, "Paid", "");
        try (this).setFulfilled(){

        }catch Error(string memory message){
            Assert.equal(message, "No permission.", "");
            serviceProviderAddress = acc0;
        }
    }

    /// #sender: account-1
    /// #value: 100
    function checkPayPerformanceBased() public payable{
        //require(msg.sender == serviceCustomerAddress, "No access.");        
        // msg.sender is address(this)
        Assert.notEqual(address(this), serviceCustomerAddress, "");
        try (this).payPerformanceBased(){

        }catch Error(string memory message){
            Assert.equal(message, "No access.", "");
        }

        //require(msg.value == amountPerformanceBasedPayment, "Wrong amount.");
        // msg.sender is address(this)
        serviceCustomerAddress = address(this);
        Assert.equal(address(this), serviceCustomerAddress, "");
        try (this).payPerformanceBased{value: 99}(){

        }catch Error(string memory message){
            Assert.equal(message, "Wrong amount.", "");
            serviceCustomerAddress = acc1;
        }

        //require(block.timestamp < deadlineRating, "Deadline reached.");
        // msg.sender is address(this)
        serviceCustomerAddress = address(this);
        uint256 temp = deadlineRating;
        deadlineRating = block.timestamp-1;
        Assert.equal(address(this), serviceCustomerAddress, "");
        Assert.ok(block.timestamp > deadlineRating, "");
        try (this).payPerformanceBased{value: 100}(){

        }catch Error(string memory message){
            Assert.equal(message, "Deadline reached.", "");
            deadlineRating = temp;
            serviceCustomerAddress = acc1;
        }

        // every requirement is met
        Assert.equal(serviceCustomerAddress, acc1, "");
        Assert.equal(status, "Fulfilled", "");
        Assert.equal(msg.value, amountPerformanceBasedPayment, "");
        Assert.ok(block.timestamp < deadlineRating, "");

        payPerformanceBased();

        // check correctness of changes
        Assert.equal(lastUpdate, block.timestamp, "");
        Assert.equal(datePaymentPerformanceBased, block.timestamp, "");
        Assert.equal(status, "Rated", "");
        Assert.equal(getBalance(), 1000, "");

        // modifier onlyStatus("Fulfilled")
        // function only callable if status is "Fulfilled"
        // msg.sender is address(this)
        serviceCustomerAddress = address(this);
        Assert.notEqual(status, "Fulfilled", "");
        try (this).payNonPerformanceBased{value: 900}(){

        }catch Error(string memory message){
            Assert.equal(message, "No permission.", "");
            serviceCustomerAddress = acc1;
        }
    }

    /// #sender: account-0
    function checkRateBack() public{
        // reset, if it was not rated and deadline is reached
        datePaymentNonPerformanceBased = 0;
        status = "Fulfilled";
        deadlineRating = block.timestamp-1;

        // require(msg.sender == serviceProviderAddress, "No access.");        
        // msg.sender is address(this)
        Assert.notEqual(address(this), serviceProviderAddress, "");
        try (this).rateBack(3){

        }catch Error(string memory message){
            Assert.equal(message, "No access.", "");
        }

        // require(block.timestamp > deadlineRating, "Deadline not reached.");
        // msg.sender is address(this)
        serviceProviderAddress = address(this);
        deadlineRating = block.timestamp+1;
        Assert.equal(address(this), serviceProviderAddress, "");
        Assert.ok(block.timestamp < deadlineRating, "2");
        try (this).rateBack(3){

        }catch Error(string memory message){
            Assert.equal(message, "Deadline not reached.", "");
            deadlineRating = block.timestamp-1;
            serviceProviderAddress = acc0;
        }

        // require(_counterRating <= 5 && _counterRating >= 1, "Wrong number scale.");
        status = "Fulfilled";
        serviceProviderAddress = address(this);        
        Assert.equal(status, "Fulfilled", "");
        Assert.equal(address(this), serviceProviderAddress, "");
        Assert.ok(block.timestamp > deadlineRating, "");
        try (this).rateBack(6){

        }catch Error(string memory message){
            Assert.equal(message, "Wrong number scale.", "");
            serviceProviderAddress = acc0;
        }

        // every requirement is met    
        Assert.equal(status, "Fulfilled", "");
        Assert.equal(msg.sender, serviceProviderAddress, "");
        Assert.ok(block.timestamp > deadlineRating, "");

        rateBack(3);        

        // check correctness of changes
        Assert.equal(counterRating, 3, "");
        Assert.equal(lastUpdate, block.timestamp, "");
        Assert.equal(dateCounterRating, block.timestamp, "");
        Assert.equal(status, "Counterrated", "");
       
        // modifier onlyStatus("Fulfilled")
        // function only callable if status is "Fulfilled"
        // msg.sender is address(this)
        serviceProviderAddress = address(this);
        Assert.notEqual(status, "Fulfilled", "");
        try (this).rateBack(3){

        }catch Error(string memory message){
            Assert.equal(message, "No permission.", "");
            serviceProviderAddress = acc0;
        }
    }

    /// #sender: account-0
    function checkWithDraw() public {
        Assert.notEqual(address(this), serviceProviderAddress, "");        
        try (this).withDraw(){

        }catch Error(string memory message){
            Assert.equal(message, "No access.", "");
            Assert.equal(getBalance(), 1000, "");
        }

        // requirements met
        Assert.equal(msg.sender, serviceProviderAddress, "");
        uint balanceBefore = TestsAccounts.getAccount(0).balance;
        withDraw();
        
        // check correctness of changes
        uint balanceAfter = TestsAccounts.getAccount(0).balance;
        Assert.equal(balanceAfter, balanceBefore+1000, "");
        Assert.equal(getBalance(), 0, "");
    }

    /// #sender: account-1
    function checkGetBalance() public{    
        //require(msg.sender == serviceProviderAddress || msg.sender == serviceCustomerAddress, "No access.");
        try (this).getBalance(){

        }catch Error(string memory message){
            Assert.equal(message, "No access.", "");
        }

        Assert.equal(msg.sender, serviceCustomerAddress, "");
        Assert.equal(getBalance(), address(this).balance, "");
    }

    /// #sender: account-0
    function checkGetMetadata() public{
        // msg.sender is service provider
        Assert.equal(msg.sender, serviceProviderAddress, "");
        Assert.equal(getMetaData(), "metadataSP", "");

        // msg.sender is service customer
        // msg.sender is address(this)
        serviceCustomerAddress = address(this);
        Assert.equal(serviceCustomerAddress, address(this), "");
        Assert.equal((this).getMetaData(), "metadataSC", "");

        serviceCustomerAddress = acc1;

        try (this).getMetaData(){

        }catch Error(string memory message){
            Assert.equal(message, "Access denied.", "");
        }
    }
}
    