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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "contracts/Lockable.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity ^0.8.0;\n\n/**\n * @title A contract that provides modifiers to prevent reentrancy to state-changing and view-only methods. This contract\n * is inspired by https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol\n * and https://github.com/balancer-labs/balancer-core/blob/master/contracts/BPool.sol.\n * @dev The reason why we use this local contract instead of importing from uma/contracts is because of the addition\n * of the internal method `functionCallStackOriginatesFromOutsideThisContract` which doesn't exist in the one exported\n * by uma/contracts.\n */\ncontract Lockable {\n    bool internal _notEntered;\n\n    constructor() {\n        // Storing an initial non-zero value makes deployment a bit more expensive, but in exchange the refund on every\n        // call to nonReentrant will be lower in amount. Since refunds are capped to a percentage of the total\n        // transaction's gas, it is best to keep them low in cases like this one, to increase the likelihood of the full\n        // refund coming into effect.\n        _notEntered = true;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a nonReentrant function from another nonReentrant function is not supported. It is possible to\n     * prevent this from happening by making the nonReentrant function external, and making it call a private\n     * function that does the actual state modification.\n     */\n    modifier nonReentrant() {\n        _preEntranceCheck();\n        _preEntranceSet();\n        _;\n        _postEntranceReset();\n    }\n\n    /**\n     * @dev Designed to prevent a view-only method from being re-entered during a call to a nonReentrant() state-changing method.\n     */\n    modifier nonReentrantView() {\n        _preEntranceCheck();\n        _;\n    }\n\n    /**\n     * @dev Returns true if the contract is currently in a non-entered state, meaning that the origination of the call\n     * came from outside the contract. This is relevant with fallback/receive methods to see if the call came from ETH\n     * being dropped onto the contract externally or due to ETH dropped on the the contract from within a method in this\n     * contract, such as unwrapping WETH to ETH within the contract.\n     */\n    function functionCallStackOriginatesFromOutsideThisContract() internal view returns (bool) {\n        return _notEntered;\n    }\n\n    // Internal methods are used to avoid copying the require statement's bytecode to every nonReentrant() method.\n    // On entry into a function, _preEntranceCheck() should always be called to check if the function is being\n    // re-entered. Then, if the function modifies state, it should call _postEntranceSet(), perform its logic, and\n    // then call _postEntranceReset().\n    // View-only methods can simply call _preEntranceCheck() to make sure that it is not being re-entered.\n    function _preEntranceCheck() internal view {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_notEntered, \"ReentrancyGuard: reentrant call\");\n    }\n\n    function _preEntranceSet() internal {\n        // Any calls to nonReentrant after this point will fail\n        _notEntered = false;\n    }\n\n    function _postEntranceReset() internal {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _notEntered = true;\n    }\n}\n"
    },
    "contracts/PolygonTokenBridger.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Lockable.sol\";\r\nimport \"./interfaces/WETH9.sol\";\r\n\r\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\r\nimport \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\r\n\r\n// Polygon Registry contract that stores their addresses.\r\ninterface PolygonRegistry {\r\n    function erc20Predicate() external returns (address);\r\n}\r\n\r\n// Polygon ERC20Predicate contract that handles Plasma exits (only used for Matic).\r\ninterface PolygonERC20Predicate {\r\n    function startExitWithBurntTokens(bytes calldata data) external;\r\n}\r\n\r\n// ERC20s (on polygon) compatible with polygon's bridge have a withdraw method.\r\ninterface PolygonIERC20 is IERC20 {\r\n    function withdraw(uint256 amount) external;\r\n}\r\n\r\ninterface MaticToken {\r\n    function withdraw(uint256 amount) external payable;\r\n}\r\n\r\n/**\r\n * @notice Contract deployed on Ethereum and Polygon to facilitate token transfers from Polygon to the HubPool and back.\r\n * @dev Because Polygon only allows withdrawals from a particular address to go to that same address on mainnet, we need to\r\n * have some sort of contract that can guarantee identical addresses on Polygon and Ethereum. This contract is intended\r\n * to be completely immutable, so it's guaranteed that the contract on each side is  configured identically as long as\r\n * it is created via create2. create2 is an alternative creation method that uses a different address determination\r\n * mechanism from normal create.\r\n * Normal create: address = hash(deployer_address, deployer_nonce)\r\n * create2:       address = hash(0xFF, sender, salt, bytecode)\r\n *  This ultimately allows create2 to generate deterministic addresses that don't depend on the transaction count of the\r\n * sender.\r\n */\r\ncontract PolygonTokenBridger is Lockable {\r\n    using SafeERC20 for PolygonIERC20;\r\n    using SafeERC20 for IERC20;\r\n\r\n    // Gas token for Polygon.\r\n    MaticToken public constant maticToken = MaticToken(0x0000000000000000000000000000000000001010);\r\n\r\n    // Should be set to HubPool on Ethereum, or unused on Polygon.\r\n    address public immutable destination;\r\n\r\n    // Registry that stores L1 polygon addresses.\r\n    PolygonRegistry public immutable l1PolygonRegistry;\r\n\r\n    // WETH contract on Ethereum.\r\n    WETH9 public immutable l1Weth;\r\n\r\n    // Wrapped Matic on Polygon\r\n    address public immutable l2WrappedMatic;\r\n\r\n    // Chain id for the L1 that this contract is deployed on or communicates with.\r\n    // For example: if this contract were meant to facilitate transfers from polygon to mainnet, this value would be\r\n    // the mainnet chainId 1.\r\n    uint256 public immutable l1ChainId;\r\n\r\n    // Chain id for the L2 that this contract is deployed on or communicates with.\r\n    // For example: if this contract were meant to facilitate transfers from polygon to mainnet, this value would be\r\n    // the polygon chainId 137.\r\n    uint256 public immutable l2ChainId;\r\n\r\n    modifier onlyChainId(uint256 chainId) {\r\n        _requireChainId(chainId);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @notice Constructs Token Bridger contract.\r\n     * @param _destination Where to send tokens to for this network.\r\n     * @param _l1PolygonRegistry L1 registry that stores updated addresses of polygon contracts. This should always be\r\n     * set to the L1 registry regardless if whether it's deployed on L2 or L1.\r\n     * @param _l1Weth L1 WETH address.\r\n     * @param _l2WrappedMatic L2 address of wrapped matic token.\r\n     * @param _l1ChainId the chain id for the L1 in this environment.\r\n     * @param _l2ChainId the chain id for the L2 in this environment.\r\n     */\r\n    constructor(\r\n        address _destination,\r\n        PolygonRegistry _l1PolygonRegistry,\r\n        WETH9 _l1Weth,\r\n        address _l2WrappedMatic,\r\n        uint256 _l1ChainId,\r\n        uint256 _l2ChainId\r\n    ) {\r\n        destination = _destination;\r\n        l1PolygonRegistry = _l1PolygonRegistry;\r\n        l1Weth = _l1Weth;\r\n        l2WrappedMatic = _l2WrappedMatic;\r\n        l1ChainId = _l1ChainId;\r\n        l2ChainId = _l2ChainId;\r\n    }\r\n\r\n    /**\r\n     * @notice Called by Polygon SpokePool to send tokens over bridge to contract with the same address as this.\r\n     * @notice The caller of this function must approve this contract to spend amount of token.\r\n     * @param token Token to bridge.\r\n     * @param amount Amount to bridge.\r\n     */\r\n    function send(PolygonIERC20 token, uint256 amount) public nonReentrant onlyChainId(l2ChainId) {\r\n        token.safeTransferFrom(msg.sender, address(this), amount);\r\n\r\n        // In the wMatic case, this unwraps. For other ERC20s, this is the burn/send action.\r\n        token.withdraw(token.balanceOf(address(this)));\r\n\r\n        // This takes the token that was withdrawn and calls withdraw on the \"native\" ERC20.\r\n        if (address(token) == l2WrappedMatic)\r\n            maticToken.withdraw{ value: address(this).balance }(address(this).balance);\r\n    }\r\n\r\n    /**\r\n     * @notice Called by someone to send tokens to the destination, which should be set to the HubPool.\r\n     * @param token Token to send to destination.\r\n     */\r\n    function retrieve(IERC20 token) public nonReentrant onlyChainId(l1ChainId) {\r\n        if (address(token) == address(l1Weth)) {\r\n            // For WETH, there is a pre-deposit step to ensure any ETH that has been sent to the contract is captured.\r\n            l1Weth.deposit{ value: address(this).balance }();\r\n        }\r\n        token.safeTransfer(destination, token.balanceOf(address(this)));\r\n    }\r\n\r\n    /**\r\n     * @notice Called to initiate an l1 exit (withdrawal) of matic tokens that have been sent over the plasma bridge.\r\n     * @param data the proof data to trigger the exit. Can be generated using the maticjs-plasma package.\r\n     */\r\n    function callExit(bytes memory data) public nonReentrant onlyChainId(l1ChainId) {\r\n        PolygonERC20Predicate erc20Predicate = PolygonERC20Predicate(l1PolygonRegistry.erc20Predicate());\r\n        erc20Predicate.startExitWithBurntTokens(data);\r\n    }\r\n\r\n    receive() external payable {\r\n        // This method is empty to avoid any gas expendatures that might cause transfers to fail.\r\n        // Note: the fact that there is _no_ code in this function means that matic can be erroneously transferred in\r\n        // to the contract on the polygon side. These tokens would be locked indefinitely since the receive function\r\n        // cannot be called on the polygon side. While this does have some downsides, the lack of any functionality\r\n        // in this function means that it has no chance of running out of gas on transfers, which is a much more\r\n        // important benefit. This just makes the matic token risk similar to that of ERC20s that are erroneously\r\n        // sent to the contract.\r\n    }\r\n\r\n    function _requireChainId(uint256 chainId) internal view {\r\n        require(block.chainid == chainId, \"Cannot run method on this chain\");\r\n    }\r\n}\r\n"
    },
    "contracts/interfaces/WETH9.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.8.0;\n\ninterface WETH9 {\n    function withdraw(uint256 wad) external;\n\n    function deposit() external payable;\n\n    function balanceOf(address guy) external view returns (uint256 wad);\n\n    function transfer(address guy, uint256 wad) external;\n}\n"
    }
  }
}}