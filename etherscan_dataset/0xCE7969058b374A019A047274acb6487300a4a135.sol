{{
  "language": "Solidity",
  "sources": {
    "TransferProtector.sol": {
      "content": "// SPDX-License-Identifier: LGPL-3.0-only\npragma solidity 0.8.14;\n\nimport \"Pausable.sol\";\nimport \"EnumerableSet.sol\";\n\nimport \"Ownable.sol\";\n\n\ncontract TransferProtector is Ownable, Pausable {\n    using EnumerableSet for EnumerableSet.AddressSet;\n\n    string public constant NAME = \"Transfer Protector\";\n    string public constant VERSION = \"0.1.0\";\n\n    EnumerableSet.AddressSet receiverSet;\n\n    event receiverAdded(\n        address indexed sender,\n        address indexed receiver\n    );\n    event receiverRemoved(\n        address indexed sender,\n        address indexed receiver\n    );\n\n    constructor(address payable _safe) {\n        require(_safe != address(0), \"Invalid safe address\");\n\n        // make the given safe the owner of the current protector.\n        _transferOwnership(_safe);\n    }\n\n    function check(\n        bytes32[] calldata _roles,\n        address _receiver,\n        uint256 _value\n    ) external whenNotPaused returns (bool) {\n        _roles; // implement role based check when needed\n        _value; // implement value control when needed\n        return receiverSet.contains(_receiver);\n    }\n\n    function addReceiver(address _receiver)\n        external\n        onlyOwner\n    {\n        receiverSet.add(_receiver);\n        emit receiverAdded(_msgSender(), _receiver);\n    }\n\n    function removeReceiver(address _receiver)\n        external\n        onlyOwner\n    {\n        receiverSet.remove(_receiver);\n        emit receiverRemoved(_msgSender(), _receiver);\n    }\n\n    function getAllReceivers() public view returns (address[] memory) {\n        bytes32[] memory store = receiverSet._inner._values;\n        address[] memory result;\n        assembly {\n            result := store\n        }\n        return result;\n    }\n\n    function setPaused(bool paused) external onlyOwner {\n        if (paused) _pause();\n        else _unpause();\n    }\n}\n"
    },
    "Pausable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"Context.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\nabstract contract Pausable is Context {\n    /**\n     * @dev Emitted when the pause is triggered by `account`.\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by `account`.\n     */\n    event Unpaused(address account);\n\n    bool private _paused;\n\n    /**\n     * @dev Initializes the contract in unpaused state.\n     */\n    constructor() {\n        _paused = false;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view virtual returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    modifier whenNotPaused() {\n        require(!paused(), \"Pausable: paused\");\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    modifier whenPaused() {\n        require(paused(), \"Pausable: not paused\");\n        _;\n    }\n\n    /**\n     * @dev Triggers stopped state.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    function _pause() internal virtual whenNotPaused {\n        _paused = true;\n        emit Paused(_msgSender());\n    }\n\n    /**\n     * @dev Returns to normal state.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    function _unpause() internal virtual whenPaused {\n        _paused = false;\n        emit Unpaused(_msgSender());\n    }\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Library for managing\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\n * types.\n *\n * Sets have the following properties:\n *\n * - Elements are added, removed, and checked for existence in constant time\n * (O(1)).\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\n *\n * ```\n * contract Example {\n *     // Add the library methods\n *     using EnumerableSet for EnumerableSet.AddressSet;\n *\n *     // Declare a set state variable\n *     EnumerableSet.AddressSet private mySet;\n * }\n * ```\n *\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\n * and `uint256` (`UintSet`) are supported.\n */\nlibrary EnumerableSet {\n    // To implement this library for multiple types with as little code\n    // repetition as possible, we write it in terms of a generic Set type with\n    // bytes32 values.\n    // The Set implementation uses private functions, and user-facing\n    // implementations (such as AddressSet) are just wrappers around the\n    // underlying Set.\n    // This means that we can only create new EnumerableSets for types that fit\n    // in bytes32.\n\n    struct Set {\n        // Storage of set values\n        bytes32[] _values;\n        // Position of the value in the `values` array, plus 1 because index 0\n        // means a value is not in the set.\n        mapping(bytes32 => uint256) _indexes;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function _add(Set storage set, bytes32 value) private returns (bool) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            // The value is stored at length-1, but we add 1 to all indexes\n            // and use 0 as a sentinel value\n            set._indexes[value] = set._values.length;\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\n        // We read and store the value's index to prevent multiple reads from the same storage slot\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) {\n            // Equivalent to contains(set, value)\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\n            // the array, and then remove the last element (sometimes called as 'swap and pop').\n            // This modifies the order of the array, as noted in {at}.\n\n            uint256 toDeleteIndex = valueIndex - 1;\n            uint256 lastIndex = set._values.length - 1;\n\n            if (lastIndex != toDeleteIndex) {\n                bytes32 lastValue = set._values[lastIndex];\n\n                // Move the last value to the index where the value to delete is\n                set._values[toDeleteIndex] = lastValue;\n                // Update the index for the moved value\n                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex\n            }\n\n            // Delete the slot where the moved value was stored\n            set._values.pop();\n\n            // Delete the index for the deleted slot\n            delete set._indexes[value];\n\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\n        return set._values[index];\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function _values(Set storage set) private view returns (bytes32[] memory) {\n        return set._values;\n    }\n\n    // Bytes32Set\n\n    struct Bytes32Set {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _add(set._inner, value);\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _remove(set._inner, value);\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\n        return _contains(set._inner, value);\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(Bytes32Set storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\n        return _at(set._inner, index);\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {\n        return _values(set._inner);\n    }\n\n    // AddressSet\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(AddressSet storage set, address value) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(AddressSet storage set, address value) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\n        return address(uint160(uint256(_at(set._inner, index))));\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(AddressSet storage set) internal view returns (address[] memory) {\n        bytes32[] memory store = _values(set._inner);\n        address[] memory result;\n\n        assembly {\n            result := store\n        }\n\n        return result;\n    }\n\n    // UintSet\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(UintSet storage set) internal view returns (uint256[] memory) {\n        bytes32[] memory store = _values(set._inner);\n        uint256[] memory result;\n\n        assembly {\n            result := store\n        }\n\n        return result;\n    }\n}\n"
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.14;\n\nimport \"Context.sol\";\n\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function _transferOwnership(address newOwner) internal virtual onlyOwner {\n        require(\n            newOwner != address(0),\n            \"Ownable: new owner is the zero address\"\n        );\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n\nabstract contract TransferOwnable is Ownable {\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        _transferOwnership(newOwner);\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "TransferProtector.sol": {}
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