{{
  "language": "Solidity",
  "sources": {
    "VoterCVXProxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\ncontract VoterCVXProxy {\n    address public owner;\n    address public voteProcessor;\n\n    mapping(bytes32 => bool) private votes;\n\n    bytes4 internal constant MAGIC_VALUE = 0x1626ba7e;\n\n    event VoteSet(bytes32 hash, bool valid);\n\n    constructor(address _voteProcessor) {\n        owner = msg.sender;\n        voteProcessor = _voteProcessor;\n    }\n\n    function setOwner(address _owner) external {\n        require(msg.sender == owner, \"!owner\");\n        owner = _owner;\n    }\n\n    function setVoteProcessor(address _voteProcessor) external {\n        require(msg.sender == owner, \"!owner\");\n        voteProcessor = _voteProcessor;\n    }\n\n    function vote(bytes32 _hash, bool _valid) external {\n        require(msg.sender == voteProcessor, \"!voteProcessor\");\n        votes[_hash] = _valid;\n        emit VoteSet(_hash, _valid);\n    }\n\n    function isValidSignature(bytes32 _hash, bytes memory)\n        public\n        view\n        returns (bytes4)\n    {\n        if (votes[_hash]) {\n            return MAGIC_VALUE;\n        } else {\n            return bytes4(0);\n        }\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
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
  }
}}