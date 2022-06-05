{{
  "language": "Solidity",
  "sources": {
    "DeterministicFactory.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport {CREATE3} from \"CREATE3.sol\";\nimport {AdminUpgradeabilityProxy} from \"AdminUpgradeabilityProxy.sol\";\n\n/// WARNING: Dont use this to deploy proxy contracts where the msg.sender is used in the initialize method.\n\n/// @title For deterministic deployment of proxy contracts\n/// @notice deploys a proxy contract for the _logic contract address provided\n/// the contract address only depends on the salt provided. For the same salt, it will deploy contracts with the same address on any chain\n/// use the getDeployed() method to view the address for your to be deployed contract in advance\ncontract DeterministicFactory {\n    event NewContractDeployed(address proxy, address logic, address admin);\n\n    /// @notice deploys a new proxy contract for the _logic contract provided\n    /// @param salt the key which determines the contract address. Keep this same on multiple chains to deploy contracts with the same address\n    /// @param value the value to send to the proxy contract if any\n    /// @param _admin the admin of the proxy contract (the address that can change the proxy implementation)\n    /// @param _data encoded data of the initialization method to call on the proxy contract\n    /// @return proxy the address of the proxy contract deployed for the _logic contract\n    function deploy(\n        bytes32 salt,\n        uint256 value,\n        address _logic,\n        address _admin,\n        bytes memory _data\n    ) public returns (address proxy) {\n        proxy = CREATE3.deploy(\n            salt,\n            abi.encodePacked(\n                type(AdminUpgradeabilityProxy).creationCode,\n                abi.encode(_logic, _admin, _data)\n            ),\n            value\n        );\n        emit NewContractDeployed(proxy, _logic, _admin);\n    }\n\n    /// @notice will return the expected contract address if this salt is used in the deploy() method\n    function getDeployed(bytes32 salt) public view returns (address) {\n        return CREATE3.getDeployed(salt);\n    }\n}\n"
    },
    "CREATE3.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.6.0;\n\nimport {Bytes32AddressLib} from \"Bytes32AddressLib.sol\";\n\n/// @notice Deploy to deterministic addresses without an initcode factor.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/CREATE3.sol)\n/// @author Modified from 0xSequence (https://github.com/0xSequence/create3/blob/master/contracts/Create3.sol)\nlibrary CREATE3 {\n    using Bytes32AddressLib for bytes32;\n\n    //--------------------------------------------------------------------------------//\n    // Opcode     | Opcode + Arguments    | Description      | Stack View             //\n    //--------------------------------------------------------------------------------//\n    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 0 size               //\n    // 0x37       |  0x37                 | CALLDATACOPY     |                        //\n    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //\n    // 0x34       |  0x34                 | CALLVALUE        | value 0 size           //\n    // 0xf0       |  0xf0                 | CREATE           | newContract            //\n    //--------------------------------------------------------------------------------//\n    // Opcode     | Opcode + Arguments    | Description      | Stack View             //\n    //--------------------------------------------------------------------------------//\n    // 0x67       |  0x67XXXXXXXXXXXXXXXX | PUSH8 bytecode   | bytecode               //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 bytecode             //\n    // 0x52       |  0x52                 | MSTORE           |                        //\n    // 0x60       |  0x6008               | PUSH1 08         | 8                      //\n    // 0x60       |  0x6018               | PUSH1 18         | 24 8                   //\n    // 0xf3       |  0xf3                 | RETURN           |                        //\n    //--------------------------------------------------------------------------------//\n    bytes internal constant PROXY_BYTECODE =\n        hex\"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3\";\n\n    bytes32 internal constant PROXY_BYTECODE_HASH = keccak256(PROXY_BYTECODE);\n\n    function deploy(\n        bytes32 salt,\n        bytes memory creationCode,\n        uint256 value\n    ) internal returns (address deployed) {\n        bytes memory proxyChildBytecode = PROXY_BYTECODE;\n\n        address proxy;\n        assembly {\n            // Deploy a new contract with our pre-made bytecode via CREATE2.\n            // We start 32 bytes into the code to avoid copying the byte length.\n            proxy := create2(\n                0,\n                add(proxyChildBytecode, 32),\n                mload(proxyChildBytecode),\n                salt\n            )\n        }\n        require(proxy != address(0), \"DEPLOYMENT_FAILED\");\n\n        deployed = getDeployed(salt);\n        (bool success, ) = proxy.call{value: value}(creationCode);\n        uint256 codeSize;\n        assembly {\n            codeSize := extcodesize(deployed)\n        }\n        require(success && codeSize != 0, \"INITIALIZATION_FAILED\");\n    }\n\n    function getDeployed(bytes32 salt) internal view returns (address) {\n        address proxy = keccak256(\n            abi.encodePacked(\n                // Prefix:\n                bytes1(0xFF),\n                // Creator:\n                address(this),\n                // Salt:\n                salt,\n                // Bytecode hash:\n                PROXY_BYTECODE_HASH\n            )\n        ).fromLast20Bytes();\n\n        return\n            keccak256(\n                abi.encodePacked(\n                    // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)\n                    // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)\n                    hex\"d6_94\",\n                    proxy,\n                    hex\"01\" // Nonce of the proxy contract (1)\n                )\n            ).fromLast20Bytes();\n    }\n}\n"
    },
    "Bytes32AddressLib.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.6.0;\n\n/// @notice Library for converting between addresses and bytes32 values.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/Bytes32AddressLib.sol)\nlibrary Bytes32AddressLib {\n    function fromLast20Bytes(bytes32 bytesValue)\n        internal\n        pure\n        returns (address)\n    {\n        return address(uint160(uint256(bytesValue)));\n    }\n\n    function fillLast12Bytes(address addressValue)\n        internal\n        pure\n        returns (bytes32)\n    {\n        return bytes32(bytes20(addressValue));\n    }\n}\n"
    },
    "AdminUpgradeabilityProxy.sol": {
      "content": "/**\n *Submitted for verification at Etherscan.io on 2020-10-09\n */\n\n// SPDX-License-Identifier: MIT\n\npragma solidity 0.6.12;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n}\n\n/**\n * @title Proxy\n * @dev Implements delegation of calls to other contracts, with proper\n * forwarding of return values and bubbling of failures.\n * It defines a fallback function that delegates all calls to the address\n * returned by the abstract _implementation() internal function.\n */\nabstract contract Proxy {\n    /**\n     * @dev Fallback function.\n     * Implemented entirely in `_fallback`.\n     */\n    fallback() external payable {\n        _fallback();\n    }\n\n    /**\n     * @dev Receive function.\n     * Implemented entirely in `_fallback`.\n     */\n    receive() external payable {\n        _fallback();\n    }\n\n    /**\n     * @return The Address of the implementation.\n     */\n    function _implementation() internal view virtual returns (address);\n\n    /**\n     * @dev Delegates execution to an implementation contract.\n     * This is a low level function that doesn't return to its internal call site.\n     * It will return to the external caller whatever the implementation returns.\n     * @param implementation Address to delegate.\n     */\n    function _delegate(address implementation) internal {\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 because we don't know the size yet.\n            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 {\n                revert(0, returndatasize())\n            }\n            default {\n                return(0, returndatasize())\n            }\n        }\n    }\n\n    /**\n     * @dev Function that is run as the first thing in the fallback function.\n     * Can be redefined in derived contracts to add functionality.\n     * Redefinitions must call super._willFallback().\n     */\n    function _willFallback() internal virtual {}\n\n    /**\n     * @dev fallback implementation.\n     * Extracted to enable manual triggering.\n     */\n    function _fallback() internal {\n        _willFallback();\n        _delegate(_implementation());\n    }\n}\n\n/**\n * @title UpgradeabilityProxy\n * @dev This contract implements a proxy that allows to change the\n * implementation address to which it will delegate.\n * Such a change is called an implementation upgrade.\n */\ncontract UpgradeabilityProxy is Proxy {\n    /**\n     * @dev Contract constructor.\n     * @param _logic Address of the initial implementation.\n     * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.\n     * It should include the signature and the parameters of the function to be called, as described in\n     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n     * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.\n     */\n    constructor(address _logic, bytes memory _data) public payable {\n        assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256(\"eip1967.proxy.implementation\")) - 1));\n        _setImplementation(_logic);\n        if (_data.length > 0) {\n            (bool success, ) = _logic.delegatecall(_data);\n            require(success);\n        }\n    }\n\n    /**\n     * @dev Emitted when the implementation is upgraded.\n     * @param implementation Address of the new implementation.\n     */\n    event Upgraded(address indexed implementation);\n\n    /**\n     * @dev Storage slot with the address of the current implementation.\n     * This is the keccak-256 hash of \"eip1967.proxy.implementation\" subtracted by 1, and is\n     * validated in the constructor.\n     */\n    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n    /**\n     * @dev Returns the current implementation.\n     * @return impl Address of the current implementation\n     */\n    function _implementation() internal view override returns (address impl) {\n        bytes32 slot = IMPLEMENTATION_SLOT;\n        assembly {\n            impl := sload(slot)\n        }\n    }\n\n    /**\n     * @dev Upgrades the proxy to a new implementation.\n     * @param newImplementation Address of the new implementation.\n     */\n    function _upgradeTo(address newImplementation) internal {\n        _setImplementation(newImplementation);\n        emit Upgraded(newImplementation);\n    }\n\n    /**\n     * @dev Sets the implementation address of the proxy.\n     * @param newImplementation Address of the new implementation.\n     */\n    function _setImplementation(address newImplementation) internal {\n        require(Address.isContract(newImplementation), \"Cannot set a proxy implementation to a non-contract address\");\n\n        bytes32 slot = IMPLEMENTATION_SLOT;\n\n        assembly {\n            sstore(slot, newImplementation)\n        }\n    }\n}\n\n/**\n * @title AdminUpgradeabilityProxy\n * @dev This contract combines an upgradeability proxy with an authorization\n * mechanism for administrative tasks.\n * All external functions in this contract must be guarded by the\n * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity\n * feature proposal that would enable this to be done automatically.\n */\ncontract AdminUpgradeabilityProxy is UpgradeabilityProxy {\n    /**\n     * Contract constructor.\n     * @param _logic address of the initial implementation.\n     * @param _admin Address of the proxy administrator.\n     * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.\n     * It should include the signature and the parameters of the function to be called, as described in\n     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n     * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.\n     */\n    constructor(\n        address _logic,\n        address _admin,\n        bytes memory _data\n    ) public payable UpgradeabilityProxy(_logic, _data) {\n        assert(ADMIN_SLOT == bytes32(uint256(keccak256(\"eip1967.proxy.admin\")) - 1));\n        _setAdmin(_admin);\n    }\n\n    /**\n     * @dev Emitted when the administration has been transferred.\n     * @param previousAdmin Address of the previous admin.\n     * @param newAdmin Address of the new admin.\n     */\n    event AdminChanged(address previousAdmin, address newAdmin);\n\n    /**\n     * @dev Storage slot with the admin of the contract.\n     * This is the keccak-256 hash of \"eip1967.proxy.admin\" subtracted by 1, and is\n     * validated in the constructor.\n     */\n\n    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;\n\n    /**\n     * @dev Modifier to check whether the `msg.sender` is the admin.\n     * If it is, it will run the function. Otherwise, it will delegate the call\n     * to the implementation.\n     */\n    modifier ifAdmin() {\n        if (msg.sender == _admin()) {\n            _;\n        } else {\n            _fallback();\n        }\n    }\n\n    /**\n     * @return The address of the proxy admin.\n     */\n    function admin() external ifAdmin returns (address) {\n        return _admin();\n    }\n\n    /**\n     * @return The address of the implementation.\n     */\n    function implementation() external ifAdmin returns (address) {\n        return _implementation();\n    }\n\n    /**\n     * @dev Changes the admin of the proxy.\n     * Only the current admin can call this function.\n     * @param newAdmin Address to transfer proxy administration to.\n     */\n    function changeAdmin(address newAdmin) external ifAdmin {\n        require(newAdmin != address(0), \"Cannot change the admin of a proxy to the zero address\");\n        emit AdminChanged(_admin(), newAdmin);\n        _setAdmin(newAdmin);\n    }\n\n    /**\n     * @dev Upgrade the backing implementation of the proxy.\n     * Only the admin can call this function.\n     * @param newImplementation Address of the new implementation.\n     */\n    function upgradeTo(address newImplementation) external ifAdmin {\n        _upgradeTo(newImplementation);\n    }\n\n    /**\n     * @dev Upgrade the backing implementation of the proxy and call a function\n     * on the new implementation.\n     * This is useful to initialize the proxied contract.\n     * @param newImplementation Address of the new implementation.\n     * @param data Data to send as msg.data in the low level call.\n     * It should include the signature and the parameters of the function to be called, as described in\n     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n     */\n    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {\n        _upgradeTo(newImplementation);\n        (bool success, ) = newImplementation.delegatecall(data);\n        require(success);\n    }\n\n    /**\n     * @return adm The admin slot.\n     */\n    function _admin() internal view returns (address adm) {\n        bytes32 slot = ADMIN_SLOT;\n        assembly {\n            adm := sload(slot)\n        }\n    }\n\n    /**\n     * @dev Sets the address of the proxy admin.\n     * @param newAdmin Address of the new proxy admin.\n     */\n    function _setAdmin(address newAdmin) internal {\n        bytes32 slot = ADMIN_SLOT;\n\n        assembly {\n            sstore(slot, newAdmin)\n        }\n    }\n\n    /**\n     * @dev Only fall back when the sender is not the admin.\n     */\n    function _willFallback() internal virtual override {\n        require(msg.sender != _admin(), \"Cannot call fallback function from the proxy admin\");\n        super._willFallback();\n    }\n}"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "DeterministicFactory.sol": {}
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}