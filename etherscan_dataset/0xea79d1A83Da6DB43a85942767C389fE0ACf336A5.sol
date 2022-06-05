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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "contracts/BalancerLocker.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\n\nimport \"./interfaces/VeToken.sol\";\nimport \"./interfaces/GaugeController.sol\";\nimport \"./interfaces/BalancerFeeDistributor.sol\";\n\n/// @title BalancerLocker\n/// @author StakeDAO\n/// @notice Locks the B-80BAL-20WETH tokens to veBAL contract\ncontract BalancerLocker {\n\tusing SafeERC20 for IERC20;\n\n\t/* ========== STATE VARIABLES ========== */\n\taddress public governance;\n\taddress public depositor;\n\taddress public accumulator;\n\n\taddress public constant BALANCER_POOL_TOKEN = address(0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56);\n\taddress public constant veBAL = address(0xC128a9954e6c874eA3d62ce62B468bA073093F25);\n\n\taddress public feeDistributor = address(0x26743984e3357eFC59f2fd6C1aFDC310335a61c9);\n\taddress public gaugeController = address(0xC128468b7Ce63eA702C1f104D55A2566b13D3ABD);\n\n\t/* ========== EVENTS ========== */\n\tevent LockCreated(address indexed user, uint256 value, uint256 duration);\n\tevent TokenClaimed(address indexed user, address token, uint256 value);\n\tevent TokensClaimed(address indexed user, address[] tokens, uint256[] value);\n\tevent VotedOnGaugeWeight(address indexed _gauge, uint256 _weight);\n\tevent Released(address indexed user, uint256 value);\n\tevent GovernanceChanged(address indexed newGovernance);\n\tevent BalancerDepositorChanged(address indexed newDepositor);\n\tevent AccumulatorChanged(address indexed newAccumulator);\n\tevent FeeDistributorChanged(address indexed newFeeDistributor);\n\tevent GaugeControllerChanged(address indexed newGaugeController);\n\n\t/* ========== CONSTRUCTOR ========== */\n\tconstructor(address _accumulator) {\n\t\tgovernance = msg.sender;\n\t\taccumulator = _accumulator;\n\t\tIERC20(BALANCER_POOL_TOKEN).approve(veBAL, type(uint256).max);\n\t}\n\n\t/* ========== MODIFIERS ========== */\n\tmodifier onlyGovernance() {\n\t\trequire(msg.sender == governance, \"!gov\");\n\t\t_;\n\t}\n\n\tmodifier onlyGovernanceOrAcc() {\n\t\trequire(msg.sender == governance || msg.sender == accumulator, \"!(gov||acc)\");\n\t\t_;\n\t}\n\n\tmodifier onlyGovernanceOrDepositor() {\n\t\trequire(msg.sender == governance || msg.sender == depositor, \"!(gov||Depositor)\");\n\t\t_;\n\t}\n\n\t/* ========== MUTATIVE FUNCTIONS ========== */\n\t/// @notice Creates a lock by locking BALANCER_POOL_TOKEN token in the veBAL contract for the specified time\n\t/// @dev Can only be called by governance or proxy\n\t/// @param _value The amount of token to be locked\n\t/// @param _unlockTime The duration for which the token is to be locked\n\tfunction createLock(uint256 _value, uint256 _unlockTime) external onlyGovernance {\n\t\tVeToken(veBAL).create_lock(_value, _unlockTime);\n\t\temit LockCreated(msg.sender, _value, _unlockTime);\n\t}\n\n\t/// @notice Increases the amount of BALANCER_POOL_TOKEN locked in veBAL\n\t/// @dev The BALANCER_POOL_TOKEN needs to be transferred to this contract before calling\n\t/// @param _value The amount by which the lock amount is to be increased\n\tfunction increaseAmount(uint256 _value) external onlyGovernanceOrDepositor {\n\t\tVeToken(veBAL).increase_amount(_value);\n\t}\n\n\t/// @notice Increases the duration for which BALANCER_POOL_TOKEN is locked in veBAL for the user calling the function\n\t/// @param _unlockTime The duration in seconds for which the token is to be locked\n\tfunction increaseUnlockTime(uint256 _unlockTime) external onlyGovernanceOrDepositor {\n\t\tVeToken(veBAL).increase_unlock_time(_unlockTime);\n\t}\n\n\t/// @notice Claim the token reward from the BALANCER_POOL_TOKEN fee Distributor passing the token as input parameter\n\t/// @param _recipient The address which will receive the claimed token reward\n\tfunction claimRewards(address _token, address _recipient) external onlyGovernanceOrAcc {\n\t\tuint256 claimed = BalancerFeeDistributor(feeDistributor).claimToken(address(this), _token);\n\t\temit TokenClaimed(_recipient, _token, claimed);\n\t\tIERC20(_token).safeTransfer(_recipient,  claimed);\n\t}\n\n\tfunction claimAllRewards(address[] calldata _tokens, address _recipient) external onlyGovernanceOrAcc {\n\t\tuint256[] memory claimed = BalancerFeeDistributor(feeDistributor).claimTokens(address(this), _tokens);\n\t\tuint length = _tokens.length;\n\t\tfor(uint i; i < length; ++i){\n\t\t\tIERC20(_tokens[i]).safeTransfer(_recipient, claimed[i]);\n\t\t}\n\t\temit TokensClaimed(_recipient, _tokens,  claimed);\n\t}\n\n\t/// @notice Withdraw the BALANCER_POOL_TOKEN from veBAL\n\t/// @dev call only after lock time expires\n\t/// @param _recipient The address which will receive the released BALANCER_POOL_TOKEN\n\tfunction release(address _recipient) external onlyGovernance {\n\t\tVeToken(veBAL).withdraw();\n\t\tuint256 balance = IERC20(BALANCER_POOL_TOKEN).balanceOf(address(this));\n\n\t\tIERC20(BALANCER_POOL_TOKEN).safeTransfer(_recipient, balance);\n\t\temit Released(_recipient, balance);\n\t}\n\n\t/// @notice Vote on Balancer Gauge Controller for a gauge with a given weight\n\t/// @param _gauge The gauge address to vote for\n\t/// @param _weight The weight with which to vote\n\tfunction voteGaugeWeight(address _gauge, uint256 _weight) external onlyGovernance {\n\t\tGaugeController(gaugeController).vote_for_gauge_weights(_gauge, _weight);\n\t\temit VotedOnGaugeWeight(_gauge, _weight);\n\t}\n\n\t/// @notice Set new governance address \n\t/// @param _governance governance address \n\tfunction setGovernance(address _governance) external onlyGovernance {\n\t\tgovernance = _governance;\n\t\temit GovernanceChanged(_governance);\n\t}\n\n\t/// @notice Set the Balancer Depositor\n\t/// @param _depositor BALANCER_POOL_TOKEN deppositor address\n\tfunction setDepositor(address _depositor) external onlyGovernance {\n\t\tdepositor = _depositor;\n\t\temit BalancerDepositorChanged(_depositor);\n\t}\n\n\t/// @notice Set the fee distributor \n\t/// @param _newFD fee distributor address\n\tfunction setFeeDistributor(address _newFD) external onlyGovernance {\n\t\tfeeDistributor = _newFD;\n\t\temit FeeDistributorChanged(_newFD);\n\t}\n\n\t/// @notice Set the gauge controller\n\t/// @param _gaugeController gauge controller address \n\tfunction setGaugeController(address _gaugeController) external onlyGovernance {\n\t\tgaugeController = _gaugeController;\n\t\temit GaugeControllerChanged(_gaugeController);\n\t}\n\n\t/// @notice Set the accumulator\n\t/// @param _accumulator accumulator address\n\tfunction setAccumulator(address _accumulator) external onlyGovernance {\n\t\taccumulator = _accumulator;\n\t\temit AccumulatorChanged(_accumulator);\n\t}\n\n\t/// @notice execute a function\n\t/// @param to Address to sent the value to\n\t/// @param value Value to be sent\n\t/// @param data Call function data\n\tfunction execute(\n\t\taddress to,\n\t\tuint256 value,\n\t\tbytes calldata data\n\t) external onlyGovernance returns (bool, bytes memory) {\n\t\t(bool success, bytes memory result) = to.call{ value: value }(data);\n\t\treturn (success, result);\n\t}\n}"
    },
    "contracts/interfaces/BalancerFeeDistributor.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\ninterface BalancerFeeDistributor {\n    /// @notice Claims all pending distributions of the provided token for a user.\n    /// @dev It's not necessary to explicitly checkpoint before calling this function, it will ensure the FeeDistributor\n    /// is up to date before calculating the amount of tokens to be claimed.\n    /// @param user - The user on behalf of which to claim.\n    /// @param token - The ERC20 token address to be claimed.\n    /// @return The amount of `token` sent to `user` as a result of claiming.\n    function claimToken(address user, address token) external returns (uint256);\n\n    /// @notice Claims a number of tokens on behalf of a user.\n    /// @dev A version of `claimToken` which supports claiming multiple `tokens` on behalf of `user`.\n    /// See `claimToken` for more details.\n    /// @param user - The user on behalf of which to claim.\n    /// @param tokens - An array of ERC20 token addresses to be claimed.\n    /// @return An array of the amounts of each token in `tokens` sent to `user` as a result of claiming.\n    function claimTokens(address user, address[] calldata tokens) external returns (uint256[] memory);\n}\n"
    },
    "contracts/interfaces/GaugeController.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\ninterface GaugeController {\n\tfunction vote_for_gauge_weights(address, uint256) external;\n\n\tfunction vote(\n\t\tuint256,\n\t\tbool,\n\t\tbool\n\t) external; //voteId, support, executeIfDecided\n}\n"
    },
    "contracts/interfaces/VeToken.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\ninterface VeToken {\n\tstruct LockedBalance {\n\t\tint128 amount;\n\t\tuint256 end;\n\t}\n\n\tfunction create_lock(uint256 _value, uint256 _unlock_time) external;\n\n\tfunction increase_amount(uint256 _value) external;\n\n\tfunction increase_unlock_time(uint256 _unlock_time) external;\n\n\tfunction withdraw() external;\n}\n"
    }
  }
}}