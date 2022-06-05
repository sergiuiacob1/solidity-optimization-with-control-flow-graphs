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
    "contracts/release/extensions/external-position-manager/external-positions/convex-voting/ConvexVotingPositionDataDecoder.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n    (c) Enzyme Council <council@enzyme.finance>\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"../../../../interfaces/IVotiumMultiMerkleStash.sol\";\n\n/// @title ConvexVotingPositionDataDecoder Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Abstract contract containing data decodings for ConvexVotingPosition payloads\nabstract contract ConvexVotingPositionDataDecoder {\n    /// @dev Helper to decode args used during the ClaimRewards action\n    function __decodeClaimRewardsActionArgs(bytes memory _actionArgs)\n        internal\n        pure\n        returns (\n            address[] memory allTokensToTransfer_,\n            bool claimLockerRewards_,\n            address[] memory extraRewardTokens_,\n            IVotiumMultiMerkleStash.ClaimParam[] memory votiumClaims_,\n            bool unstakeCvxCrv_\n        )\n    {\n        return\n            abi.decode(\n                _actionArgs,\n                (address[], bool, address[], IVotiumMultiMerkleStash.ClaimParam[], bool)\n            );\n    }\n\n    /// @dev Helper to decode args used during the Delegate action\n    function __decodeDelegateActionArgs(bytes memory _actionArgs)\n        internal\n        pure\n        returns (address delegatee_)\n    {\n        return abi.decode(_actionArgs, (address));\n    }\n\n    /// @dev Helper to decode args used during the Lock action\n    function __decodeLockActionArgs(bytes memory _actionArgs)\n        internal\n        pure\n        returns (uint256 amount_, uint256 spendRatio_)\n    {\n        return abi.decode(_actionArgs, (uint256, uint256));\n    }\n}\n"
    },
    "contracts/release/extensions/external-position-manager/external-positions/convex-voting/ConvexVotingPositionParser.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\nimport \"../IExternalPositionParser.sol\";\nimport \"./ConvexVotingPositionDataDecoder.sol\";\nimport \"./IConvexVotingPosition.sol\";\n\npragma solidity 0.6.12;\n\n/// @title ConvexVotingPositionParser\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Parser for Convex vlCVX positions\ncontract ConvexVotingPositionParser is IExternalPositionParser, ConvexVotingPositionDataDecoder {\n    address private immutable CVX_TOKEN;\n\n    constructor(address _cvxToken) public {\n        CVX_TOKEN = _cvxToken;\n    }\n\n    /// @notice Parses the assets to send and receive for the callOnExternalPosition\n    /// @param _actionId The _actionId for the callOnExternalPosition\n    /// @param _encodedActionArgs The encoded parameters for the callOnExternalPosition\n    /// @return assetsToTransfer_ The assets to be transferred from the Vault\n    /// @return amountsToTransfer_ The amounts to be transferred from the Vault\n    /// @return assetsToReceive_ The assets to be received at the Vault\n    function parseAssetsForAction(\n        address,\n        uint256 _actionId,\n        bytes memory _encodedActionArgs\n    )\n        external\n        override\n        returns (\n            address[] memory assetsToTransfer_,\n            uint256[] memory amountsToTransfer_,\n            address[] memory assetsToReceive_\n        )\n    {\n        if (_actionId == uint256(IConvexVotingPosition.Actions.Lock)) {\n            (uint256 amount, ) = __decodeLockActionArgs(_encodedActionArgs);\n\n            assetsToTransfer_ = new address[](1);\n            assetsToTransfer_[0] = CVX_TOKEN;\n\n            amountsToTransfer_ = new uint256[](1);\n            amountsToTransfer_[0] = amount;\n        } else if (_actionId == uint256(IConvexVotingPosition.Actions.Withdraw)) {\n            assetsToReceive_ = new address[](1);\n            assetsToReceive_[0] = CVX_TOKEN;\n        }\n\n        // No validations or transferred assets passed for Actions.ClaimRewards\n\n        return (assetsToTransfer_, amountsToTransfer_, assetsToReceive_);\n    }\n\n    /// @notice Parse and validate input arguments to be used when initializing a newly-deployed ExternalPositionProxy\n    /// @dev Empty for this external position type\n    function parseInitArgs(address, bytes memory) external override returns (bytes memory) {}\n}\n"
    },
    "contracts/release/extensions/external-position-manager/external-positions/convex-voting/IConvexVotingPosition.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n    (c) Enzyme Council <council@enzyme.finance>\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\nimport \"../../../../../persistent/external-positions/IExternalPosition.sol\";\n\npragma solidity 0.6.12;\n\n/// @title IConvexVotingPosition Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IConvexVotingPosition is IExternalPosition {\n    enum Actions {Lock, Relock, Withdraw, ClaimRewards, Delegate}\n}\n"
    },
    "contracts/release/interfaces/IVotiumMultiMerkleStash.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n    (c) Enzyme Council <council@enzyme.finance>\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\n/// @title IVotiumMultiMerkleStash Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IVotiumMultiMerkleStash {\n    struct ClaimParam {\n        address token;\n        uint256 index;\n        uint256 amount;\n        bytes32[] merkleProof;\n    }\n\n    function claimMulti(address, ClaimParam[] calldata) external;\n}\n"
    }
  }
}}