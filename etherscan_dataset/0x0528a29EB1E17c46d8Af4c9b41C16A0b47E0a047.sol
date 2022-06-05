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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/Random.sol": {
      "content": "pragma solidity >=0.6.0 <0.8.9;\n//SPDX-License-Identifier: MIT\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\ncontract Random is Ownable{\n\n\n    uint16 private _randomIndex = 0;\n    uint private _randomCalls = 0;\n    uint16 public version=22;\n    mapping(uint16 => address) private _randomSource;\n\n    constructor(){\n        // Fill random source addresses\n        _randomSource[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n        _randomSource[1] = 0x3cD751E6b0078Be393132286c442345e5DC49699;\n        _randomSource[2] = 0xb5d85CBf7cB3EE0D56b3bB207D5Fc4B82f43F511;\n        _randomSource[3] = 0xC098B2a3Aa256D2140208C3de6543aAEf5cd3A94;\n        _randomSource[4] = 0x28C6c06298d514Db089934071355E5743bf21d60;\n        _randomSource[5] = 0x2FAF487A4414Fe77e2327F0bf4AE2a264a776AD2;\n        _randomSource[6] = 0x267be1C1D684F78cb4F6a176C4911b741E4Ffdc0;\n    }\n\n    function updateRandomIndex() public {\n        _randomIndex += 1;\n        _randomCalls += 1;\n        if (_randomIndex > 6) _randomIndex = 0;\n    }\n\n    function getSomeRandomNumber(uint _seed, uint _limit) public view returns (uint16) {\n        uint extra = 0;\n        for (uint16 i = 0; i < 7; i++) {\n            extra += _randomSource[_randomIndex].balance;\n        }\n\n        uint random = uint(\n            keccak256(\n                abi.encodePacked(\n                    _seed,\n                    blockhash(block.number - 1),\n                    block.coinbase,\n                    block.difficulty,\n                    msg.sender,\n                    block.timestamp,\n                    extra,\n                    _randomCalls,\n                    _randomIndex\n                )\n            )\n        );\n\n        return uint16(random % _limit);\n    }\n\n    function changeRandomSource(uint16 _id, address _address) public onlyOwner {\n        _randomSource[_id] = _address;\n    }\n\n    function shuffleSeeds(uint _seed, uint _max) public onlyOwner {\n        uint shuffleCount = getSomeRandomNumber(_seed, _max);\n        _randomIndex = uint16(shuffleCount);\n        for (uint i = 0; i < shuffleCount; i++) {\n            updateRandomIndex();\n        }\n    }\n}"
    }
  }
}}