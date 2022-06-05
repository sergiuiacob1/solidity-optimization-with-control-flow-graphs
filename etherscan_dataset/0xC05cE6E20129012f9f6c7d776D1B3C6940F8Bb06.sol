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
    "contracts/CentralLogger.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity =0.8.10;\n\n/// @title Central logger contract\n/// @notice Log collector with only 1 purpose - to emit the event. Can be called from any contract\n/** @dev Use like this:\n*\n* bytes32 internal constant CENTRAL_LOGGER_ID = keccak256(\"CentralLogger\");\n* CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));\n*\n* Or directly:\n*   CentralLogger logger = CentralLogger(0xDEPLOYEDADDRESS);\n*\n* logger.log(\n*            address(this),\n*            msg.sender,\n*            \"myGreatFunction\",\n*            abi.encode(msg.value, param1, param2)\n*        );\n*\n* DO NOT USE delegateCall as it defies the centralisation purpose of this logger.\n*/\ncontract CentralLogger {\n\n    event LogEvent(\n        address indexed contractAddress,\n        address indexed caller,\n        string indexed logName,\n        bytes data\n    );\n\n\t/* solhint-disable no-empty-blocks */\n\tconstructor() {\n\t}\n\n    /// @notice Log the event centrally\n    /// @dev For gas impact see https://www.evm.codes/#a3\n    /// @param _logName length must be less than 32 bytes\n    function log(\n        address _contract,\n        address _caller,\n        string memory _logName,\n        bytes memory _data\n    ) public {\n        emit LogEvent(_contract, _caller, _logName, _data);\n    }\n}\n"
    }
  }
}}