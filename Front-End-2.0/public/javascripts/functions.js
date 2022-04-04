/**
 * @author Davut Keles <m.davut.keles@gmail.com>
 */
load();

async function load(){
    if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        window.ethereum.enable();
        window.contract = await new window.web3.eth.Contract(reputationSystemABI, reputationSystemAddress);
    }
}


async function loadTransaction(transactionAddress){
    return await new window.web3.eth.Contract(transactionABI, transactionAddress);
}

async function getTransactionData(transactionAddress){
    var t = await loadTransaction(transactionAddress);
    let serviceProviderAddress = await t.methods.serviceProviderAddress().call();
    let serviceCustomerAddress = await t.methods.serviceCustomerAddress().call();
    let dateCreation = getTime(await t.methods.dateCreation().call());
    let datePaymentPerformanceBased = getTime(await t.methods.datePaymentPerformanceBased().call());
    let datePaymentNonPerformanceBased = getTime(await t.methods.datePaymentNonPerformanceBased().call());
    let dateFulfillment = getTime(await t.methods.dateFulfillment().call());
    let dateCounterRating = getTime(await t.methods.dateCounterRating().call());
    let deadlineFulfillment = getTime(await t.methods.deadlineFulfillment().call());
    let deadlinePayment = getTime(await t.methods.deadlinePayment().call());
    let deadlineRating = getTime(await t.methods.deadlineRating().call());
    let lastUpdate = getTime(await t.methods.lastUpdate().call());
    let status = await t.methods.status().call();
    let metadataSP = await t.methods.metadataSP().call();
    let metadataSC = await t.methods.metadataSC().call();
    let productType = await t.methods.productType().call();
    let serviceType = await t.methods.serviceType().call();
    let amountPerformanceBasedPayment = await t.methods.amountPerformanceBasedPayment().call();
    let amountNonPerformanceBasedPayment = await t.methods.amountNonPerformanceBasedPayment().call();
    let counterRating = await t.methods.counterRating().call();



    return [serviceProviderAddress, serviceCustomerAddress, dateCreation, 
    datePaymentPerformanceBased, datePaymentNonPerformanceBased, dateFulfillment,
    dateCounterRating, deadlineFulfillment, deadlinePayment, deadlineRating, lastUpdate,
    status, metadataSP, metadataSC, productType, serviceType, amountPerformanceBasedPayment, 
    amountNonPerformanceBasedPayment, counterRating];
}

async function getTransactionDataShort(transactionAddress){
    var t = await loadTransaction(transactionAddress);
    let serviceProviderAddress = await t.methods.serviceProviderAddress().call();
    let serviceCustomerAddress = await t.methods.serviceCustomerAddress().call();
    let status = await t.methods.status().call();
    let productType = await t.methods.productType().call();
    let serviceType = await t.methods.serviceType().call();
    let amountPerformanceBasedPayment = await t.methods.amountPerformanceBasedPayment().call();
    let amountNonPerformanceBasedPayment = await t.methods.amountNonPerformanceBasedPayment().call();
    let lastUpdate = getTime(await t.methods.lastUpdate().call());

    return [serviceProviderAddress, serviceCustomerAddress,
            status, productType, serviceType, amountPerformanceBasedPayment, 
            amountNonPerformanceBasedPayment, lastUpdate];
}

async function getAllTransactions(){
    var transactions = [];
    var i = 0;
    while (true){
        try{
            transactions.push(await window.contract.methods.getTransactionStruct(i).call());
            i++;
        }catch(e){
            break;
        }
    }

    return transactions;
}

function getTime(unixtimestamp){
    if (unixtimestamp == 0){
        // date was not initialized;
        return "Not defined yet.";
    }else{
        var date = new Date(unixtimestamp*1000);
        var day = date.getUTCDate();
        var month = date.getUTCMonth()+1;
        var year = date.getUTCFullYear();
        var hour = date.getHours();
        var minute = date.getMinutes();
        var second = date.getSeconds();
        return day + "." + month + "." + year + " " + hour + ":" + minute + ":" + second;
    }
}

function timestampFromNow(){
    return Math.floor(Date.now() / 1000);
}

function tippingDeadlineDue(unixtimestamp){
    if (unixtimestamp == 0){
        // date was not initialized;
        return false;
    }else{
        var now = Math.floor(Date.now() / 1000);
        if (unixtimestamp < now ){
            return true;
        }else{
            return false;
        }
    }
}

async function getUsername(address){
    try{
        var username = await window.contract.methods.usernamesFromAddress(address).call();
        updateStatus("username loaded");
        return username;
    }catch(e){
        updateStatus(e);
    }
}

async function getVerificationDate(address){
    try{
        var verificationDate = await window.contract.methods.userVerificationDate(address).call();
        return getTime(verificationDate);
        updateStatus("verificationDate loaded");
    }catch(e){
        updateStatus(e);
    }
}

function updateStatus(status) {
    console.log(status);
}
function getAddress(){
    try{
        if (ethereum.selectedAddress != null){ 
            return ethereum.selectedAddress;
        }else{
            return "Please connect a wallet.";
        }
    }catch(e){
        return "You are not connect to Ethereum.";
    }
}

async function getVerified(address){
    try{
        var verified = await window.contract.methods.verifiedUsers(address).call();
        if (verified){
            return " (Verified)";
        }else{
            return " (Not Verified)";
        }
    }catch(e){
        updateStatus(e);
    }
}

async function verify(){
    try{
        await window.contract.methods.verify().send({from: ethereum.selectedAddress});
        location.reload();
    }catch(e){
        updateStatus(e);
    }
}

async function getPublicKey(){        
    const account = ethereum.selectedAddress;
    await ethereum
    .request({
        method: 'eth_getEncryptionPublicKey',
        params: [account],
    })
    .then((result) => {
        uploadPublicKey(result);
    })
    .catch((error) => {
        updateStatus(error);
    });
    updateStatus("Public key was uploaded.");      
}
async function getPublicKeyFromSmartContract(){
    return await window.contract.methods.addressPublicKey(ethereum.selectedAddress).call();
}

async function uploadPublicKey(publicKey){
    await window.contract.methods.addPublicKey(publicKey).send({from: ethereum.selectedAddress});     
    location.reload();
}

async function metamaskStatus(){
    try{
        ethereum.selectedAddress;
    }catch(e){
        UIkit.modal.dialog("<p style='padding:2em;'>Metamask-Status: Please install <a href='https://metamask.io/'>Metamask</a>.</p>");
    }
}
