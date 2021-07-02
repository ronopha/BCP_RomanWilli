var HDWalletProvider = require('truffle-hdwallet-provider');
var Web3 = require('web3');


//Main
var { abi, evm } = require('./compile.js').Main;
bytecode = evm.bytecode.object;

var rinkeby_connect = 'https://rinkeby.infura.io/v3/f5759990ab43442c919c2e9594a022cd'
var ropsten_connect = 'https://ropsten.infura.io/v3/f5759990ab43442c919c2e9594a022cd'
var provider = new HDWalletProvider(
 'index bracket clog acoustic lamp egg orient price pill federal else glory',
 rinkeby_connect
);
var web3 = new Web3(provider);
var PIN =	"0x1FC61f56660ba988FE63027c2F2b739F680A247D"
//PUK unten
var PUK2a =	"0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21"
var PUK2b =	"0x03c10878054b5fc0DCd59c08E23940250220B20E"
var PUK2c =	"0x927F09B02C027B61D1477132440FEF3515EBe022"

var deployMain = async () => {
  var accounts = await web3.eth.getAccounts();
  var PUK =	 accounts[0];
  var sumText = [PIN, PUK, PUK2a, PUK2b, PUK2c]
  console.log('Attempting to deploy Main from account:  ', accounts[0]);
  result =await new web3.eth.Contract(abi)
  .deploy({  data: bytecode, arguments: sumText })
  .send({  from: accounts[0] });
  mainAddress = result.options.address
  
 

  //console.log('Contract MainRegistration bytecode:  \n', JSON.stringify(bytecode)); 
  //console.log('Contract MainRegistration abi:   \n', JSON.stringify(abi)); 
  console.log('Contract Main deployed to:   \n', mainAddress); 

  return mainAddress;
};





deployMain();



exports.mainAddresse = deployMain;






