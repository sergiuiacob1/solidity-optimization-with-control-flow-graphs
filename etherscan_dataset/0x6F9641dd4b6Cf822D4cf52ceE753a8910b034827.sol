{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
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
    "contracts/test/TestCounter.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.12;\n\n//sample \"receiver\" contract, for testing \"exec\" from wallet.\ncontract TestCounter {\n    mapping(address => uint256) public counters;\n\n    function count() public {\n        counters[msg.sender] = counters[msg.sender] + 1;\n\n    }\n\n    function justemit() public {\n        emit CalledFrom(msg.sender);\n    }\n\n    event CalledFrom(address sender);\n\n    //helper method to waste gas\n    // repeat - waste gas on writing storage in a loop\n    // junk - dynamic buffer to stress the function size.\n    mapping(uint256 => uint256) xxx;\n    uint256 offset;\n\n    function gasWaster(uint256 repeat, string calldata /*junk*/) external {\n        for (uint256 i = 1; i <= repeat; i++) {\n            offset++;\n            xxx[offset] = i;\n        }\n    }\n}"
    }
  }
}}