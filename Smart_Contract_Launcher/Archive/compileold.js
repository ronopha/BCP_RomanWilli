


// This is the previous form of compile.js 
const path = require('path'); //cross platform compatibility
const fs = require('fs');
const solc = require('solc');


//Mainnet
//Mainnet Registration
const MainnetRegistration = path.resolve(__dirname, 'contracts', 'BCP Mainnet Registration Module.sol'); //current working directory
const sourceMainRegistration = fs.readFileSync(MainnetRegistration, 'utf8'); //read raw source file 

const input = {
  language: "Solidity",
  sources: {
    "BCP Mainnet Registration Module.sol": {
      content: sourceMainRegistration,
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));



//Mainnet Commitment and Order
const MainnetCommitment = path.resolve(__dirname, 'contracts', 'BCP Commitment and Order module.sol'); //current working directory
const sourceMainCommitment = fs.readFileSync(MainnetCommitment, 'utf8'); //read raw source file 

const inputCommitment = {
  language: "Solidity",
  sources: {
    "BCP Commitment and Order module.sol": {
      content: sourceMainCommitment,
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const outputCommitment = JSON.parse(solc.compile(JSON.stringify(inputCommitment)));





//Ropsten
//Ropsten Registration
const RopstenRegistration = path.resolve(__dirname, 'contracts', 'BCP Registration module Ropsten.sol'); //current working directory
const sourceRopstenRegistration = fs.readFileSync(RopstenRegistration, 'utf8'); //read raw source file 

const inputRopstenRegistration = {
  language: "Solidity",
  sources: {
    "BCP Registration module Ropsten.sol": {
      content: sourceRopstenRegistration,
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const outputRopstenRegistration = JSON.parse(solc.compile(JSON.stringify(inputRopstenRegistration)));



//Ropsten Commitment and Order
const RopstenCommitment = path.resolve(__dirname, 'contracts', 'BCP Commitment and Order module Ropsten.sol'); //current working directory
const sourceRopstenCommitment = fs.readFileSync(RopstenCommitment, 'utf8'); //read raw source file 

const inputRopstenCommitment = {
  language: "Solidity",
  sources: {
    "BCP Commitment and Order module Ropsten.sol": {
      content: sourceRopstenCommitment,
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const outputRopstenCommitment = JSON.parse(solc.compile(JSON.stringify(inputRopstenCommitment)));





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
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const outputTest = JSON.parse(solc.compile(JSON.stringify(inputTest)));












exports.RegistrationMain = output.contracts["BCP Mainnet Registration Module.sol"].BCPRegistration;
exports.CommitmentMain = outputCommitment.contracts["BCP Commitment and Order module.sol"].BCPCommitmentandOrder;


exports.RegistrationRopsten = outputRopstenRegistration.contracts["BCP Registration module Ropsten.sol"].BCPRegistrationRopsten;
exports.CommitmentRopsten = outputRopstenCommitment.contracts["BCP Commitment and Order module Ropsten.sol"].BCPCommitmentandOrderRopsten;

exports.TestModule = outputTest.contracts["TestModule_1.1.13.sol"].BCP_TestModule;
