{{
  "language": "Solidity",
  "sources": {
    "ApeUSDLiquidator.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity =0.7.6;\npragma abicoder v2;\n\nimport \"ISwapRouter.sol\";\nimport \"Ownable.sol\";\nimport \"IERC20.sol\";\nimport \"SafeERC20.sol\";\nimport \"ReentrancyGuard.sol\";\n\nimport \"IApeFinance.sol\";\n\ninterface ICurvePool {\n    function coins(uint256 i) external view returns (address);\n    function exchange(int128 i, int128 j, uint256 dx, uint256 min) external returns (uint256);\n}\n\ncontract ApeUSDLiquidator is ReentrancyGuard, Ownable {\n    using SafeERC20 for IERC20;\n\n    ISwapRouter public constant swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);\n    uint24 public constant poolFee03 = 3000; // 0.3%\n    uint24 public constant poolFee005 = 500; // 0.05%\n    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;\n    address public constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;\n\n    ICurvePool public constant curvePool = ICurvePool(0x1977870a4c18a728C19Dd4eB6542451DF06e0A4b);\n\n    IApeFinance public immutable apeAPE;\n    IApeFinance public immutable apeApeUSD;\n    IERC20 public immutable ape;\n    IERC20 public immutable apeUSD;\n\n    constructor(\n        IApeFinance _apeAPE,\n        IApeFinance _apeApeUSD\n    ) {\n        apeAPE = _apeAPE;\n        apeApeUSD = _apeApeUSD;\n\n        ape = IERC20(_apeAPE.underlying());\n        apeUSD = IERC20(_apeApeUSD.underlying());\n    }\n\n    function liquidate(address[] calldata borrower, uint256[] calldata repayAmount, uint256 totalBorrow) external nonReentrant() {\n        apeApeUSD.borrow(payable(address(this)), totalBorrow);\n        apeUSD.approve(address(apeApeUSD), totalBorrow*2);\n\n        for (uint256 i = 0; i < borrower.length; i++) {\n            apeApeUSD.liquidateBorrow(borrower[i], repayAmount[i], address(apeAPE));\n        }\n\n        apeAPE.redeem(payable(address(this)), apeAPE.balanceOf(address(this)), 0);\n        uint256 fraxAmount = swapOnUniswap(ape.balanceOf(address(this)));\n        swapOnCurve(fraxAmount);\n\n        apeApeUSD.repayBorrow(address(this), uint256(-1));\n        uint256 profit = apeUSD.balanceOf(address(this));\n        if (profit > 0) {\n            apeUSD.safeTransfer(owner(), profit);\n        }\n    }\n\n    function swapOnUniswap(uint256 amountIn) internal returns (uint256 amountOut) {\n        ape.approve(address(swapRouter), amountIn);\n\n        ISwapRouter.ExactInputParams memory params =\n            ISwapRouter.ExactInputParams({\n                path: abi.encodePacked(address(ape), poolFee03, WETH9, poolFee005, USDC, poolFee005, FRAX),\n                recipient: address(this),\n                deadline: block.timestamp,\n                amountIn: amountIn,\n                amountOutMinimum: 0\n            });\n\n        amountOut = swapRouter.exactInput(params);\n    }\n\n    function swapOnCurve(uint256 amountIn) internal returns (uint256 amountOut) {\n        IERC20(FRAX).approve(address(curvePool), amountIn);\n\n        if (curvePool.coins(0) == address(FRAX)) {\n            amountOut = curvePool.exchange(0, 1, amountIn, 0);\n        }\n        else {\n            amountOut = curvePool.exchange(1, 0, amountIn, 0);\n        }\n    }\n}\n"
    },
    "ISwapRouter.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.7.5;\npragma abicoder v2;\n\nimport \"IUniswapV3SwapCallback.sol\";\n\n/// @title Router token swapping functionality\n/// @notice Functions for swapping tokens via Uniswap V3\ninterface ISwapRouter is IUniswapV3SwapCallback {\n    struct ExactInputSingleParams {\n        address tokenIn;\n        address tokenOut;\n        uint24 fee;\n        address recipient;\n        uint256 deadline;\n        uint256 amountIn;\n        uint256 amountOutMinimum;\n        uint160 sqrtPriceLimitX96;\n    }\n\n    /// @notice Swaps `amountIn` of one token for as much as possible of another token\n    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata\n    /// @return amountOut The amount of the received token\n    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);\n\n    struct ExactInputParams {\n        bytes path;\n        address recipient;\n        uint256 deadline;\n        uint256 amountIn;\n        uint256 amountOutMinimum;\n    }\n\n    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path\n    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata\n    /// @return amountOut The amount of the received token\n    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);\n\n    struct ExactOutputSingleParams {\n        address tokenIn;\n        address tokenOut;\n        uint24 fee;\n        address recipient;\n        uint256 deadline;\n        uint256 amountOut;\n        uint256 amountInMaximum;\n        uint160 sqrtPriceLimitX96;\n    }\n\n    /// @notice Swaps as little as possible of one token for `amountOut` of another token\n    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata\n    /// @return amountIn The amount of the input token\n    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);\n\n    struct ExactOutputParams {\n        bytes path;\n        address recipient;\n        uint256 deadline;\n        uint256 amountOut;\n        uint256 amountInMaximum;\n    }\n\n    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)\n    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata\n    /// @return amountIn The amount of the input token\n    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);\n}\n"
    },
    "IUniswapV3SwapCallback.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.5.0;\n\n/// @title Callback for IUniswapV3PoolActions#swap\n/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface\ninterface IUniswapV3SwapCallback {\n    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.\n    /// @dev In the implementation you must pay the pool tokens owed for the swap.\n    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.\n    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.\n    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by\n    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.\n    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by\n    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.\n    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call\n    function uniswapV3SwapCallback(\n        int256 amount0Delta,\n        int256 amount1Delta,\n        bytes calldata data\n    ) external;\n}\n"
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () internal {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"IERC20.sol\";\nimport \"SafeMath.sol\";\nimport \"Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using SafeMath for uint256;\n    using Address for address;\n\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        // solhint-disable-next-line max-line-length\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value, \"SafeERC20: decreased allowance below zero\");\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) { // Return data is optional\n            // solhint-disable-next-line max-line-length\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it's recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        uint256 c = a + b;\n        if (c < a) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b > a) return (false, 0);\n        return (true, a - b);\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) return (true, 0);\n        uint256 c = a * b;\n        if (c / a != b) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a / b);\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a % b);\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b <= a, \"SafeMath: subtraction overflow\");\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) return 0;\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryDiv}.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a % b;\n    }\n}\n"
    },
    "Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.2 <0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { size := extcodesize(account) }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\n        (bool success, ) = recipient.call{ value: amount }(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain`call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n      return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.call{ value: value }(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                // solhint-disable-next-line no-inline-assembly\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor () internal {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and make it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n"
    },
    "IApeFinance.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity =0.7.6;\n\ninterface IApeFinance {\n\n    function balanceOf(address account) external view returns (uint256);\n\n    function borrow(address payable borrower, uint256 borrowAmount) external returns (uint256);\n\n    function underlying() external view returns (address);\n\n    function liquidateBorrow(\n        address borrower,\n        uint256 repayAmount,\n        address cTokenCollateral\n    ) external returns (uint256);\n\n    function redeem(\n        address payable redeemer,\n        uint256 redeemTokens,\n        uint256 redeemAmount\n    ) external returns (uint256);\n\n    function repayBorrow(address borrower, uint256 repayAmount)\n        external\n        returns (uint256);\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "ApeUSDLiquidator.sol": {}
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