var HDWalletProvider = require('truffle-hdwallet-provider');
var Web3 = require('web3');


//Commitment Ropsten
var { abi, evm } = require('./compile.js').CommitmentRopsten;
//const datendeployed = require('./deployMainRegistration.js');
//console.log(datendeployed.mainCommitmentAddresse);

var address = ["0xAd21EaE3D6Edd9F368129CE3719AB11d70E11Fdb"];



bytecode = evm.bytecode.object;

var rinkeby_connect = 'https://rinkeby.infura.io/v3/f5759990ab43442c919c2e9594a022cd';
var ropsten_connect = 'https://ropsten.infura.io/v3/f5759990ab43442c919c2e9594a022cd';

var provider = new HDWalletProvider(
 'index bracket clog acoustic lamp egg orient price pill federal else glory',
 ropsten_connect
);
var web3 = new Web3(provider);



var deployCommitmentRopsten = async () => {
  var accounts = await web3.eth.getAccounts();
 
  //address = beta
  
  console.log('Attempting to deploy RopstenCommitmentOrder from account', accounts[0]);
  var result =await new web3.eth.Contract(abi)
  .deploy({ data: bytecode, arguments: address })
  .send({ gas: '6000000', from: accounts[0] });
  var RopstenCommitmentAddress = result.options.address

  //console.log('Contract RopstenCommitmentOrder bytecode:  \n', JSON.stringify(bytecode)); 
  //console.log('Contract RopstenCommitmentOrder abi:   \n', JSON.stringify(abi)); 
  console.log('Contract RopstenCommitmentOrder deployed to:    \n', RopstenCommitmentAddress); 

  
  
  
};


  




deployCommitmentRopsten();






exports.RopstenCommitmentAddresse = deployCommitmentRopsten;