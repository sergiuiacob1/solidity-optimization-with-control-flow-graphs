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
      "enabled": true,
      "runs": 100
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
    "src/IAssetMatcher.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.2 <0.8.0;\npragma abicoder v2;\n\nimport \"./lib/LibAsset.sol\";\n\ninterface IAssetMatcher {\n    function matchAssets(LibAsset.AssetType memory leftAssetType, LibAsset.AssetType memory rightAssetType)\n        external\n        view\n        returns (LibAsset.AssetType memory);\n}\n"
    },
    "src/custom-matcher/AssetMatcherCollection.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.2 <0.8.0;\npragma abicoder v2;\n\nimport \"../IAssetMatcher.sol\";\n\n/*\n * Custom matcher for collection (assetClass, that need any/all elements from collection)\n */\ncontract AssetMatcherCollection is IAssetMatcher {\n    bytes constant EMPTY = \"\";\n\n    function matchAssets(LibAsset.AssetType memory leftAssetType, LibAsset.AssetType memory rightAssetType)\n        public\n        view\n        override\n        returns (LibAsset.AssetType memory)\n    {\n        if (\n            (rightAssetType.assetClass == LibAsset.ERC721_ASSET_CLASS) ||\n            (rightAssetType.assetClass == LibAsset.ERC1155_ASSET_CLASS) ||\n            (rightAssetType.assetClass == LibAsset.CRYPTO_PUNKS)\n        ) {\n            address leftToken = abi.decode(leftAssetType.data, (address));\n            (address rightToken, ) = abi.decode(rightAssetType.data, (address, uint256));\n            if (leftToken == rightToken) {\n                return LibAsset.AssetType(rightAssetType.assetClass, rightAssetType.data);\n            }\n        }\n        return LibAsset.AssetType(0, EMPTY);\n    }\n}\n"
    },
    "src/lib/LibAsset.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.2 <0.8.0;\n\nlibrary LibAsset {\n    bytes4 public constant ETH_ASSET_CLASS = bytes4(keccak256(\"ETH\"));\n    bytes4 public constant ERC20_ASSET_CLASS = bytes4(keccak256(\"ERC20\"));\n    bytes4 public constant ERC721_ASSET_CLASS = bytes4(keccak256(\"ERC721\"));\n    bytes4 public constant ERC1155_ASSET_CLASS = bytes4(keccak256(\"ERC1155\"));\n    bytes4 public constant _GHOSTMARKET_NFT_ROYALTIES = bytes4(keccak256(\"_GHOSTMARKET_NFT_ROYALTIES\"));\n    bytes4 public constant COLLECTION = bytes4(keccak256(\"COLLECTION\"));\n    bytes4 public constant CRYPTO_PUNKS = bytes4(keccak256(\"CRYPTO_PUNKS\"));\n\n    bytes32 constant ASSET_TYPE_TYPEHASH = keccak256(\"AssetType(bytes4 assetClass,bytes data)\");\n\n    bytes32 constant ASSET_TYPEHASH =\n        keccak256(\"Asset(AssetType assetType,uint256 value)AssetType(bytes4 assetClass,bytes data)\");\n\n    struct AssetType {\n        bytes4 assetClass;\n        bytes data;\n    }\n\n    struct Asset {\n        AssetType assetType;\n        uint256 value;\n    }\n\n    function hash(AssetType memory assetType) internal pure returns (bytes32) {\n        return keccak256(abi.encode(ASSET_TYPE_TYPEHASH, assetType.assetClass, keccak256(assetType.data)));\n    }\n\n    function hash(Asset memory asset) internal pure returns (bytes32) {\n        return keccak256(abi.encode(ASSET_TYPEHASH, hash(asset.assetType), asset.value));\n    }\n}\n"
    }
  }
}}