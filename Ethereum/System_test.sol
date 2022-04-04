// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "./02_System.sol";
import "./01_Transaction.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSystem is System{

    address acc0;
    address acc1;
    address acc2;

    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }

    /// #sender: account-0
    function checkVerify() public{
        Assert.equal(verifiedUsers[msg.sender], false, "");
        Assert.equal(userVerificationDate[msg.sender], 0, "");
        Assert.equal(verifiedUsersList.length, 0, "");

        // requirements are met
        Assert.equal(verifiedUsers[msg.sender], false, "");
        verify();

        // check correctness of changes
        Assert.equal(verifiedUsers[msg.sender], true, "");
        Assert.equal(userVerificationDate[msg.sender], block.timestamp, "");
        Assert.equal(verifiedUsersList.length, 1, "");

        //require(verifiedUsers[msg.sender] == false, "Already verified.");
        Assert.equal(verifiedUsers[address(this)], false, "");
        (this).verify();
        Assert.equal(verifiedUsers[address(this)], true, "");
        try (this).verify(){

        }catch Error(string memory message){
            Assert.equal(message, "Already verified.", "");
        }
    }

    /// #sender: account-0
    function checkAddUsername() public{
        //require(verifiedUsers[msg.sender] == true, "Not verified.");
        Assert.equal(verifiedUsers[address(this)], true, "");
        try (this).verify(){

        }catch Error(string memory message){
            Assert.equal(message, "Already verified.", "");
        }
        
        // all requirements are met
        Assert.equal(verifiedUsers[msg.sender], true, "");
        Assert.equal(usernamesFromString["testuser"], address(0), "");
        Assert.equal(usernamesFromAddress[msg.sender], "", "");
        
        addUsername("testuser");

        // check correctness of changes
        Assert.equal(usernamesFromString["testuser"], msg.sender, "");
        Assert.equal(usernamesFromAddress[msg.sender], "testuser", "");

        //require(usernamesFromString[_username] == address(0), "Username is taken.");
        Assert.equal(verifiedUsers[address(this)], true, "");
        Assert.notEqual(usernamesFromString["testuser"], address(0), "");
        Assert.equal(usernamesFromAddress[address(this)], "", "");
        try (this).addUsername("testuser"){

        }catch Error(string memory message){
            Assert.equal(message, "Username is taken.", "");
        }
        
        //require(keccak256(abi.encodePacked(usernamesFromAddress[msg.sender])) == keccak256(abi.encodePacked("")), "Sender username exists already.");
        (this).addUsername("testuser2");
        Assert.equal(verifiedUsers[address(this)], true, "");
        Assert.equal(usernamesFromString["testuser3"], address(0), "");
        Assert.notEqual(usernamesFromAddress[msg.sender], "", "");
        try (this).addUsername("testuser3"){

        }catch Error(string memory message){
            Assert.equal(message, "Sender username exists already.", "");
        }
    
    }

    /// #sender: account-0
    function checkAddPublicKey() public{
        verifiedUsers[address(this)] = false;
        Assert.equal(verifiedUsers[address(this)], false, "");
        try (this).addPublicKey("publicKey"){

        }catch Error(string memory message){
            Assert.equal(message, "Not verified.", "");
            verifiedUsers[address(this)] = true;
        }

        // requirements are met
        Assert.equal(verifiedUsers[msg.sender], true, "");

        addPublicKey("publickey");
        // check correctness of changes
        Assert.equal(addressPublicKey[msg.sender], "publickey", "");

    }

    /// #sender: account-0
    function checkCreateTransaction() public{
        //require(verifiedUsers[msg.sender] == true, "Not verified.");        
        verifiedUsers[address(this)] = false;
        Assert.equal(verifiedUsers[address(this)], false, "");
        try (this).createTransaction(msg.sender, 1, 10, 90, "metadataSC", "metadataSP", "serviceType", "productType"){

        }catch Error(string memory message){
            Assert.equal(message, "Not verified.", "");
            verifiedUsers[address(this)] = true;
        }

        //require(verifiedUsers[_serviceCustomerAddress] == true, "SC not verified.");
        verifiedUsers[msg.sender] = false;
        Assert.equal(verifiedUsers[address(this)], true, "");
        Assert.equal(verifiedUsers[msg.sender], false, "");
        try (this).createTransaction(msg.sender, 1, 10, 90, "metadataSC", "metadataSP", "serviceType", "productType"){

        }catch Error(string memory message){
            Assert.equal(message, "SC not verified.", "");
            verifiedUsers[msg.sender] = true;
        }

        //require(_serviceCustomerAddress != msg.sender, "SP and SC must differ.");
        Assert.equal(verifiedUsers[address(this)], true, "");
        Assert.equal(verifiedUsers[msg.sender], true, "");
        try (this).createTransaction(address(this), 1, 10, 90, "metadataSC", "metadataSP", "serviceType", "productType"){

        }catch Error(string memory message){
            Assert.equal(message, "SP and SC must differ.", "");
        }

        // requirements are met
        Assert.equal(verifiedUsers[address(this)], true, "");
        Assert.equal(verifiedUsers[msg.sender], true, "");
        Assert.notEqual(address(this), msg.sender, "");
        Assert.equal(transactionHistory.length, 0, "");

        // msg.sender calls
        createTransaction(address(this), 1, 10, 90, "metadataSC", "metadataSP", "serviceType", "productType");

        // check correctness of changes
        Assert.ok(transactionHistory.length == 1, "");
        Transaction t = transactionHistory[0];
        Assert.equal(t.serviceCustomerAddress(), address(this), "");
        Assert.equal(t.serviceProviderAddress(), msg.sender, "");
        Assert.ok(t.amountNonPerformanceBasedPayment() == 90, "");
        Assert.ok(t.amountPerformanceBasedPayment() == 10, "");
        Assert.equal(t.metadataSC(), "metadataSC", "");
        Assert.equal(t.metadataSP(), "metadataSP", "");
        Assert.equal(t.serviceType(), "serviceType", "");
        Assert.equal(t.productType(), "productType", "");

        // special requirement
        // Transaction objects created outside System-Class should not be pushed into transactionHistory array
        Assert.ok(transactionHistory.length == 1, "");
        Transaction t2 = new Transaction(acc0, acc1, 1, 100, 900, "metadataSC", "metadataSP", "serviceType", "productType");
        Assert.ok(transactionHistory.length == 1, "");
    }
}
    