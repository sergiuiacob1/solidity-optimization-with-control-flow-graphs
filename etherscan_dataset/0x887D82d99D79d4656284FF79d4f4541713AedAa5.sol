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
    "@eth-optimism/contracts/L1/messaging/IL1ERC20Bridge.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.9.0;\n\n/**\n * @title IL1ERC20Bridge\n */\ninterface IL1ERC20Bridge {\n    /**********\n     * Events *\n     **********/\n\n    event ERC20DepositInitiated(\n        address indexed _l1Token,\n        address indexed _l2Token,\n        address indexed _from,\n        address _to,\n        uint256 _amount,\n        bytes _data\n    );\n\n    event ERC20WithdrawalFinalized(\n        address indexed _l1Token,\n        address indexed _l2Token,\n        address indexed _from,\n        address _to,\n        uint256 _amount,\n        bytes _data\n    );\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    /**\n     * @dev get the address of the corresponding L2 bridge contract.\n     * @return Address of the corresponding L2 bridge contract.\n     */\n    function l2TokenBridge() external returns (address);\n\n    /**\n     * @dev deposit an amount of the ERC20 to the caller's balance on L2.\n     * @param _l1Token Address of the L1 ERC20 we are depositing\n     * @param _l2Token Address of the L1 respective L2 ERC20\n     * @param _amount Amount of the ERC20 to deposit\n     * @param _l2Gas Gas limit required to complete the deposit on L2.\n     * @param _data Optional data to forward to L2. This data is provided\n     *        solely as a convenience for external contracts. Aside from enforcing a maximum\n     *        length, these contracts provide no guarantees about its content.\n     */\n    function depositERC20(\n        address _l1Token,\n        address _l2Token,\n        uint256 _amount,\n        uint32 _l2Gas,\n        bytes calldata _data\n    ) external;\n\n    /**\n     * @dev deposit an amount of ERC20 to a recipient's balance on L2.\n     * @param _l1Token Address of the L1 ERC20 we are depositing\n     * @param _l2Token Address of the L1 respective L2 ERC20\n     * @param _to L2 address to credit the withdrawal to.\n     * @param _amount Amount of the ERC20 to deposit.\n     * @param _l2Gas Gas limit required to complete the deposit on L2.\n     * @param _data Optional data to forward to L2. This data is provided\n     *        solely as a convenience for external contracts. Aside from enforcing a maximum\n     *        length, these contracts provide no guarantees about its content.\n     */\n    function depositERC20To(\n        address _l1Token,\n        address _l2Token,\n        address _to,\n        uint256 _amount,\n        uint32 _l2Gas,\n        bytes calldata _data\n    ) external;\n\n    /*************************\n     * Cross-chain Functions *\n     *************************/\n\n    /**\n     * @dev Complete a withdrawal from L2 to L1, and credit funds to the recipient's balance of the\n     * L1 ERC20 token.\n     * This call will fail if the initialized withdrawal from L2 has not been finalized.\n     *\n     * @param _l1Token Address of L1 token to finalizeWithdrawal for.\n     * @param _l2Token Address of L2 token where withdrawal was initiated.\n     * @param _from L2 address initiating the transfer.\n     * @param _to L1 address to credit the withdrawal to.\n     * @param _amount Amount of the ERC20 to deposit.\n     * @param _data Data provided by the sender on L2. This data is provided\n     *   solely as a convenience for external contracts. Aside from enforcing a maximum\n     *   length, these contracts provide no guarantees about its content.\n     */\n    function finalizeERC20Withdrawal(\n        address _l1Token,\n        address _l2Token,\n        address _from,\n        address _to,\n        uint256 _amount,\n        bytes calldata _data\n    ) external;\n}\n"
    },
    "@eth-optimism/contracts/L1/messaging/IL1StandardBridge.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.9.0;\n\nimport \"./IL1ERC20Bridge.sol\";\n\n/**\n * @title IL1StandardBridge\n */\ninterface IL1StandardBridge is IL1ERC20Bridge {\n    /**********\n     * Events *\n     **********/\n    event ETHDepositInitiated(\n        address indexed _from,\n        address indexed _to,\n        uint256 _amount,\n        bytes _data\n    );\n\n    event ETHWithdrawalFinalized(\n        address indexed _from,\n        address indexed _to,\n        uint256 _amount,\n        bytes _data\n    );\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    /**\n     * @dev Deposit an amount of the ETH to the caller's balance on L2.\n     * @param _l2Gas Gas limit required to complete the deposit on L2.\n     * @param _data Optional data to forward to L2. This data is provided\n     *        solely as a convenience for external contracts. Aside from enforcing a maximum\n     *        length, these contracts provide no guarantees about its content.\n     */\n    function depositETH(uint32 _l2Gas, bytes calldata _data) external payable;\n\n    /**\n     * @dev Deposit an amount of ETH to a recipient's balance on L2.\n     * @param _to L2 address to credit the withdrawal to.\n     * @param _l2Gas Gas limit required to complete the deposit on L2.\n     * @param _data Optional data to forward to L2. This data is provided\n     *        solely as a convenience for external contracts. Aside from enforcing a maximum\n     *        length, these contracts provide no guarantees about its content.\n     */\n    function depositETHTo(\n        address _to,\n        uint32 _l2Gas,\n        bytes calldata _data\n    ) external payable;\n\n    /*************************\n     * Cross-chain Functions *\n     *************************/\n\n    /**\n     * @dev Complete a withdrawal from L2 to L1, and credit funds to the recipient's balance of the\n     * L1 ETH token. Since only the xDomainMessenger can call this function, it will never be called\n     * before the withdrawal is finalized.\n     * @param _from L2 address initiating the transfer.\n     * @param _to L1 address to credit the withdrawal to.\n     * @param _amount Amount of the ERC20 to deposit.\n     * @param _data Optional data to forward to L2. This data is provided\n     *        solely as a convenience for external contracts. Aside from enforcing a maximum\n     *        length, these contracts provide no guarantees about its content.\n     */\n    function finalizeETHWithdrawal(\n        address _from,\n        address _to,\n        uint256 _amount,\n        bytes calldata _data\n    ) external;\n}\n"
    },
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.9.0;\n\n/**\n * @title ICrossDomainMessenger\n */\ninterface ICrossDomainMessenger {\n    /**********\n     * Events *\n     **********/\n\n    event SentMessage(\n        address indexed target,\n        address sender,\n        bytes message,\n        uint256 messageNonce,\n        uint256 gasLimit\n    );\n    event RelayedMessage(bytes32 indexed msgHash);\n    event FailedRelayedMessage(bytes32 indexed msgHash);\n\n    /*************\n     * Variables *\n     *************/\n\n    function xDomainMessageSender() external view returns (address);\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    /**\n     * Sends a cross domain message to the target messenger.\n     * @param _target Target contract address.\n     * @param _message Message to send to the target.\n     * @param _gasLimit Gas limit for the provided message.\n     */\n    function sendMessage(\n        address _target,\n        bytes calldata _message,\n        uint32 _gasLimit\n    ) external;\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "contracts/chain-adapters/CrossDomainEnabled.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/* Interface Imports */\nimport { ICrossDomainMessenger } from \"@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol\";\n\n/**\n * @title CrossDomainEnabled\n * @dev Helper contract for contracts performing cross-domain communications between L1 and Optimism.\n * @dev This modifies the eth-optimism/CrossDomainEnabled contract only by changing state variables to be\n * immutable for use in contracts like the Optimism_Adapter which use delegateCall().\n */\ncontract CrossDomainEnabled {\n    // Messenger contract used to send and recieve messages from the other domain.\n    address public immutable messenger;\n\n    /**\n     * @param _messenger Address of the CrossDomainMessenger on the current layer.\n     */\n    constructor(address _messenger) {\n        messenger = _messenger;\n    }\n\n    /**\n     * Enforces that the modified function is only callable by a specific cross-domain account.\n     * @param _sourceDomainAccount The only account on the originating domain which is\n     *  authenticated to call this function.\n     */\n    modifier onlyFromCrossDomainAccount(address _sourceDomainAccount) {\n        require(msg.sender == address(getCrossDomainMessenger()), \"invalid cross domain messenger\");\n\n        require(\n            getCrossDomainMessenger().xDomainMessageSender() == _sourceDomainAccount,\n            \"invalid cross domain sender\"\n        );\n\n        _;\n    }\n\n    /**\n     * Gets the messenger, usually from storage. This function is exposed in case a child contract\n     * needs to override.\n     * @return The address of the cross-domain messenger contract which should be used.\n     */\n    function getCrossDomainMessenger() internal virtual returns (ICrossDomainMessenger) {\n        return ICrossDomainMessenger(messenger);\n    }\n\n    /**\n     * Sends a message to an account on another domain\n     * @param _crossDomainTarget The intended recipient on the destination domain\n     * @param _message The data to send to the target (usually calldata to a function with\n     *  onlyFromCrossDomainAccount())\n     * @param _gasLimit The gasLimit for the receipt of the message on the target domain.\n     */\n    function sendCrossDomainMessage(\n        address _crossDomainTarget,\n        uint32 _gasLimit,\n        bytes calldata _message\n    ) internal {\n        // slither-disable-next-line reentrancy-events, reentrancy-benign\n        getCrossDomainMessenger().sendMessage(_crossDomainTarget, _message, _gasLimit);\n    }\n}\n"
    },
    "contracts/chain-adapters/Optimism_Adapter.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity ^0.8.0;\n\nimport \"../interfaces/AdapterInterface.sol\";\nimport \"../interfaces/WETH9.sol\";\n\n// @dev Use local modified CrossDomainEnabled contract instead of one exported by eth-optimism because we need\n// this contract's state variables to be `immutable` because of the delegateCall call.\nimport \"./CrossDomainEnabled.sol\";\nimport \"@eth-optimism/contracts/L1/messaging/IL1StandardBridge.sol\";\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\n\n/**\n * @notice Contract containing logic to send messages from L1 to Optimism.\n * @dev Public functions calling external contracts do not guard against reentrancy because they are expected to be\n * called via delegatecall, which will execute this contract's logic within the context of the originating contract.\n * For example, the HubPool will delegatecall these functions, therefore its only necessary that the HubPool's methods\n * that call this contract's logic guard against reentrancy.\n */\n\n// solhint-disable-next-line contract-name-camelcase\ncontract Optimism_Adapter is CrossDomainEnabled, AdapterInterface {\n    using SafeERC20 for IERC20;\n    uint32 public immutable l2GasLimit = 2_000_000;\n\n    WETH9 public immutable l1Weth;\n\n    IL1StandardBridge public immutable l1StandardBridge;\n\n    // Optimism has the ability to support \"custom\" bridges. These bridges are not supported by the canonical bridge\n    // and so we need to store the address of the custom token and the associated bridge. In the event we want to\n    // support a new token that is not supported by Optimism, we can add a new custom bridge for it and re-deploy the\n    // adapter. A full list of custom optimism tokens and their associated bridges can be found here:\n    // https://github.com/ethereum-optimism/ethereum-optimism.github.io/blob/master/optimism.tokenlist.json\n    address public immutable dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;\n    address public immutable daiOptimismBridge = 0x10E6593CDda8c58a1d0f14C5164B376352a55f2F;\n    address public immutable snx = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;\n    address public immutable snxOptimismBridge = 0x39Ea01a0298C315d149a490E34B59Dbf2EC7e48F;\n\n    /**\n     * @notice Constructs new Adapter.\n     * @param _l1Weth WETH address on L1.\n     * @param _crossDomainMessenger XDomainMessenger Optimism system contract.\n     * @param _l1StandardBridge Standard bridge contract.\n     */\n    constructor(\n        WETH9 _l1Weth,\n        address _crossDomainMessenger,\n        IL1StandardBridge _l1StandardBridge\n    ) CrossDomainEnabled(_crossDomainMessenger) {\n        l1Weth = _l1Weth;\n        l1StandardBridge = _l1StandardBridge;\n    }\n\n    /**\n     * @notice Send cross-chain message to target on Optimism.\n     * @param target Contract on Optimism that will receive message.\n     * @param message Data to send to target.\n     */\n    function relayMessage(address target, bytes calldata message) external payable override {\n        sendCrossDomainMessage(target, uint32(l2GasLimit), message);\n        emit MessageRelayed(target, message);\n    }\n\n    /**\n     * @notice Bridge tokens to Optimism.\n     * @param l1Token L1 token to deposit.\n     * @param l2Token L2 token to receive.\n     * @param amount Amount of L1 tokens to deposit and L2 tokens to receive.\n     * @param to Bridge recipient.\n     */\n    function relayTokens(\n        address l1Token,\n        address l2Token,\n        uint256 amount,\n        address to\n    ) external payable override {\n        // If the l1Token is weth then unwrap it to ETH then send the ETH to the standard bridge.\n        if (l1Token == address(l1Weth)) {\n            l1Weth.withdraw(amount);\n            l1StandardBridge.depositETHTo{ value: amount }(to, l2GasLimit, \"\");\n        } else {\n            IL1StandardBridge _l1StandardBridge = l1StandardBridge;\n\n            // Check if the L1 token requires a custom bridge. If so, use that bridge over the standard bridge.\n            if (l1Token == dai) _l1StandardBridge = IL1StandardBridge(daiOptimismBridge); // 1. DAI\n            if (l1Token == snx) _l1StandardBridge = IL1StandardBridge(snxOptimismBridge); // 2. SNX\n\n            IERC20(l1Token).safeIncreaseAllowance(address(_l1StandardBridge), amount);\n            _l1StandardBridge.depositERC20To(l1Token, l2Token, to, amount, l2GasLimit, \"\");\n        }\n        emit TokensRelayed(l1Token, l2Token, amount, to);\n    }\n}\n"
    },
    "contracts/interfaces/AdapterInterface.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity ^0.8.0;\n\n/**\n * @notice Sends cross chain messages and tokens to contracts on a specific L2 network.\n */\n\ninterface AdapterInterface {\n    event MessageRelayed(address target, bytes message);\n\n    event TokensRelayed(address l1Token, address l2Token, uint256 amount, address to);\n\n    function relayMessage(address target, bytes calldata message) external payable;\n\n    function relayTokens(\n        address l1Token,\n        address l2Token,\n        uint256 amount,\n        address to\n    ) external payable;\n}\n"
    },
    "contracts/interfaces/WETH9.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.8.0;\n\ninterface WETH9 {\n    function withdraw(uint256 wad) external;\n\n    function deposit() external payable;\n\n    function balanceOf(address guy) external view returns (uint256 wad);\n\n    function transfer(address guy, uint256 wad) external;\n}\n"
    }
  }
}}