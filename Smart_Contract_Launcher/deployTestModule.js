var HDWalletProvider = require('truffle-hdwallet-provider');
var Web3 = require('web3');


//TestModule Main
var { abi, evm } = require('./compile.js').TestModule;


//var daten = require('./deployMainRegistration.js');
//console.log(daten.datendeployed);

var address = ["0xcC39ABc71DeE21Dccd2d6b2f22f131CBd0d0d5f8"];



bytecode = evm.bytecode.object;

abiRopsten = abi;
bytecodeRopsten = bytecode;

const rinkeby_connect = 'https://rinkeby.infura.io/v3/f5759990ab43442c919c2e9594a022cd';
const ropsten_connect = 'https://ropsten.infura.io/v3/f5759990ab43442c919c2e9594a022cd';

var providerMain = new HDWalletProvider(
 'index bracket clog acoustic lamp egg orient price pill federal else glory',
 rinkeby_connect
);

var providerRopsten = new HDWalletProvider(
 'index bracket clog acoustic lamp egg orient price pill federal else glory',
 rinkeby_connect
);

var web3Main = new Web3(providerMain);

var web3Ropsten = new Web3(providerRopsten);



var deployTest = async () => {
  var accounts = await web3Main.eth.getAccounts();
 
  console.log('Attempting to deploy MainTestModule from account', accounts[0]);
  var result =await new web3Main.eth.Contract(abi)
  .deploy({ data: bytecode, arguments: address })
  .send({ gas: '3500000', from: accounts[0] });
  var mainTestAddress = result.options.address

  //console.log('Contract MainTestModule bytecode:  \n', JSON.stringify(bytecode)); 
  //sconsole.log('Contract MainTestModule abi:   \n', JSON.stringify(abi)); 
  console.log('Contract MainTestModule deployed to:    \n', mainTestAddress); 

   var accountsRopsten = await web3Ropsten.eth.getAccounts();
 
  console.log('Attempting to deploy RopstenTestModule from account', accountsRopsten[0]);
  var resultRopsten =await new web3Ropsten.eth.Contract(abiRopsten)
  .deploy({ data: bytecodeRopsten, arguments: address })
  .send({ from: accountsRopsten[0] });
  var RopstenTestAddress = resultRopsten.options.address

  //console.log('Contract RopstenTestModule bytecode:  \n', JSON.stringify(bytecode)); 
  //console.log('Contract RopstenTestModule abi:   \n', JSON.stringify(abi)); 
  console.log('Contract RopstenTestModule deployed to:    \n', RopstenTestAddress); 
  
  
};

  




deployTest();





