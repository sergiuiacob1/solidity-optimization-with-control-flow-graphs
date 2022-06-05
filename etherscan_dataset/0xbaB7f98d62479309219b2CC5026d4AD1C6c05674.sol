{{
  "language": "Solidity",
  "sources": {
    "OnChainPricingMainnetLenient.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.10;\n\n\nimport {IERC20} from \"IERC20.sol\";\nimport {SafeERC20} from \"SafeERC20.sol\";\n\n\nimport \"IUniswapRouterV2.sol\";\nimport \"ICurveRouter.sol\";\n\n/// @title OnChainPricing\n/// @author Alex the Entreprenerd @ BadgerDAO\n/// @dev Mainnet Version of Price Quoter, hardcoded for more efficiency\n/// @notice To spin a variant, just change the constants and use the Component Functions at the end of the file\n/// @notice Instead of upgrading in the future, just point to a new implementation\n/// @notice This version has 5% extra slippage to allow further flexibility\n///     if the manager abuses the check you should consider reverting back to a more rigorous pricer\ncontract OnChainPricingMainnetLenient {\n\n    struct Quote {\n        string name;\n        uint256 amountOut;\n    }\n    \n    // Assumption #1 Most tokens liquid pair is WETH (WETH is tokenized ETH for that chain)\n    // e.g on Fantom, WETH would be wFTM\n    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n\n    /// == Uni V2 Like Routers || These revert on non-existent pair == //\n    // UniV2\n    address public constant UNIV2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Spookyswap\n    // Sushi\n    address public constant SUSHI_ROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;\n\n    // Curve / Doesn't revert on failure\n    address public constant CURVE_ROUTER = 0x8e764bE4288B842791989DB5b8ec067279829809; // Curve quote and swaps\n\n    // === SLIPPAGE === //\n    // Can change slippage within rational limits\n    address public constant TECH_OPS = 0x86cbD0ce0c087b482782c181dA8d191De18C8275;\n    \n    uint256 private constant MAX_BPS = 10_000;\n\n    uint256 private constant MAX_SLIPPAGE = 500; // 5%\n\n    uint256 public slippage = 200; // 2% Initially\n\n\n    function setSlippage(uint256 newSlippage) external {\n        require(msg.sender == TECH_OPS, \"Only TechOps\");\n        require(newSlippage < MAX_SLIPPAGE);\n        slippage = newSlippage;\n    }\n\n    // === PRICING === //\n\n    /// @dev View function for testing the routing of the strategy\n    function findOptimalSwap(address tokenIn, address tokenOut, uint256 amountIn) external view returns (Quote memory) {\n        uint256 length = 3; // Add length you need\n\n        Quote[] memory quotes = new Quote[](length);\n\n        uint256 curveQuote = getCurvePrice(CURVE_ROUTER, tokenIn, tokenOut, amountIn);\n        quotes[0] = Quote(\"curve\", curveQuote);\n\n        uint256 uniQuote = getUniPrice(UNIV2_ROUTER, tokenIn, tokenOut, amountIn);\n        quotes[1] = Quote(\"uniV2\", uniQuote);\n\n        uint256 sushiQuote = getUniPrice(SUSHI_ROUTER, tokenIn, tokenOut, amountIn);\n        quotes[2] = Quote(\"sushi\", sushiQuote);\n\n\n        /// TODO: Add Balancer and UniV3\n        \n\n        // Because this is a generalized contract, it is best to just loop,\n        // Ideally we have a hierarchy for each chain to save some extra gas, but I think it's ok\n        // O(n) complexity and each check is like 9 gas\n        Quote memory bestQuote = quotes[0];\n        unchecked {\n            for(uint256 x = 1; x < length; ++x) {\n                if(quotes[x].amountOut > bestQuote.amountOut) {\n                    bestQuote = quotes[x];\n                }\n            }\n        }\n\n        bestQuote.amountOut = bestQuote.amountOut * (MAX_BPS - slippage) / MAX_BPS;\n        return bestQuote;\n    }\n    \n\n    /// === Component Functions === /// \n    /// Why bother?\n    /// Because each chain is slightly different but most use similar tech / forks\n    /// May as well use the separate functoions so each OnChain Pricing on different chains will be slightly different\n    /// But ultimately will work in the same way\n\n    /// @dev Given the address of the UniV2Like Router, the input amount, and the path, returns the quote for it\n    function getUniPrice(address router, address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) {\n        address[] memory path = new address[](2);\n        path[0] = address(tokenIn);\n        path[1] = address(tokenOut);\n\n        uint256 quote; //0\n\n\n        // TODO: Consider doing check before revert to avoid paying extra gas\n        // Specifically, test gas if we get revert vs if we check to avoid it\n        try IUniswapRouterV2(router).getAmountsOut(amountIn, path) returns (uint256[] memory amounts) {\n            quote = amounts[amounts.length - 1]; // Last one is the outToken\n        } catch (bytes memory) {\n            // We ignore as it means it's zero\n        }\n\n        return quote;\n    }\n\n    // TODO: Consider adding a `bool` check for `isWeth` to skip the weth check (as it's computed above)\n    // TODO: Most importantly need to run some gas cost tests to ensure we keep at most at like 120k\n\n\n    /// @dev Given the address of the CurveLike Router, the input amount, and the path, returns the quote for it\n    function getCurvePrice(address router, address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) {\n        (, uint256 curveQuote) = ICurveRouter(router).get_best_rate(tokenIn, tokenOut, amountIn);\n\n        return curveQuote;\n    }\n}"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC20.sol\";\nimport \"Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "IUniswapRouterV2.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.5.0;\n\ninterface IUniswapRouterV2 {\n    function factory() external view returns (address);\n\n    function addLiquidity(\n        address tokenA,\n        address tokenB,\n        uint256 amountADesired,\n        uint256 amountBDesired,\n        uint256 amountAMin,\n        uint256 amountBMin,\n        address to,\n        uint256 deadline\n    )\n        external\n        returns (\n            uint256 amountA,\n            uint256 amountB,\n            uint256 liquidity\n        );\n\n    function addLiquidityETH(\n        address token,\n        uint256 amountTokenDesired,\n        uint256 amountTokenMin,\n        uint256 amountETHMin,\n        address to,\n        uint256 deadline\n    )\n        external\n        payable\n        returns (\n            uint256 amountToken,\n            uint256 amountETH,\n            uint256 liquidity\n        );\n\n    function removeLiquidity(\n        address tokenA,\n        address tokenB,\n        uint256 liquidity,\n        uint256 amountAMin,\n        uint256 amountBMin,\n        address to,\n        uint256 deadline\n    ) external returns (uint256 amountA, uint256 amountB);\n\n    function getAmountsOut(uint256 amountIn, address[] calldata path)\n        external\n        view\n        returns (uint256[] memory amounts);\n\n    function getAmountsIn(uint256 amountOut, address[] calldata path)\n        external\n        view\n        returns (uint256[] memory amounts);\n\n    function swapETHForExactTokens(\n        uint256 amountOut,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external payable returns (uint256[] memory amounts);\n\n    function swapExactETHForTokens(\n        uint256 amountOutMin,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external payable returns (uint256[] memory amounts);\n\n    function swapExactTokensForETH(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n\n    function swapTokensForExactETH(\n        uint256 amountOut,\n        uint256 amountInMax,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n\n    function swapExactTokensForTokens(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n\n    function swapTokensForExactTokens(\n        uint256 amountOut,\n        uint256 amountInMax,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n}\n"
    },
    "ICurveRouter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.5.0;\npragma experimental ABIEncoderV2;\n\n\ninterface ICurveRouter {\n  function get_best_rate(\n    address from, address to, uint256 _amount) external view returns (address, uint256);\n  \n  function exchange_with_best_rate(\n    address _from,\n    address _to,\n    uint256 _amount,\n    uint256 _expected\n  ) external returns (uint256);\n}"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
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