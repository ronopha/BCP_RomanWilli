var HDWalletProvider = require('truffle-hdwallet-provider');
var Web3 = require('web3');
fs = require('fs');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

//Infura Links
var rinkeby_connect = 'https://rinkeby.infura.io/v3/f5759990ab43442c919c2e9594a022cd'


//Providers
var providerMain = new HDWalletProvider(
  'bubble shy ivory siren stamp latin number anger naive eager balance struggle',
  rinkeby_connect
 );
 
 //web3 Instances
 var web3Main = new Web3(providerMain);


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
  console.log('Attempting to deploy Main (Rinkeby) Smart Contract and Main (Rinkeby) Test module from account:  ', accountsMain[0]);
  result =await new web3Main.eth.Contract(abiMain)
  .deploy({  data: bytecodeMain, arguments: sumText })
  .send({  from: accountsMain[0] });
  mainAddress = result.options.address
  
  console.log('Main (Rinkeby) Smart Contract deployed to:   \n', mainAddress); 
  deployedfrom =  accountsMain[0]

  return {deployedfrom ,mainAddress, abiMain, bytecodeMain};
};

var deployTest = async (address) => {
    //TestModule Main
address = [address];
var { abi, evm } = require('./compile.js').TestModule;
bytecode = evm.bytecode.object;

abiMainTest = abi;
bytecodeMainTest = bytecode;

  var accountsMainTest = await web3Main.eth.getAccounts();
 
  var result =await new web3Main.eth.Contract(abiMainTest)
  .deploy({ data: bytecodeMainTest, arguments: address })
  .send({ gas: '3500000', from: accountsMainTest[0] });
  var mainTestAddress = result.options.address

  console.log('Main (Rinkeby) Test module deployed to:    \n', mainTestAddress); 
 
  deployedfrom =  accountsMainTest[0]

  return {deployedfrom ,mainTestAddress, abiMainTest, bytecodeMainTest};
  
};


var mainWriter = async (resultMain, resultTestModul ) => {
//Write in CSV-File
const csvWriter = createCsvWriter({
  path: 'Main.csv',
  header: [
      {id: 'name', title: 'NAME'},
      {id: 'deployedfrom', title: 'DEPLOYEDFROM'},
      {id: 'deployedto', title: 'DEPLOYEDTO'},
      {id: 'abi', title: 'ABI'},
      {id: 'bytecode', title: 'BYTECODE'}
  ]
});

const records = [
  {name: 'Main (Rinkeby) Smart Contract',  deployedfrom: resultMain.deployedfrom, deployedto: resultMain.mainAddress,  abi: JSON.stringify(resultMain.abiMain), bytecode: JSON.stringify(resultMain.bytecodeMain)},
  {name: 'Main (Rinkeby) Test Module',  deployedfrom: resultTestModul.deployedfrom, deployedto: resultTestModul.mainTestAddress,  abi: JSON.stringify(resultTestModul.abiMainTest), bytecode: JSON.stringify(resultTestModul.bytecodeMainTest)}
];




  fs.writeFile('abiMain.json', JSON.stringify(resultMain.abiMain), function (err) {
    if (err) return console.log(err);
    console.log('abiMain > abiMain.json');
  });
  
  fs.writeFile('abiMainTest.json', JSON.stringify(resultTestModul.abiMainTest), function (err) {
    if (err) return console.log(err);
    console.log('abiMainTest > abiMainTest.json');
  });
  
  fs.writeFile('bytecodeMain.json', JSON.stringify(resultMain.bytecodeMain), function (err) {
    if (err) return console.log(err);
    console.log('bytecodeMain > bytecodeMain.json');
  });
  
  fs.writeFile('bytecodeMainTest.json', JSON.stringify(resultTestModul.bytecodeMainTest), function (err) {
    if (err) return console.log(err);
    console.log('bytecodeMainTest > bytecodeMainTest.json');
  });
  
  console.log('Main.csv created');


  csvWriter.writeRecords(records)       // returns a promise
  .then(() => {
      console.log('...Done');
  }); 


};





async function asyncCall() {
  
  const resultMain = await deployMain();
  const resultTestModulMain = await deployTest(resultMain.mainAddress);
  await mainWriter(resultMain,resultTestModulMain);
}

asyncCall();













