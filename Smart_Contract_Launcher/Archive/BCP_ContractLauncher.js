var HDWalletProvider = require('truffle-hdwallet-provider');
var Web3 = require('web3');

//Infura Links
var rinkeby_connect = 'https://rinkeby.infura.io/v3/f5759990ab43442c919c2e9594a022cd'
var ropsten_connect = 'https://ropsten.infura.io/v3/f5759990ab43442c919c2e9594a022cd'
var kovan_connect = 'https://kovan.infura.io/v3/f5759990ab43442c919c2e9594a022cd'

//Providers
var providerMain = new HDWalletProvider(
  'tongue august shock scrub drive distance rescue ivory museum opera left warfare',
  rinkeby_connect
 );
 
 var providerRopsten = new HDWalletProvider(
  'tongue august shock scrub drive distance rescue ivory museum opera left warfare',
  rinkeby_connect
 );

 //web3 Instances
 var web3Main = new Web3(providerMain);

var web3Ropsten = new Web3(providerRopsten);



var PIN =	"0x1FC61f56660ba988FE63027c2F2b739F680A247D"
//PUK unten
var PUK2a =	"0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21"
var PUK2b =	"0x03c10878054b5fc0DCd59c08E23940250220B20E"
var PUK2c =	"0x927F09B02C027B61D1477132440FEF3515EBe022"

var deployMain = async () => {
    
    //Main
    var { abi, evm } = require('./compile.js').Main;
    bytecode = evm.bytecode.object;
    abiMain = abi;
    bytecodeMain = bytecode;

  var accountsMain = await web3Main.eth.getAccounts();
  var PUK =	 accountsMain[0];
  
  var sumText = [PIN, PUK, PUK2a, PUK2b, PUK2c]
  console.log('Attempting to deploy Main from account:  ', accountsMain[0]);
  result =await new web3Main.eth.Contract(abiMain)
  .deploy({  data: bytecodeMain, arguments: sumText })
  .send({  from: accountsMain[0] });
  mainAddress = result.options.address
  
 

  //console.log('Contract MainRegistration bytecode:  \n', JSON.stringify(bytecode)); 
  //console.log('Contract MainRegistration abi:   \n', JSON.stringify(abi)); 
  console.log('Contract Main deployed to:   \n', mainAddress); 

  return mainAddress;
};


var deployRopsten = async () => {
    //Ropsten
var { abi, evm } = require('./compile.js').Ropsten;
bytecode = evm.bytecode.object;
abiRopsten = abi
bytecodeRopsten = bytecode
  var accountsRopsten = await web3Ropsten.eth.getAccounts();
  var PUK =	 accountsRopsten[0];
  var sumText = [PIN, PUK, PUK2a, PUK2b, PUK2c]
  console.log('Attempting to deploy Ropsten from account:  ', accountsRopsten[0]);
  result =await new web3Ropsten.eth.Contract(abiRopsten)
  .deploy({  data: bytecodeRopsten, arguments: sumText })
  .send({  from: accountsRopsten[0] });
  ropstenAddress = result.options.address
  
 

  //console.log('Contract MainRegistration bytecode:  \n', JSON.stringify(bytecode)); 
  //console.log('Contract MainRegistration abi:   \n', JSON.stringify(abi)); 
  console.log('Contract Ropsten deployed to:   \n', ropstenAddress); 

  return ropstenAddress;
};

var deployTest = async (address) => {
    //TestModule Main
address = [address];
var { abi, evm } = require('./compile.js').TestModule;
bytecode = evm.bytecode.object;

abiMainTest = abi;
bytecodeMainTest = bytecode;

abiRopstenTest = abi;
bytecodeRopstenTest = bytecode;

  var accountsMainTest = await web3Main.eth.getAccounts();
 
  console.log('Attempting to deploy MainTestModule from account', accountsMainTest[0]);
  var result =await new web3Main.eth.Contract(abiMainTest)
  .deploy({ data: bytecodeMainTest, arguments: address })
  .send({ gas: '3500000', from: accountsMainTest[0] });
  var mainTestAddress = result.options.address

  //console.log('Contract MainTestModule bytecode:  \n', JSON.stringify(bytecode)); 
  //sconsole.log('Contract MainTestModule abi:   \n', JSON.stringify(abi)); 
  console.log('Contract MainTestModule deployed to:    \n', mainTestAddress); 

   var accountsRopstenTest = await web3Ropsten.eth.getAccounts();
 
  console.log('Attempting to deploy RopstenTestModule from account', accountsRopstenTest[0]);
  var resultRopstenTest =await new web3Ropsten.eth.Contract(abiRopstenTest)
  .deploy({ data: bytecodeRopstenTest, arguments: address })
  .send({ from: accountsRopstenTest[0] });
  var RopstenTestAddress = resultRopstenTest.options.address

  //console.log('Contract RopstenTestModule bytecode:  \n', JSON.stringify(bytecode)); 
  //console.log('Contract RopstenTestModule abi:   \n', JSON.stringify(abi)); 
  console.log('Contract RopstenTestModule deployed to:    \n', RopstenTestAddress); 
  
  
};



async function asyncCall() {
  
  const resultMain = await deployMain();
  const resultRopsten = await deployRopsten();
  const resultTestModul = await deployTest(resultMain);
}

asyncCall();











