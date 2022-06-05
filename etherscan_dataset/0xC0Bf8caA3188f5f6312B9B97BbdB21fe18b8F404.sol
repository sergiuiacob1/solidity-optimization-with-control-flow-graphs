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
    "contracts/Config.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.8.10;\n\nimport \"./Ownable.sol\";\n\n/// @title APUS config contract\n/// @notice Holds global variables for the rest of APUS ecosystem\ncontract Config is Ownable {\n\n\t/// @notice Adoption Contribution Rate, where 100% = 10000 = ACR_DECIMAL_PRECISION. \n\t/// @dev Percent value where 0 -> 0%, 10 -> 0.1%, 100 -> 1%, 250 -> 2.5%, 550 -> 5.5%, 1000 -> 10%, 0xffff -> 655.35%\n\t/// @dev Example: x * adoptionContributionRate / ACR_DECIMAL_PRECISION\n\tuint16 public adoptionContributionRate;\n\n\t/// @notice Adoption DAO multisig address\n\taddress payable public adoptionDAOAddress;\n\n\t/// @notice Emit when owner changes Adoption Contribution Rate\n\t/// @param caller Who changed the Adoption Contribution Rate (i.e. who was owner at that moment)\n\t/// @param previousACR Previous Adoption Contribution Rate\n\t/// @param newACR New Adoption Contribution Rate\n\tevent ACRChanged(address indexed caller, uint16 previousACR, uint16 newACR);\n\n\t/// @notice Emit when owner changes Adoption DAO address\n\t/// @param caller Who changed the Adoption DAO address (i.e. who was owner at that moment)\n\t/// @param previousAdoptionDAOAddress Previous Adoption DAO address\n\t/// @param newAdoptionDAOAddress New Adoption DAO address\n\tevent AdoptionDAOAddressChanged(address indexed caller, address previousAdoptionDAOAddress, address newAdoptionDAOAddress);\n\n\t/* solhint-disable-next-line func-visibility */\n\tconstructor(address payable _adoptionDAOAddress, uint16 _initialACR) Ownable(_adoptionDAOAddress) {\n\t\tadoptionContributionRate = _initialACR;\n\t\tadoptionDAOAddress = _adoptionDAOAddress;\n\t}\n\n\n\t/// @notice Change Adoption Contribution Rate\n\t/// @dev Only owner can change Adoption Contribution Rate\n\t/// @dev Emits `ACRChanged` event\n\t/// @param _newACR Adoption Contribution Rate\n\tfunction setAdoptionContributionRate(uint16 _newACR) external onlyOwner {\n\t\tuint16 _previousACR = adoptionContributionRate;\n\t\tadoptionContributionRate = _newACR;\n\t\temit ACRChanged(msg.sender, _previousACR, _newACR);\n\t}\n\n\t/// @notice Change Adoption DAO address\n\t/// @dev Only owner can change Adoption DAO address\n\t/// @dev Emits `AdoptionDAOAddressChanged` event\n\tfunction setAdoptionDAOAddress(address payable _newAdoptionDAOAddress) external onlyOwner {\n\t\taddress payable _previousAdoptionDAOAddress = adoptionDAOAddress;\n\t\tadoptionDAOAddress = _newAdoptionDAOAddress;\n\t\temit AdoptionDAOAddressChanged(msg.sender, _previousAdoptionDAOAddress, _newAdoptionDAOAddress);\n\t}\n\n}\n"
    },
    "contracts/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n// Adapted from OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)\r\n// Using less gas and initiating the first owner to the provided multisig address\r\n\r\npragma solidity ^0.8.10;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one provided during the deployment of the contract. \r\n * This can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable {\r\n\r\n    /**\r\n     * @dev Address of the current owner. \r\n     */\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @param _firstOwner Initial owner\r\n     * @dev Initializes the contract setting the initial owner.\r\n     */\r\n    constructor(address _firstOwner) {\r\n        _transferOwnership(_firstOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner == msg.sender, \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address _newOwner) public virtual onlyOwner {\r\n        require(_newOwner != address(0), \"Ownable: cannot be zero address\");\r\n        _transferOwnership(_newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address _newOwner) internal virtual {\r\n        address oldOwner = owner;\r\n        owner = _newOwner;\r\n        emit OwnershipTransferred(oldOwner, _newOwner);\r\n    }\r\n}\r\n"
    }
  }
}}