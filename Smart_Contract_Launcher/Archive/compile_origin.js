


// This is the previous form of compile.js 
const path = require('path'); //cross platform compatibility
const fs = require('fs');
const solc = require('solc');

const MainnetRegistration = path.resolve(__dirname, 'contracts', 'BCP Mainnet Registration Module.sol'); //current working directory
const source = fs.readFileSync(MainnetRegistration, 'utf8'); //read raw source file 

const RopstenRegistration = path.resolve(__dirname, 'contracts', 'BCP Registration module Ropsten.sol'); //current working directory
const sourceRopsten = fs.readFileSync(RopstenRegistration, 'utf8'); //read raw source file 



// The last line of codes need to be changed like below.
const input = {
  language: "Solidity",
  sources: {
    "BCP Mainnet Registration Module.sol": {
      content: source,
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

const inputCommitment = {
  language: "Solidity",
  sources: {
    "BCP Commitment and Order module.sol": {
      content: source,
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


const inputRopsten = {
  language: "Solidity",
  sources: {
    "BCP Registration module Ropsten.sol'": {
      content: sourceRopsten,
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

const inputRopstenCommitment = {
  language: "Solidity",
  sources: {
    "BCP Commitment and Order module Ropsten.sol": {
      content: source,
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
const outputCommitment = JSON.parse(solc.compile(JSON.stringify(inputCommitment)));

const outputRopsten = JSON.parse(solc.compile(JSON.stringify(inputRopsten)));
const outputRopstenCommitment = JSON.parse(solc.compile(JSON.stringify(inputRopstenCommitment)));


  exports.RegistrationMain = output.contracts["BCP Mainnet Registration Module.sol"].BCPRegistration;
  //exports.RegistrationRopsten = outputRopsten.contracts["BCP Registration module Ropsten.sol"].BCPRegistrationRopsten;
  


