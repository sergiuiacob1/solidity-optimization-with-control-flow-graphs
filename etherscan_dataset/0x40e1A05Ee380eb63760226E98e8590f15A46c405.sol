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
    "contracts/CauldronUtils.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n// solhint-disable func-name-mixedcase\npragma solidity ^0.8.10;\n\ncontract CauldronUtils {\n    uint8 internal constant ACTION_REPAY = 2;\n    uint8 internal constant ACTION_REMOVE_COLLATERAL = 4;\n    uint8 internal constant ACTION_BORROW = 5;\n    uint8 internal constant ACTION_GET_REPAY_SHARE = 6;\n    uint8 internal constant ACTION_GET_REPAY_PART = 7;\n    uint8 internal constant ACTION_ACCRUE = 8;\n    uint8 internal constant ACTION_ADD_COLLATERAL = 10;\n    uint8 internal constant ACTION_UPDATE_EXCHANGE_RATE = 11;\n    uint8 internal constant ACTION_BENTO_DEPOSIT = 20;\n    uint8 internal constant ACTION_BENTO_WITHDRAW = 21;\n    uint8 internal constant ACTION_BENTO_TRANSFER = 22;\n    uint8 internal constant ACTION_BENTO_TRANSFER_MULTIPLE = 23;\n    uint8 internal constant ACTION_BENTO_SETAPPROVAL = 24;\n    uint8 internal constant ACTION_CALL = 30;\n\n    struct ActionAddRepayRemoveBorrow {\n        bool assigned;\n        int256 share;\n        address to;\n        bool skim;\n    }\n\n    struct ActionUpdateExchangeRate {\n        bool assigned;\n        bool mustUpdate;\n        uint256 minRate;\n        uint256 maxRate;\n    }\n\n    struct CookAction {\n        string name;\n        uint8 action;\n        uint256 value;\n        bytes data;\n    }\n\n    function decodeCookWithSignature(bytes calldata rawData) public pure returns (CookAction[] memory cookActions) {\n        return decodeCookData(rawData[4:]);\n    }\n\n    function decodeCookData(bytes calldata data) public pure returns (CookAction[] memory cookActions) {\n        (uint8[] memory actions, uint256[] memory values, bytes[] memory datas) = abi.decode(data, (uint8[], uint256[], bytes[]));\n\n        cookActions = new CookAction[](actions.length);\n\n        for (uint256 i = 0; i < actions.length; i++) {\n            uint8 action = actions[i];\n            string memory name;\n\n            if (action == ACTION_ADD_COLLATERAL) {\n                name = \"addCollateral\";\n            } else if (action == ACTION_REPAY) {\n                name = \"repay\";\n            } else if (action == ACTION_REMOVE_COLLATERAL) {\n                name = \"removeCollateral\";\n            } else if (action == ACTION_BORROW) {\n                name = \"borrow\";\n            } else if (action == ACTION_UPDATE_EXCHANGE_RATE) {\n                name = \"updateExchangeRate\";\n            } else if (action == ACTION_BENTO_SETAPPROVAL) {\n                name = \"bentoSetApproval\";\n            } else if (action == ACTION_BENTO_DEPOSIT) {\n                name = \"bentoDeposit\";\n            } else if (action == ACTION_BENTO_WITHDRAW) {\n                name = \"bentoWithdraw\";\n            } else if (action == ACTION_BENTO_TRANSFER) {\n                name = \"bentoTransfer\";\n            } else if (action == ACTION_BENTO_TRANSFER_MULTIPLE) {\n                name = \"bentoTransferMultiple\";\n            } else if (action == ACTION_CALL) {\n                name = \"call\";\n            } else if (action == ACTION_GET_REPAY_SHARE) {\n                name = \"getRepayShare\";\n            } else if (action == ACTION_GET_REPAY_PART) {\n                name = \"getRepayPart\";\n            }\n\n            cookActions[i] = CookAction(name, action, values[i], datas[i]);\n        }\n    }\n\n    function decode_addCollateral(bytes calldata data)\n        public\n        pure\n        returns (\n            int256 share,\n            address to,\n            bool skim\n        )\n    {\n        return abi.decode(data, (int256, address, bool));\n    }\n\n    function decode_repay(bytes calldata data)\n        public\n        pure\n        returns (\n            int256 part,\n            address to,\n            bool skim\n        )\n    {\n        return abi.decode(data, (int256, address, bool));\n    }\n\n    function decode_removeCollateral(bytes calldata data) public pure returns (int256 share, address to) {\n        return abi.decode(data, (int256, address));\n    }\n\n    function decode_borrow(bytes calldata data) public pure returns (int256 amount, address to) {\n        return abi.decode(data, (int256, address));\n    }\n\n    function decode_updateExchangeRate(bytes calldata data)\n        public\n        pure\n        returns (\n            bool mustUpdate,\n            uint256 minRate,\n            uint256 maxRate\n        )\n    {\n        return abi.decode(data, (bool, uint256, uint256));\n    }\n\n    function decode_bentoSetApproval(bytes calldata data)\n        public\n        pure\n        returns (\n            address user,\n            address masterContract,\n            bool approved,\n            uint8 v,\n            bytes32 r,\n            bytes32 s\n        )\n    {\n        return abi.decode(data, (address, address, bool, uint8, bytes32, bytes32));\n    }\n\n    function decode_bentoDeposit(bytes calldata data)\n        public\n        pure\n        returns (\n            address token,\n            address to,\n            int256 amount,\n            int256 share\n        )\n    {\n        return abi.decode(data, (address, address, int256, int256));\n    }\n\n    function decode_bentoWithdraw(bytes calldata data)\n        public\n        pure\n        returns (\n            address token,\n            address to,\n            int256 amount,\n            int256 share\n        )\n    {\n        return abi.decode(data, (address, address, int256, int256));\n    }\n\n    function decode_bentoTransfer(bytes calldata data)\n        public\n        pure\n        returns (\n            address token,\n            address to,\n            int256 share\n        )\n    {\n        return abi.decode(data, (address, address, int256));\n    }\n\n    function decode_bentoTransferMultiple(bytes calldata data)\n        public\n        pure\n        returns (\n            address token,\n            address[] memory tos,\n            uint256[] memory shares\n        )\n    {\n        return abi.decode(data, (address, address[], uint256[]));\n    }\n\n    function decode_call(bytes calldata data)\n        public\n        pure\n        returns (\n            address callee,\n            bytes memory callData,\n            bool useValue1,\n            bool useValue2,\n            uint8 returnValues\n        )\n    {\n        return abi.decode(data, (address, bytes, bool, bool, uint8));\n    }\n\n    function decode_getRepayShare(bytes calldata data) public pure returns (int256 part) {\n        return abi.decode(data, (int256));\n    }\n\n    function decode_getRepayPart(bytes calldata data) public pure returns (int256 amount) {\n        return abi.decode(data, (int256));\n    }\n}\n"
    }
  }
}}