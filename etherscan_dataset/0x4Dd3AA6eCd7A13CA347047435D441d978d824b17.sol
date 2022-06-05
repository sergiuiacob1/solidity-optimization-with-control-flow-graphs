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
      "runs": 30000
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
    "contracts/ERC721MinterFree.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\nabstract contract IERC721 {\n    function mint(address to) external virtual;\n}\n\ncontract ERC721MinterFree is Ownable {\n    IERC721 public erc721;\n\n    //used to verify whitelist user\n    mapping(address => uint) public mintQuantity;\n    address public devPayoutAddress;\n    mapping(address => uint) public claimed;\n    mapping(address => bool) public whitelisted;\n\n    constructor(IERC721 erc721_) {\n        erc721 = erc721_;\n        devPayoutAddress = address(0xc891a8B00b0Ea012eD2B56767896CCf83C4A61DD);\n    }\n\n    function setNFT(IERC721 erc721_) public onlyOwner {\n        erc721 = erc721_;\n    }\n\n    function setQuantity(address buyer, uint newQ_) public onlyOwner {\n        mintQuantity[buyer] = newQ_;\n    }\n\n    function mint(uint quantity_) public {\n        //requires that user is in whitelsit\n        require(whitelisted[msg.sender], \"Address not whitelisted.\");\n\n        //check mint quantity\n        require(claimed[msg.sender] + quantity_ <= mintQuantity[msg.sender], \"Already claimed.\");\n\n        //increase quantity that user has claimed\n        claimed[msg.sender] = claimed[msg.sender] + quantity_;\n\n        //mint quantity times\n        for (uint i = 0; i < quantity_; i++) {\n            erc721.mint(msg.sender);\n        }\n    }\n\n    function addToWhitelist(address[] memory _whitelist) public onlyOwner {\n        for (uint i = 0; i < _whitelist.length; i++) {\n            whitelisted[_whitelist[i]] = true;\n        }\n    }\n}\n"
    }
  }
}}