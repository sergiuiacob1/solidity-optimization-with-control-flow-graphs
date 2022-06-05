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
    "contracts/CommunityAcknowledgement.sol": {
      "content": "// SPDX-License-Identifier: LGPL-3.0\npragma solidity =0.8.10;\n\nimport \"./Ownable.sol\";\n\ncontract CommunityAcknowledgement is Ownable {\n\n\t/// @notice Recognised Community Contributor Acknowledgement Rate\n\t/// @dev Id is keccak256 hash of contributor address\n\tmapping (bytes32 => uint16) public rccar;\n\n\t/// @notice Emit when owner recognises contributor\n\t/// @param contributor Keccak256 hash of recognised contributor address\n\t/// @param previousAcknowledgementRate Previous contributor acknowledgement rate\n\t/// @param newAcknowledgementRate New contributor acknowledgement rate\n\tevent ContributorRecognised(bytes32 indexed contributor, uint16 indexed previousAcknowledgementRate, uint16 indexed newAcknowledgementRate);\n\n\t/* solhint-disable-next-line no-empty-blocks */\n\tconstructor(address _adoptionDAOAddress) Ownable(_adoptionDAOAddress) {\n\n\t}\n\n\t/// @notice Getter for Recognised Community Contributor Acknowledgement Rate\n\t/// @param _contributor Keccak256 hash of contributor address\n\t/// @return Acknowledgement Rate\n\tfunction getAcknowledgementRate(bytes32 _contributor) external view returns (uint16) {\n\t\treturn rccar[_contributor];\n\t}\n\n\t/// @notice Getter for Recognised Community Contributor Acknowledgement Rate for msg.sender\n\t/// @return Acknowledgement Rate\n\tfunction senderAcknowledgementRate() external view returns (uint16) {\n\t\treturn rccar[keccak256(abi.encodePacked(msg.sender))];\n\t}\n\n\t/// @notice Recognise community contributor and set its acknowledgement rate\n\t/// @dev Only owner can recognise contributor\n\t/// @dev Emits `ContributorRecognised` event\n\t/// @param _contributor Keccak256 hash of recognised contributor address\n\t/// @param _acknowledgementRate Contributor new acknowledgement rate\n\tfunction recogniseContributor(bytes32 _contributor, uint16 _acknowledgementRate) public onlyOwner {\n\t\tuint16 _previousAcknowledgementRate = rccar[_contributor];\n\t\trccar[_contributor] = _acknowledgementRate;\n\t\temit ContributorRecognised(_contributor, _previousAcknowledgementRate, _acknowledgementRate);\n\t}\n\n\t/// @notice Recognise list of contributors\n\t/// @dev Only owner can recognise contributors\n\t/// @dev Emits `ContributorRecognised` event for every contributor\n\t/// @param _contributors List of keccak256 hash of recognised contributor addresses\n\t/// @param _acknowledgementRates List of contributors new acknowledgement rates\n\tfunction batchRecogniseContributor(bytes32[] calldata _contributors, uint16[] calldata _acknowledgementRates) external onlyOwner {\n\t\trequire(_contributors.length == _acknowledgementRates.length, \"Lists do not match in length\");\n\n\t\tfor (uint256 i = 0; i < _contributors.length; i++) {\n\t\t\trecogniseContributor(_contributors[i], _acknowledgementRates[i]);\n\t\t}\n\t}\n\n}\n"
    },
    "contracts/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n// Adapted from OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)\r\n// Using less gas and initiating the first owner to the provided multisig address\r\n\r\npragma solidity ^0.8.10;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one provided during the deployment of the contract. \r\n * This can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable {\r\n\r\n    /**\r\n     * @dev Address of the current owner. \r\n     */\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @param _firstOwner Initial owner\r\n     * @dev Initializes the contract setting the initial owner.\r\n     */\r\n    constructor(address _firstOwner) {\r\n        _transferOwnership(_firstOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner == msg.sender, \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address _newOwner) public virtual onlyOwner {\r\n        require(_newOwner != address(0), \"Ownable: cannot be zero address\");\r\n        _transferOwnership(_newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address _newOwner) internal virtual {\r\n        address oldOwner = owner;\r\n        owner = _newOwner;\r\n        emit OwnershipTransferred(oldOwner, _newOwner);\r\n    }\r\n}\r\n"
    }
  }
}}