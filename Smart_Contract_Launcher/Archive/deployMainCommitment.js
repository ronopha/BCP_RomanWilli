var HDWalletProvider = require('truffle-hdwallet-provider');
var Web3 = require('web3');

//var daten = await require('./deployMainRegistration.js');
//console.log(await daten.mainCommitmentAddresse());




//Commitment Main
var { abi, evm } = require('./compile.js').CommitmentMain;


var address = ["0xcC39ABc71DeE21Dccd2d6b2f22f131CBd0d0d5f8"];



bytecode = evm.bytecode.object;

var rinkeby_connect = 'https://rinkeby.infura.io/v3/f5759990ab43442c919c2e9594a022cd'

var provider = new HDWalletProvider(
 'index bracket clog acoustic lamp egg orient price pill federal else glory',
 rinkeby_connect
);
var web3 = new Web3(provider);



var deployCommitmentMain = async () => {

  //address = beta;
  
  var accounts = await web3.eth.getAccounts();
 
  console.log('Attempting to deploy MainCommitmentOrder from account', accounts[0]);



  var result =await new web3.eth.Contract(abi)
  .deploy({ data: bytecode, arguments: address })
  //.deploy({ data: bytecode, arguments: beta })
  .send({ gas: '6000000', from: accounts[0] });
  var mainCommitmentAddress = result.options.address

  //console.log('Contract MainCommitment bytecode:  \n', JSON.stringify(bytecode)); 
  //console.log('Contract MainCommitment abi:   \n', JSON.stringify(abi)); 
  console.log('Contract MainCommitment deployed to:    \n', mainCommitmentAddress); 

  return mainCommitmentAddress;
  
  
};


  


deployCommitmentMain();



exports.mainCommitmentAddresse = deployCommitmentMain;



