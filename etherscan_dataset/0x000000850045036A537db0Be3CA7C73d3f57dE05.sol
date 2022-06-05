{{
  "language": "Solidity",
  "sources": {
    "BadgerRegistry.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity >=0.6.0 <0.7.0;\npragma experimental ABIEncoderV2;\n\nimport \"EnumerableSet.sol\";\n\n\ncontract BadgerRegistry {\n  using EnumerableSet for EnumerableSet.AddressSet;\n\n  //@dev is the vault at the experimental, guarded or open stage? Only for Prod Vaults\n  enum VaultStatus { experimental, guarded, open, discontinued }\n\n  struct VaultData {\n    string version;\n    VaultStatus status;\n    address[] list;\n  }\n\n  //@dev Multisig. Vaults from here are considered Production ready\n  address public governance;\n  address public devGovernance; //@notice an address with some powers to make things easier in development\n\n  //@dev Given an Author Address, and Version, Return the Vault\n  mapping(address => mapping(string => EnumerableSet.AddressSet)) private vaults;\n  mapping(string => address) public addresses;\n\n  //@dev Given Version and VaultStatus, returns the list of Vaults in production\n  mapping(string => mapping(VaultStatus => EnumerableSet.AddressSet)) private productionVaults;\n\n  // Known constants you can use\n  string[] public keys; //@notice, you don't have a guarantee of the key being there, it's just a utility\n  string[] public versions; //@notice, you don't have a guarantee of the key being there, it's just a utility\n\n  event NewVault(address author, string version, address vault);\n  event RemoveVault(address author, string version, address vault);\n  event PromoteVault(address author, string version, address vault, VaultStatus status);\n  event DemoteVault(address author, string version, address vault, VaultStatus status);\n\n  event Set(string key, address at);\n  event AddKey(string key);\n  event DeleteKey(string key);\n  event AddVersion(string version);\n\n  function initialize(address newGovernance) public {\n    require(governance == address(0));\n    governance = newGovernance;\n    devGovernance = address(0);\n\n    versions.push(\"v1\"); //For v1\n    versions.push(\"v2\"); //For v2\n  }\n\n  function setGovernance(address _newGov) public {\n    require(msg.sender == governance, \"!gov\");\n    governance = _newGov;\n  }\n\n  function setDev(address newDev) public {\n    require(msg.sender == governance || msg.sender == devGovernance, \"!gov\");\n    devGovernance = newDev;\n  }\n\n  //@dev Utility function to add Versions for Vaults,\n  //@notice No guarantee that it will be properly used\n  function addVersions(string memory version) public {\n    require(msg.sender == governance, \"!gov\");\n    versions.push(version);\n\n    emit AddVersion(version);\n  }\n\n\n  //@dev Anyone can add a vault to here, it will be indexed by their address\n  function add(string memory version, address vault) public {\n    bool added = vaults[msg.sender][version].add(vault);\n    if (added) {\n      emit NewVault(msg.sender, version, vault);\n    }\n  }\n\n  //@dev Remove the vault from your index\n  function remove(string memory version, address vault) public {\n    bool removed = vaults[msg.sender][version].remove(vault);\n    if (removed) {\n      emit RemoveVault(msg.sender, version, vault);\n     }\n  }\n\n  //@dev Promote a vault to Production\n  //@dev Promote just means indexed by the Governance Address\n  function promote(string memory version, address vault, VaultStatus status) public {\n    require(msg.sender == governance || msg.sender == devGovernance, \"!gov\");\n    require(status != VaultStatus.discontinued);\n\n    VaultStatus actualStatus = status;\n    if(msg.sender == devGovernance) {\n      actualStatus = VaultStatus.experimental;\n    }\n\n    bool added = productionVaults[version][actualStatus].add(vault);\n\n    // If added remove from old and emit event\n    if (added) {\n      // also remove from old prod\n      if(uint256(actualStatus) == 2){\n        // Remove from prev2\n        productionVaults[version][VaultStatus(0)].remove(vault);\n        productionVaults[version][VaultStatus(1)].remove(vault);\n      }\n      if(uint256(actualStatus) == 1){\n        // Remove from prev1\n        productionVaults[version][VaultStatus(0)].remove(vault);\n      }\n\n      emit PromoteVault(msg.sender, version, vault, actualStatus);\n    }\n  }\n\n  function demote(string memory version, address vault, VaultStatus status) public {\n    require(msg.sender == governance || msg.sender == devGovernance, \"!gov\");\n\n    VaultStatus actualStatus = status;\n    if(msg.sender == devGovernance) {\n      actualStatus = VaultStatus.experimental;\n    }\n\n    bool removed = productionVaults[version][actualStatus].remove(vault);\n\n    if (removed) {\n      emit DemoteVault(msg.sender, version, vault, status);\n    }\n  }\n\n  /** KEY Management */\n\n  //@dev Set the value of a key to a specific address\n  //@notice e.g. controller = 0x123123\n  function set(string memory key, address at) public {\n    require(msg.sender == governance, \"!gov\");\n    _addKey(key);\n    addresses[key] = at;\n    emit Set(key, at);\n  }\n\n  //@dev Delete a key\n  function deleteKey(string memory key) public {\n    require(msg.sender == governance, \"!gov\");\n    for(uint256 x = 0; x < keys.length; x++){\n      // Compare strings via their hash because solidity\n      if(keccak256(bytes(key)) == keccak256(bytes(keys[x]))) {\n        delete addresses[key];\n        keys[x] = keys[keys.length - 1];\n        keys.pop();\n        emit DeleteKey(key);\n        return;\n      }\n    }\n\n  }\n\n  //@dev Retrieve the value of a key\n  function get(string memory key) public view returns (address){\n    return addresses[key];\n  }\n\n  //@dev Get keys count\n  function keysCount() public view returns (uint256){\n    return keys.length;\n  }\n\n  //@dev Add a key to the list of keys\n  //@notice This is used to make it easier to discover keys,\n  //@notice however you have no guarantee that all keys will be in the list\n  function _addKey(string memory key) internal {\n    //If we find the key, skip\n    for(uint256 x = 0; x < keys.length; x++){\n      // Compare strings via their hash because solidity\n      if(keccak256(bytes(key)) == keccak256(bytes(keys[x]))) {\n        return;\n      }\n    }\n\n    // Else let's add it and emit the event\n    keys.push(key);\n\n    emit AddKey(key);\n  }\n\n  //@dev Retrieve a list of all Vault Addresses from the given author\n  function getVaults(string memory version, address author) public view returns (address[] memory) {\n    uint256 length = vaults[author][version].length();\n\n    address[] memory list = new address[](length);\n    for (uint256 i = 0; i < length; i++) {\n      list[i] = vaults[author][version].at(i);\n    }\n    return list;\n  }\n\n  //@dev Retrieve a list of all Vaults that are in production, based on Version and Status\n  function getFilteredProductionVaults(string memory version, VaultStatus status) public view returns (address[] memory) {\n    uint256 length = productionVaults[version][status].length();\n\n    address[] memory list = new address[](length);\n    for (uint256 i = 0; i < length; i++) {\n      list[i] = productionVaults[version][status].at(i);\n    }\n    return list;\n  }\n\n  function getProductionVaults() public view returns (VaultData[] memory) {\n    uint256 versionsCount = versions.length;\n\n    VaultData[] memory data = new VaultData[](versionsCount * 3);\n\n    for(uint256 x = 0; x < versionsCount; x++) {\n      for(uint256 y = 0; y < 3; y++) {\n        uint256 length = productionVaults[versions[x]][VaultStatus(y)].length();\n        address[] memory list = new address[](length);\n        for(uint256 z = 0; z < length; z++){\n          list[z] = productionVaults[versions[x]][VaultStatus(y)].at(z);\n        }\n        data[x * (versionsCount - 1) + y * 2] = VaultData({\n          version: versions[x],\n          status: VaultStatus(y),\n          list: list\n        });\n      }\n    }\n\n    return data;\n  }\n}"
    },
    "EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.6.0;\n\n/**\n * @dev Library for managing\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\n * types.\n *\n * Sets have the following properties:\n *\n * - Elements are added, removed, and checked for existence in constant time\n * (O(1)).\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\n *\n * ```\n * contract Example {\n *     // Add the library methods\n *     using EnumerableSet for EnumerableSet.AddressSet;\n *\n *     // Declare a set state variable\n *     EnumerableSet.AddressSet private mySet;\n * }\n * ```\n *\n * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`\n * (`UintSet`) are supported.\n */\nlibrary EnumerableSet {\n    // To implement this library for multiple types with as little code\n    // repetition as possible, we write it in terms of a generic Set type with\n    // bytes32 values.\n    // The Set implementation uses private functions, and user-facing\n    // implementations (such as AddressSet) are just wrappers around the\n    // underlying Set.\n    // This means that we can only create new EnumerableSets for types that fit\n    // in bytes32.\n\n    struct Set {\n        // Storage of set values\n        bytes32[] _values;\n\n        // Position of the value in the `values` array, plus 1 because index 0\n        // means a value is not in the set.\n        mapping (bytes32 => uint256) _indexes;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function _add(Set storage set, bytes32 value) private returns (bool) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            // The value is stored at length-1, but we add 1 to all indexes\n            // and use 0 as a sentinel value\n            set._indexes[value] = set._values.length;\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\n        // We read and store the value's index to prevent multiple reads from the same storage slot\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) { // Equivalent to contains(set, value)\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\n            // the array, and then remove the last element (sometimes called as 'swap and pop').\n            // This modifies the order of the array, as noted in {at}.\n\n            uint256 toDeleteIndex = valueIndex - 1;\n            uint256 lastIndex = set._values.length - 1;\n\n            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs\n            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.\n\n            bytes32 lastvalue = set._values[lastIndex];\n\n            // Move the last value to the index where the value to delete is\n            set._values[toDeleteIndex] = lastvalue;\n            // Update the index for the moved value\n            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based\n\n            // Delete the slot where the moved value was stored\n            set._values.pop();\n\n            // Delete the index for the deleted slot\n            delete set._indexes[value];\n\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\n        require(set._values.length > index, \"EnumerableSet: index out of bounds\");\n        return set._values[index];\n    }\n\n    // AddressSet\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(AddressSet storage set, address value) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(value)));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(AddressSet storage set, address value) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(value)));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(value)));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\n        return address(uint256(_at(set._inner, index)));\n    }\n\n\n    // UintSet\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "BadgerRegistry.sol": {}
    },
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
  }
}}