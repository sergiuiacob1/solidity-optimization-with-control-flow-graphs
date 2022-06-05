{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": false
      },
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
    "contracts/persistent/external-positions/IExternalPosition.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n    (c) Enzyme Council <council@enzyme.finance>\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IExternalPosition Contract\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IExternalPosition {\n    function getDebtAssets() external returns (address[] memory, uint256[] memory);\n\n    function getManagedAssets() external returns (address[] memory, uint256[] memory);\n\n    function init(bytes memory) external;\n\n    function receiveCallFromVault(bytes memory) external;\n}\n"
    },
    "contracts/release/extensions/external-position-manager/external-positions/IExternalPositionParser.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IExternalPositionParser Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Interface for all external position parsers\ninterface IExternalPositionParser {\n    function parseAssetsForAction(\n        address _externalPosition,\n        uint256 _actionId,\n        bytes memory _encodedActionArgs\n    )\n        external\n        returns (\n            address[] memory assetsToTransfer_,\n            uint256[] memory amountsToTransfer_,\n            address[] memory assetsToReceive_\n        );\n\n    function parseInitArgs(address _vaultProxy, bytes memory _initializationData)\n        external\n        returns (bytes memory initArgs_);\n}\n"
    },
    "contracts/release/extensions/external-position-manager/external-positions/the-graph-delegation/ITheGraphDelegationPosition.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n    (c) Enzyme Council <council@enzyme.finance>\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\nimport \"../../../../../persistent/external-positions/IExternalPosition.sol\";\n\npragma solidity 0.6.12;\n\n/// @title ITheGraphDelegationPosition Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface ITheGraphDelegationPosition is IExternalPosition {\n    enum Actions {Delegate, Undelegate, Withdraw}\n}\n"
    },
    "contracts/release/extensions/external-position-manager/external-positions/the-graph-delegation/TheGraphDelegationPositionDataDecoder.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n    (c) Enzyme Council <council@enzyme.finance>\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\n/// @title TheGraphDelegationPositionDataDecoder Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Abstract contract containing data decodings for TheGraphDelegationPosition payloads\nabstract contract TheGraphDelegationPositionDataDecoder {\n    /// @dev Helper to decode args used during the Delegate action\n    function __decodeDelegateActionArgs(bytes memory _actionArgs)\n        internal\n        pure\n        returns (address indexer_, uint256 tokens_)\n    {\n        return abi.decode(_actionArgs, (address, uint256));\n    }\n\n    /// @dev Helper to decode args used during the Undelegate action\n    function __decodeUndelegateActionArgs(bytes memory _actionArgs)\n        internal\n        pure\n        returns (address indexer_, uint256 shares_)\n    {\n        return abi.decode(_actionArgs, (address, uint256));\n    }\n\n    /// @dev Helper to decode args used during the Withdraw action\n    function __decodeWithdrawActionArgs(bytes memory _actionArgs)\n        internal\n        pure\n        returns (address indexer_, address nextIndexer_)\n    {\n        return abi.decode(_actionArgs, (address, address));\n    }\n}\n"
    },
    "contracts/release/extensions/external-position-manager/external-positions/the-graph-delegation/TheGraphDelegationPositionParser.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n    (c) Enzyme Council <council@enzyme.finance>\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\nimport \"../IExternalPositionParser.sol\";\nimport \"./TheGraphDelegationPositionDataDecoder.sol\";\nimport \"./ITheGraphDelegationPosition.sol\";\n\npragma solidity 0.6.12;\n\n/// @title TheGraphDelegationPositionParser\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Parser for The Graph Delegation positions\ncontract TheGraphDelegationPositionParser is\n    IExternalPositionParser,\n    TheGraphDelegationPositionDataDecoder\n{\n    address private immutable GRT_TOKEN;\n\n    constructor(address _grtToken) public {\n        GRT_TOKEN = _grtToken;\n    }\n\n    /// @notice Parses the assets to send and receive for the callOnExternalPosition\n    /// @param _actionId The _actionId for the callOnExternalPosition\n    /// @param _encodedActionArgs The encoded parameters for the callOnExternalPosition\n    /// @return assetsToTransfer_ The assets to be transferred from the Vault\n    /// @return amountsToTransfer_ The amounts to be transferred from the Vault\n    /// @return assetsToReceive_ The assets to be received at the Vault\n    function parseAssetsForAction(\n        address,\n        uint256 _actionId,\n        bytes memory _encodedActionArgs\n    )\n        external\n        override\n        returns (\n            address[] memory assetsToTransfer_,\n            uint256[] memory amountsToTransfer_,\n            address[] memory assetsToReceive_\n        )\n    {\n        if (_actionId == uint256(ITheGraphDelegationPosition.Actions.Delegate)) {\n            (, uint256 amount) = __decodeDelegateActionArgs(_encodedActionArgs);\n\n            assetsToTransfer_ = new address[](1);\n            assetsToTransfer_[0] = GRT_TOKEN;\n\n            amountsToTransfer_ = new uint256[](1);\n            amountsToTransfer_[0] = amount;\n        } else {\n            // Action.Undelegate and Action.Withdraw\n            assetsToReceive_ = new address[](1);\n            assetsToReceive_[0] = GRT_TOKEN;\n        }\n\n        return (assetsToTransfer_, amountsToTransfer_, assetsToReceive_);\n    }\n\n    /// @notice Parse and validate input arguments to be used when initializing a newly-deployed ExternalPositionProxy\n    /// @dev Empty for this external position type\n    function parseInitArgs(address, bytes memory) external override returns (bytes memory) {}\n}\n"
    }
  }
}}