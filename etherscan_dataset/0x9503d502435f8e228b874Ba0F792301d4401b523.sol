{{
  "language": "Solidity",
  "sources": {
    "StdReferenceBasic.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\npragma solidity 0.8.13;\n\nimport {StdReferenceBase} from \"StdReferenceBase.sol\";\nimport {AccessControl} from \"AccessControl.sol\";\n\n/// @title BandChain StdReferenceBasic\n/// @author Band Protocol Team\ncontract StdReferenceBasic is AccessControl, StdReferenceBase {\n    struct RefData {\n        uint64 rate; // USD-rate, multiplied by 1e9.\n        uint64 resolveTime; // UNIX epoch when data is last resolved.\n        uint64 requestID; // BandChain request identifier for this data.\n    }\n\n    /// Mapping from token symbol to ref data\n    mapping(string => RefData) public refs;\n\n    bytes32 public constant RELAYER_ROLE = keccak256(\"RELAYER_ROLE\");\n\n    constructor() {\n        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);\n        _grantRole(RELAYER_ROLE, msg.sender);\n    }\n\n    /**\n     * @dev Grants `RELAYER_ROLE` to `accounts`.\n     *\n     * If each `account` had not been already granted `RELAYER_ROLE`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``RELAYER_ROLE``'s admin role.\n     */\n    function grantRelayers(address[] calldata accounts) external onlyRole(getRoleAdmin(RELAYER_ROLE)) {\n        for (uint256 idx = 0; idx < accounts.length; idx++) {\n            _grantRole(RELAYER_ROLE, accounts[idx]);\n        }\n    }\n\n    /**\n     * @dev Revokes `RELAYER_ROLE` from `accounts`.\n     *\n     * If each `account` had already granted `RELAYER_ROLE`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``RELAYER_ROLE``'s admin role.\n     */\n    function revokeRelayers(address[] calldata accounts) external onlyRole(getRoleAdmin(RELAYER_ROLE)) {\n        for (uint256 idx = 0; idx < accounts.length; idx++) {\n            _revokeRole(RELAYER_ROLE, accounts[idx]);\n        }\n    }\n\n    /// @notice Relay and save a set of price data to the contract only if resolveTime is newer\n    /// @dev All of the lists must be of equal length\n    /// @param symbols A list of symbols whose data is being relayed in this function call\n    /// @param rates A list of the rates associated with each symbol\n    /// @param resolveTime A timestamp of when the rate data was retrieved\n    /// @param requestID A BandChain request ID in which the rate data was retrieved\n    function relay(\n        string[] calldata symbols,\n        uint64[] calldata rates,\n        uint64 resolveTime,\n        uint64 requestID\n    ) external {\n        require(hasRole(RELAYER_ROLE, msg.sender), \"NOTARELAYER\");\n        require(rates.length == symbols.length, \"BADRATESLENGTH\");\n        for (uint256 idx = 0; idx < symbols.length; idx++) {\n            RefData storage ref = refs[symbols[idx]];\n            if (resolveTime > ref.resolveTime) {\n                refs[symbols[idx]] = RefData({rate: rates[idx], resolveTime: resolveTime, requestID: requestID});\n            }\n        }\n    }\n\n    /// @notice Relay and save a set of price data to the contract\n    /// @dev All of the lists must be of equal length\n    /// @param symbols A list of symbols whose data is being relayed in this function call\n    /// @param rates A list of the rates associated with each symbol\n    /// @param resolveTime A timestamp of when the rate data was retrieved\n    /// @param requestID A BandChain request ID in which the rate data was retrieved\n    function forceRelay(\n        string[] calldata symbols,\n        uint64[] calldata rates,\n        uint64 resolveTime,\n        uint64 requestID\n    ) external {\n        require(hasRole(RELAYER_ROLE, msg.sender), \"NOTARELAYER\");\n        require(rates.length == symbols.length, \"BADRATESLENGTH\");\n        for (uint256 idx = 0; idx < symbols.length; idx++) {\n            refs[symbols[idx]] = RefData({rate: rates[idx], resolveTime: resolveTime, requestID: requestID});\n        }\n    }\n\n    /// @notice Returns the price data for the given base/quote pair. Revert if not available.\n    /// @param base the base symbol of the token pair to query\n    /// @param quote the quote symbol of the token pair to query\n    function getReferenceData(string memory base, string memory quote) public view override returns (ReferenceData memory) {\n        (uint256 baseRate, uint256 baseLastUpdate) = _getRefData(base);\n        (uint256 quoteRate, uint256 quoteLastUpdate) = _getRefData(quote);\n        return ReferenceData({rate: (baseRate * 1e18) / quoteRate, lastUpdatedBase: baseLastUpdate, lastUpdatedQuote: quoteLastUpdate});\n    }\n\n    /// @notice Get the price data of a token\n    /// @param symbol the symbol of the token whose price to query\n    function _getRefData(string memory symbol) internal view returns (uint256 rate, uint256 lastUpdate) {\n        if (keccak256(bytes(symbol)) == keccak256(bytes(\"USD\"))) {\n            return (1e9, block.timestamp);\n        }\n        RefData storage refData = refs[symbol];\n        require(refData.resolveTime > 0, \"REFDATANOTAVAILABLE\");\n        return (uint256(refData.rate), uint256(refData.resolveTime));\n    }\n}\n"
    },
    "StdReferenceBase.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\npragma solidity 0.8.13;\n\nimport {IStdReference} from \"IStdReference.sol\";\n\nabstract contract StdReferenceBase is IStdReference {\n    function getReferenceData(string memory _base, string memory _quote) public view virtual override returns (ReferenceData memory);\n\n    function getReferenceDataBulk(string[] memory _bases, string[] memory _quotes) public view override returns (ReferenceData[] memory) {\n        require(_bases.length == _quotes.length, \"BAD_INPUT_LENGTH\");\n        uint256 len = _bases.length;\n        ReferenceData[] memory results = new ReferenceData[](len);\n        for (uint256 idx = 0; idx < len; idx++) {\n            results[idx] = getReferenceData(_bases[idx], _quotes[idx]);\n        }\n        return results;\n    }\n}\n"
    },
    "IStdReference.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\npragma solidity 0.8.13;\n\ninterface IStdReference {\n    /// A structure returned whenever someone requests for standard reference data.\n    struct ReferenceData {\n        uint256 rate; // base/quote exchange rate, multiplied by 1e18.\n        uint256 lastUpdatedBase; // UNIX epoch of the last time when base price gets updated.\n        uint256 lastUpdatedQuote; // UNIX epoch of the last time when quote price gets updated.\n    }\n\n    /// Returns the price data for the given base/quote pair. Revert if not available.\n    function getReferenceData(string memory _base, string memory _quote) external view returns (ReferenceData memory);\n\n    /// Similar to getReferenceData, but with multiple base/quote pairs at once.\n    function getReferenceDataBulk(string[] memory _bases, string[] memory _quotes) external view returns (ReferenceData[] memory);\n}\n"
    },
    "AccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IAccessControl.sol\";\nimport \"Context.sol\";\nimport \"Strings.sol\";\nimport \"ERC165.sol\";\n\n/**\n * @dev Contract module that allows children to implement role-based access\n * control mechanisms. This is a lightweight version that doesn't allow enumerating role\n * members except through off-chain means by accessing the contract event logs. Some\n * applications may benefit from on-chain enumerability, for those cases see\n * {AccessControlEnumerable}.\n *\n * Roles are referred to by their `bytes32` identifier. These should be exposed\n * in the external API and be unique. The best way to achieve this is by\n * using `public constant` hash digests:\n *\n * ```\n * bytes32 public constant MY_ROLE = keccak256(\"MY_ROLE\");\n * ```\n *\n * Roles can be used to represent a set of permissions. To restrict access to a\n * function call, use {hasRole}:\n *\n * ```\n * function foo() public {\n *     require(hasRole(MY_ROLE, msg.sender));\n *     ...\n * }\n * ```\n *\n * Roles can be granted and revoked dynamically via the {grantRole} and\n * {revokeRole} functions. Each role has an associated admin role, and only\n * accounts that have a role's admin role can call {grantRole} and {revokeRole}.\n *\n * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means\n * that only accounts with this role will be able to grant or revoke other\n * roles. More complex role relationships can be created by using\n * {_setRoleAdmin}.\n *\n * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to\n * grant and revoke this role. Extra precautions should be taken to secure\n * accounts that have been granted it.\n */\nabstract contract AccessControl is Context, IAccessControl, ERC165 {\n    struct RoleData {\n        mapping(address => bool) members;\n        bytes32 adminRole;\n    }\n\n    mapping(bytes32 => RoleData) private _roles;\n\n    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;\n\n    /**\n     * @dev Modifier that checks that an account has a specific role. Reverts\n     * with a standardized message including the required role.\n     *\n     * The format of the revert reason is given by the following regular expression:\n     *\n     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/\n     *\n     * _Available since v4.1._\n     */\n    modifier onlyRole(bytes32 role) {\n        _checkRole(role, _msgSender());\n        _;\n    }\n\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {\n        return _roles[role].members[account];\n    }\n\n    /**\n     * @dev Revert with a standard message if `account` is missing `role`.\n     *\n     * The format of the revert reason is given by the following regular expression:\n     *\n     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/\n     */\n    function _checkRole(bytes32 role, address account) internal view virtual {\n        if (!hasRole(role, account)) {\n            revert(\n                string(\n                    abi.encodePacked(\n                        \"AccessControl: account \",\n                        Strings.toHexString(uint160(account), 20),\n                        \" is missing role \",\n                        Strings.toHexString(uint256(role), 32)\n                    )\n                )\n            );\n        }\n    }\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {\n        return _roles[role].adminRole;\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been revoked `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) public virtual override {\n        require(account == _msgSender(), \"AccessControl: can only renounce roles for self\");\n\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event. Note that unlike {grantRole}, this function doesn't perform any\n     * checks on the calling account.\n     *\n     * [WARNING]\n     * ====\n     * This function should only be called from the constructor when setting\n     * up the initial roles for the system.\n     *\n     * Using this function in any other way is effectively circumventing the admin\n     * system imposed by {AccessControl}.\n     * ====\n     *\n     * NOTE: This function is deprecated in favor of {_grantRole}.\n     */\n    function _setupRole(bytes32 role, address account) internal virtual {\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Sets `adminRole` as ``role``'s admin role.\n     *\n     * Emits a {RoleAdminChanged} event.\n     */\n    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {\n        bytes32 previousAdminRole = getRoleAdmin(role);\n        _roles[role].adminRole = adminRole;\n        emit RoleAdminChanged(role, previousAdminRole, adminRole);\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * Internal function without access restriction.\n     */\n    function _grantRole(bytes32 role, address account) internal virtual {\n        if (!hasRole(role, account)) {\n            _roles[role].members[account] = true;\n            emit RoleGranted(role, account, _msgSender());\n        }\n    }\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * Internal function without access restriction.\n     */\n    function _revokeRole(bytes32 role, address account) internal virtual {\n        if (hasRole(role, account)) {\n            _roles[role].members[account] = false;\n            emit RoleRevoked(role, account, _msgSender());\n        }\n    }\n}\n"
    },
    "IAccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of AccessControl declared to support ERC165 detection.\n */\ninterface IAccessControl {\n    /**\n     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`\n     *\n     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite\n     * {RoleAdminChanged} not being emitted signaling this.\n     *\n     * _Available since v3.1._\n     */\n    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);\n\n    /**\n     * @dev Emitted when `account` is granted `role`.\n     *\n     * `sender` is the account that originated the contract call, an admin role\n     * bearer except when using {AccessControl-_setupRole}.\n     */\n    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Emitted when `account` is revoked `role`.\n     *\n     * `sender` is the account that originated the contract call:\n     *   - if using `revokeRole`, it is the admin role bearer\n     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)\n     */\n    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) external view returns (bool);\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {AccessControl-_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) external view returns (bytes32);\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been granted `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) external;\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    },
    "ERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"
    },
    "IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "StdReferenceBasic.sol": {}
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