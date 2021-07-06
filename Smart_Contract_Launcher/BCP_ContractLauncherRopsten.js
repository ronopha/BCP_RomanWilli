var HDWalletProvider = require('truffle-hdwallet-provider');
var Web3 = require('web3');
fs = require('fs');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;


//Infura Links
var ropsten_connect = 'https://ropsten.infura.io/v3/f5759990ab43442c919c2e9594a022cd'


//Providers

 var providerRopsten = new HDWalletProvider(
  'bubble shy ivory siren stamp latin number anger naive eager balance struggle',
  ropsten_connect
 );

 //web3 Instances
var web3Ropsten = new Web3(providerRopsten);



var PIN =	"0x1FC61f56660ba988FE63027c2F2b739F680A247D"
//PUK unten
var PUK2a =	"0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21"
var PUK2b =	"0x03c10878054b5fc0DCd59c08E23940250220B20E"
var PUK2c =	"0x927F09B02C027B61D1477132440FEF3515EBe022"




var deployRopsten = async () => {
    //Ropsten
var { abi, evm } = require('./compile.js').Ropsten;
bytecode = evm.bytecode.object;
abiRopsten = abi
bytecodeRopsten = bytecode
  var accountsRopsten = await web3Ropsten.eth.getAccounts();
  var PUK =	 accountsRopsten[0];
  var sumText = [PIN, PUK, PUK2a, PUK2b, PUK2c]
  console.log('Attempting to deploy Ropsten Smart Contract and Ropsten Test module from account:  ', accountsRopsten[0]);
  result =await new web3Ropsten.eth.Contract(abiRopsten)
  .deploy({  data: bytecodeRopsten, arguments: sumText })
  .send({  from: accountsRopsten[0] });
  ropstenAddress = result.options.address
  
  console.log('Ropsten Smart Contract deployed to:   \n', ropstenAddress); 
  deployedfrom =  accountsRopsten[0];


  return {deployedfrom ,ropstenAddress, abiRopsten, bytecodeRopsten};
};

var deployTest = async (address) => {
    //TestModule Main
address = [address];
var { abi, evm } = require('./compile.js').TestModule;
bytecode = evm.bytecode.object;

abiRopstenTest = abi;
bytecodeRopstenTest = bytecode;

  
  var accountsRopstenTest = await web3Ropsten.eth.getAccounts();
 
  var resultRopstenTest =await new web3Ropsten.eth.Contract(abiRopstenTest)
  .deploy({ data: bytecodeRopstenTest, arguments: address })
  .send({ from: accountsRopstenTest[0] });
  var RopstenTestAddress = resultRopstenTest.options.address

  console.log('Ropsten Test module deployed to:    \n', RopstenTestAddress); 
  deployedfrom =  accountsRopstenTest[0];

  return {deployedfrom ,RopstenTestAddress, abiRopstenTest, bytecodeRopstenTest};
  
};


var ropstenWriter = async (resultRopsten, resultTestModulRopsten) => {
  //Write in CSV-File
  const csvWriter = createCsvWriter({
    path: 'Export/Ropsten.csv',
    header: [
        {id: 'name', title: 'NAME'},
        {id: 'deployedfrom', title: 'DEPLOYEDFROM'},
        {id: 'deployedto', title: 'DEPLOYEDTO'},
        {id: 'abi', title: 'ABI'},
        {id: 'bytecode', title: 'BYTECODE'}
    ]
  });
  
  const records = [
    {name: 'Ropsten Smart Contract',  deployedfrom: resultRopsten.deployedfrom, deployedto: resultRopsten.ropstenAddress,  abi: JSON.stringify(resultRopsten.abiRopsten), bytecode: JSON.stringify(resultRopsten.bytecodeRopsten)},
    {name: 'Ropsten Test Module',  deployedfrom: resultTestModulRopsten.deployedfrom, deployedto: resultTestModulRopsten.RopstenTestAddress,  abi: JSON.stringify(resultTestModulRopsten.abiRopstenTest), bytecode: JSON.stringify(resultTestModulRopsten.bytecodeRopstenTest)}
  ];
  

    fs.writeFile('Export/abiRopsten.json', JSON.stringify(resultRopsten.abiRopsten), function (err) {
      if (err) return console.log(err);
      console.log('abiRopsten > abiRopsten.json');
    });
    
    fs.writeFile('Export/abiRopstenTest.json', JSON.stringify(resultTestModulRopsten.abiRopstenTest), function (err) {
      if (err) return console.log(err);
      console.log('abiRopstenTest > abiRopstenTest.json');
    });
    
    fs.writeFile('Export/bytecodeRopsten.json', JSON.stringify(resultRopsten.bytecodeRopsten), function (err) {
      if (err) return console.log(err);
      console.log('bytecodeRopsten > bytecodeRopsten.json');
    });
    
    fs.writeFile('Export/bytecodeRopstenTest.json', JSON.stringify(resultTestModulRopsten.bytecodeRopstenTest), function (err) {
      if (err) return console.log(err);
      console.log('bytecodeRopstenTest > bytecodeRopstenTest.json');
    });
    

    console.log('Ropsten.csv created');



    csvWriter.writeRecords(records)       // returns a promise
    .then(() => {
        console.log('...Done');
    });


  
  };



async function asyncCall() {
  
  const resultRopsten = await deployRopsten();
  const resultTestModulRopsten = await deployTest(resultRopsten.ropstenAddress);
  await ropstenWriter(resultRopsten,resultTestModulRopsten);
}

asyncCall();











