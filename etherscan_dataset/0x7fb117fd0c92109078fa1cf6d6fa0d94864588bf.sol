{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}\r\n"},"DNF_ICO.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\nimport \"./IERC20Metadata.sol\";\r\nimport \"./Ownable.sol\";\r\nimport \"./SafeMath.sol\";\r\n\r\npragma solidity ^0.8.7;\r\n\r\ncontract DNF_ICO is Ownable {\r\n    using SafeMath for uint256;\r\n\r\n    // IERC20 tokenContract = IERC20(address(0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E));\r\n    address public tokenAddress =\r\n        address(0x47D1D10c2A15259b1fed015A6c15740e3303d2f3);\r\n    IERC20Metadata tokenContract = IERC20Metadata(tokenAddress);\r\n    address public fundCollector =\r\n        address(0xF533169233f69e0aC126886cA41cA2a2272C7037);\r\n    mapping(address =\u003e uint256) public contributedAmount;\r\n\r\n    uint256 public minContribution = 200 * 10**6;\r\n    uint256 public maxContribution = 2000 * 10**6;\r\n    uint256 public totalContribution = 0;\r\n    uint256 public maxCap = 40000 * 10**6;\r\n\r\n    bool public isFinalized = false;\r\n\r\n    event Contribute(address indexed _contributor);\r\n\r\n    function contribute(uint256 amount) public {\r\n        require(\r\n            add256(contributedAmount[msg.sender], amount) \u003c= maxContribution,\r\n            \"CONTRIBUTION AMOUNT EXCEEDS MAX__TOTALCONTRIBUTION\"\r\n        );\r\n        require(\r\n            add256(contributedAmount[msg.sender], amount) \u003e= minContribution,\r\n            \"MIN_CONTRIBUTION IS NOT FULLFILLED\"\r\n        );\r\n        require(add256(totalContribution, amount) \u003c maxCap, \"EXCEEDS MAX_CAP\");\r\n        require(!isFinalized, \"PRESALE IS FINALIZED\");\r\n        require(\r\n            tokenContract.allowance(msg.sender, address(this)) \u003e= amount,\r\n            \"Allowance Error\"\r\n        );\r\n        tokenContract.transferFrom(msg.sender, address(this), amount);\r\n        if (contributedAmount[msg.sender] == 0) emit Contribute(msg.sender);\r\n        contributedAmount[msg.sender] = add256(\r\n            contributedAmount[msg.sender],\r\n            amount\r\n        );\r\n        totalContribution = add256(totalContribution, amount);\r\n        if (add256(totalContribution, minContribution) \u003e maxCap) {\r\n            isFinalized = true;\r\n        }\r\n    }\r\n\r\n    function tokenBalance() public view returns (uint256) {\r\n        return tokenContract.balanceOf(address(this));\r\n    }\r\n\r\n    function withdrawFunds() public onlyOwner {\r\n        uint256 balance = tokenContract.balanceOf(address(this));\r\n        require(balance \u003e 0);\r\n        tokenContract.transfer(fundCollector, balance);\r\n    }\r\n\r\n    function finalizePresale() public onlyOwner {\r\n        isFinalized = true;\r\n    }\r\n\r\n    function resumePresale() public onlyOwner {\r\n        isFinalized = false;\r\n    }\r\n\r\n    function updateTokenAddress(address _tokenAddress) external onlyOwner {\r\n        tokenAddress = _tokenAddress;\r\n        tokenContract = IERC20Metadata(tokenAddress);\r\n    }\r\n\r\n    function updateFundCollector(address _fundCollector) external onlyOwner {\r\n        fundCollector = _fundCollector;\r\n    }\r\n\r\n    function updateMaxCap(uint256 _maxCap) public onlyOwner {\r\n        maxCap = _maxCap * 10**6;\r\n    }\r\n\r\n    function updateMinContribution(uint256 _minContribution) public onlyOwner {\r\n        require(\r\n            _minContribution \u003e 0,\r\n            \"MIN CONTRIBUTION CANNOT BE LOWER OR EQUAL TO 0\"\r\n        );\r\n        require(\r\n            _minContribution \u003c maxContribution,\r\n            \"MIN CONTRIBUTION CANNOT BE HIGHER OR EQUAL THAN MAX CONTRIBUTION\"\r\n        );\r\n        minContribution = _minContribution * 10**6;\r\n    }\r\n\r\n    function updateMaxContribution(uint256 _maxContribution) public onlyOwner {\r\n        require(\r\n            _maxContribution \u003e minContribution,\r\n            \"MAX CONTRIBUTION CANNOT BE LOWER OR EQUAL THAN MIN CONTRIBUTION\"\r\n        );\r\n        maxContribution = _maxContribution * 10**6;\r\n    }\r\n\r\n    function add256(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"addition overflow\");\r\n        return c;\r\n    }\r\n}\r\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n/**\r\n *Submitted for verification at snowtrace.io on 2022-05-18\r\n */\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address to, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `from` to `to` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) external returns (bool);\r\n}\r\n"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\r\n/**\r\n *Submitted for verification at snowtrace.io on 2022-05-18\r\n */\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Interface for the optional metadata functions from the ERC20 standard.\r\n *\r\n * _Available since v4.1._\r\n */\r\nimport \"./IERC20.sol\";\r\n\r\ninterface IERC20Metadata is IERC20 {\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token.\r\n     */\r\n    function symbol() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the decimals places of the token.\r\n     */\r\n    function decimals() external view returns (uint8);\r\n}\r\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\nimport \"./Context.sol\";\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(\r\n        address indexed previousOwner,\r\n        address indexed newOwner\r\n    );\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor() {\r\n        _transferOwnership(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(\r\n            newOwner != address(0),\r\n            \"Ownable: new owner is the zero address\"\r\n        );\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}\r\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n// CAUTION\r\n// This version of SafeMath should only be used with Solidity 0.8 or later,\r\n// because it relies on the compiler\u0027s built in overflow checks.\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\r\n *\r\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\r\n * now has built in overflow checking.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryAdd(uint256 a, uint256 b)\r\n        internal\r\n        pure\r\n        returns (bool, uint256)\r\n    {\r\n        unchecked {\r\n            uint256 c = a + b;\r\n            if (c \u003c a) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function trySub(uint256 a, uint256 b)\r\n        internal\r\n        pure\r\n        returns (bool, uint256)\r\n    {\r\n        unchecked {\r\n            if (b \u003e a) return (false, 0);\r\n            return (true, a - b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMul(uint256 a, uint256 b)\r\n        internal\r\n        pure\r\n        returns (bool, uint256)\r\n    {\r\n        unchecked {\r\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n            // benefit is lost if \u0027b\u0027 is also tested.\r\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n            if (a == 0) return (true, 0);\r\n            uint256 c = a * b;\r\n            if (c / a != b) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryDiv(uint256 a, uint256 b)\r\n        internal\r\n        pure\r\n        returns (bool, uint256)\r\n    {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a / b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMod(uint256 a, uint256 b)\r\n        internal\r\n        pure\r\n        returns (bool, uint256)\r\n    {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a % b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a + b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a * b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a / b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a % b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {trySub}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003c= a, errorMessage);\r\n            return a - b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a / b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting with custom message when dividing by zero.\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {tryMod}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a % b;\r\n        }\r\n    }\r\n}\r\n"}}