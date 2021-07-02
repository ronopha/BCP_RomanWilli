const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
var { abi, evm } = require('./compile.js').RegistrationMain;
//var { abi, evm } = require('./compile.js').RegistrationRopsten;
//const x = require('./compile');
//console.log(x);



bytecode = evm.bytecode.object;


console.log(abi);




const rinkeby_connect = 'https://rinkeby.infura.io/v3/f5759990ab43442c919c2e9594a022cd'
const ropsten_connect = 'https://ropsten.infura.io/v3/f5759990ab43442c919c2e9594a022cd'
const provider = new HDWalletProvider(
 'index bracket clog acoustic lamp egg orient price pill federal else glory',
 rinkeby_connect
);

const web3 = new Web3(provider);


const PIN =	"0x1FC61f56660ba988FE63027c2F2b739F680A247D"
//PUK unten
const PUK2a =	"0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21"
const PUK2b =	"0x03c10878054b5fc0DCd59c08E23940250220B20E"
const PUK2c =	"0x927F09B02C027B61D1477132440FEF3515EBe022"



const deploy = async () => {
  const accounts = await web3.eth.getAccounts();
  const PUK =	 accounts[0];
  const sumText = [PIN, PUK, PUK2a, PUK2b, PUK2c]
  console.log('Attempting to deploy from account', accounts[0]);
  


  const result =await new web3.eth.Contract(abi)
  
  
  .deploy({ data: bytecode, arguments: sumText })
  .send({ gas: '3500000', from: accounts[0] });

  console.log('Contract deployed to', result.options.address);


 
  
};


deploy();


