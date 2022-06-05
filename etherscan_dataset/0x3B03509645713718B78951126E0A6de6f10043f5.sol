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
      "runs": 1000000
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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@uma/core/contracts/common/implementation/MultiCaller.sol": {
      "content": "// This contract is taken from Uniswaps's multi call implementation (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/base/Multicall.sol)\n// and was modified to be solidity 0.8 compatible. Additionally, the method was restricted to only work with msg.value\n// set to 0 to avoid any nasty attack vectors on function calls that use value sent with deposits.\npragma solidity ^0.8.0;\n\n/// @title MultiCaller\n/// @notice Enables calling multiple methods in a single call to the contract\ncontract MultiCaller {\n    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {\n        require(msg.value == 0, \"Only multicall with 0 value\");\n        results = new bytes[](data.length);\n        for (uint256 i = 0; i < data.length; i++) {\n            (bool success, bytes memory result) = address(this).delegatecall(data[i]);\n\n            if (!success) {\n                // Next 5 lines from https://ethereum.stackexchange.com/a/83577\n                if (result.length < 68) revert();\n                assembly {\n                    result := add(result, 0x04)\n                }\n                revert(abi.decode(result, (string)));\n            }\n\n            results[i] = result;\n        }\n    }\n}\n"
    },
    "contracts/AcrossConfigStore.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\r\npragma solidity ^0.8.0;\r\n\r\nimport \"@uma/core/contracts/common/implementation/MultiCaller.sol\";\r\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\r\n\r\n/**\r\n * @title Allows admin to set and update configuration settings for full contract system. These settings are designed\r\n * to be consumed by off-chain bots, rather than by other contracts.\r\n * @dev This contract should not perform any validation on the setting values and should be owned by the governance\r\n * system of the full contract suite..\r\n */\r\ncontract AcrossConfigStore is Ownable, MultiCaller {\r\n    // General dictionary where admin can associate variables with specific L1 tokens, like the Rate Model and Token\r\n    // Transfer Thresholds.\r\n    mapping(address => string) public l1TokenConfig;\r\n\r\n    // General dictionary where admin can store global variables like `MAX_POOL_REBALANCE_LEAF_SIZE` and\r\n    // `MAX_RELAYER_REPAYMENT_LEAF_SIZE` that off-chain agents can query.\r\n    mapping(bytes32 => string) public globalConfig;\r\n\r\n    event UpdatedTokenConfig(address indexed key, string value);\r\n    event UpdatedGlobalConfig(bytes32 indexed key, string value);\r\n\r\n    /**\r\n     * @notice Updates token config.\r\n     * @param l1Token the l1 token address to update value for.\r\n     * @param value Value to update.\r\n     */\r\n    function updateTokenConfig(address l1Token, string memory value) external onlyOwner {\r\n        l1TokenConfig[l1Token] = value;\r\n        emit UpdatedTokenConfig(l1Token, value);\r\n    }\r\n\r\n    /**\r\n     * @notice Updates global config.\r\n     * @param key Key to update.\r\n     * @param value Value to update.\r\n     */\r\n    function updateGlobalConfig(bytes32 key, string calldata value) external onlyOwner {\r\n        globalConfig[key] = value;\r\n        emit UpdatedGlobalConfig(key, value);\r\n    }\r\n}\r\n"
    }
  }
}}