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
    "contracts/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n// Adapted from OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)\r\n// Using less gas and initiating the first owner to the provided multisig address\r\n\r\npragma solidity ^0.8.10;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one provided during the deployment of the contract. \r\n * This can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable {\r\n\r\n    /**\r\n     * @dev Address of the current owner. \r\n     */\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @param _firstOwner Initial owner\r\n     * @dev Initializes the contract setting the initial owner.\r\n     */\r\n    constructor(address _firstOwner) {\r\n        _transferOwnership(_firstOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner == msg.sender, \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address _newOwner) public virtual onlyOwner {\r\n        require(_newOwner != address(0), \"Ownable: cannot be zero address\");\r\n        _transferOwnership(_newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address _newOwner) internal virtual {\r\n        address oldOwner = owner;\r\n        owner = _newOwner;\r\n        emit OwnershipTransferred(oldOwner, _newOwner);\r\n    }\r\n}\r\n"
    },
    "contracts/Registry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.8.10;\n\nimport \"./Ownable.sol\";\n\n/// @title Registry contract for whole Apus ecosystem\n/// @notice Holds addresses of all essential Apus contracts\ncontract Registry is Ownable {\n\n\t/// @notice Stores address under its id\n\t/// @dev Id is keccak256 hash of its string representation\n\tmapping (bytes32 => address) public addresses;\n\n\t/// @notice Emit when owner registers address\n\t/// @param id Keccak256 hash of its string id representation\n\t/// @param previousAddress Previous address value under given id\n\t/// @param newAddress New address under given id\n\tevent AddressRegistered(bytes32 indexed id, address indexed previousAddress, address indexed newAddress);\n\n\t/* solhint-disable-next-line no-empty-blocks */\n\tconstructor(address _initialOwner) Ownable(_initialOwner) {\n\n\t}\n\n\n\t/// @notice Getter for registered addresses\n\t/// @dev Returns zero address if address have not been registered before\n\t/// @param _id Registered address identifier\n\tfunction getAddress(bytes32 _id) external view returns(address) {\n\t\treturn addresses[_id];\n\t}\n\n\n\t/// @notice Register address under given id\n\t/// @dev Only owner can register addresses\n\t/// @dev Emits `AddressRegistered` event\n\t/// @param _id Keccak256 hash of its string id representation\n\t/// @param _address Registering address\n\tfunction registerAddress(bytes32 _id, address _address) public onlyOwner {\n\t\trequire(_address != address(0), \"Can't register 0x0 address\");\n\t\taddress _previousAddress = addresses[_id];\n\t\taddresses[_id] = _address;\n\t\temit AddressRegistered(_id, _previousAddress, _address);\n\t}\n\n\t/// @notice Register list of addresses under given list of ids\n\t/// @dev Only owner can register addresses\n\t/// @dev Emits `AddressRegistered` event for every address\n\t/// @param _ids List of keccak256 hashes of its string id representation\n\t/// @param _addresses List of registering addresses\n\tfunction batchRegisterAddresses(bytes32[] calldata _ids, address[] calldata _addresses) external onlyOwner {\n\t\trequire(_ids.length == _addresses.length, \"Lists do not match in length\");\n\n\t\tfor (uint256 i = 0; i < _ids.length; i++) {\n\t\t\tregisterAddress(_ids[i], _addresses[i]);\n\t\t}\n\t}\n}\n"
    }
  }
}}