{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 10000
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "contracts/libraries/JBCurrencies.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.6;\n\nlibrary JBCurrencies {\n  uint256 public constant ETH = 1;\n  uint256 public constant USD = 2;\n}\n"
    }
  }
}}