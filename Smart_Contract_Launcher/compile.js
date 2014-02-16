


// This is the previous form of compile.js 
const path = require('path'); //cross platform compatibility
const fs = require('fs');
const solc = require('solc');
//const solcjs = require('solc-js');


//Main
const Main = path.resolve(__dirname, 'contracts', 'Main.sol'); //current working directory
const sourceMain = fs.readFileSync(Main, 'utf8'); //read raw source file 

const input = {
  language: "Solidity",
  sources: {
    "Main.sol": {
      content: sourceMain,
    },
  },
  settings: {
      
        // Optional: Optimizer settings
    "optimizer": {
      // disabled by default
      "enabled": true,
      "runs": 200,
    },
      
      //test
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));






//Ropsten
const Ropsten = path.resolve(__dirname, 'contracts', 'Ropsten.sol'); //current working directory
const sourceRopsten = fs.readFileSync(Ropsten, 'utf8'); //read raw source file 

const inputRopsten = {
  language: "Solidity",
  sources: {
    "Ropsten.sol": {
      content: sourceRopsten,
    },
    
  },
  settings: {
      
      
      // Optional: Optimizer settings
    "optimizer": {
      // disabled by default
      "enabled": true,
      "runs": 200,
    },
      
      
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const outputRopsten = JSON.parse(solc.compile(JSON.stringify(inputRopsten)));






//Test Module
const Test = path.resolve(__dirname, 'contracts', 'TestModule_1.1.13.sol'); //current working directory
const sourceTest = fs.readFileSync(Test, 'utf8'); //read raw source file 

const inputTest = {
  language: "Solidity",
  sources: {
    "TestModule_1.1.13.sol": {
      content: sourceTest,
    },
  },
  settings: {
      
        // Optional: Optimizer settings
    "optimizer": {
      // disabled by default
      "enabled": true,
      "runs": 200,
    },
      
      
      
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const outputTest = JSON.parse(solc.compile(JSON.stringify(inputTest)));












exports.Main = output.contracts["Main.sol"].BlockchainPresence;

exports.Ropsten = outputRopsten.contracts["Ropsten.sol"].BlockchainPresenceRopsten;

exports.TestModule = outputTest.contracts["TestModule_1.1.13.sol"].BCP_TestModule;
