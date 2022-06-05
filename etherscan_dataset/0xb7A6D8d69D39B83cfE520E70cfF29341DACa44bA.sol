{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
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
    "contracts/ape-finance/InterestRateModel.sol": {
      "content": "pragma solidity ^0.5.16;\n\n/**\n * @title ApeFinance's InterestRateModel Interface\n */\ncontract InterestRateModel {\n    /// @notice Indicator that this is an InterestRateModel contract (for inspection)\n    bool public constant isInterestRateModel = true;\n\n    /**\n     * @notice Calculates the current borrow interest rate per block\n     * @param cash The total amount of cash the market has\n     * @param borrows The total amount of borrows the market has outstanding\n     * @param reserves The total amnount of reserves the market has\n     * @return The borrow rate per block (as a percentage, and scaled by 1e18)\n     */\n    function getBorrowRate(\n        uint256 cash,\n        uint256 borrows,\n        uint256 reserves\n    ) external view returns (uint256);\n\n    /**\n     * @notice Calculates the current supply interest rate per block\n     * @param cash The total amount of cash the market has\n     * @param borrows The total amount of borrows the market has outstanding\n     * @param reserves The total amnount of reserves the market has\n     * @param reserveFactorMantissa The current reserve factor the market has\n     * @return The supply rate per block (as a percentage, and scaled by 1e18)\n     */\n    function getSupplyRate(\n        uint256 cash,\n        uint256 borrows,\n        uint256 reserves,\n        uint256 reserveFactorMantissa\n    ) external view returns (uint256);\n}\n"
    },
    "contracts/ape-finance/SafeMath.sol": {
      "content": "pragma solidity ^0.5.16;\n\n// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol\n// Subject to the MIT license.\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it's recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, errorMessage);\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot underflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction underflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot underflow.\n     */\n    function sub(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, errorMessage);\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers.\n     * Reverts on division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers.\n     * Reverts with custom message on division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b > 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn't hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n"
    },
    "contracts/ape-finance/TripleSlopeRateModel.sol": {
      "content": "pragma solidity ^0.5.16;\n\nimport \"./InterestRateModel.sol\";\nimport \"./SafeMath.sol\";\n\n/**\n * @title ApeFinance's TripleSlopeRateModel Contract\n */\ncontract TripleSlopeRateModel is InterestRateModel {\n    using SafeMath for uint256;\n\n    event NewInterestParams(\n        uint256 baseRatePerBlock,\n        uint256 multiplierPerBlock,\n        uint256 jumpMultiplierPerBlock,\n        uint256 kink1,\n        uint256 kink2,\n        uint256 roof\n    );\n\n    /**\n     * @notice The address of the owner, i.e. the Timelock contract, which can update parameters directly\n     */\n    address public owner;\n\n    /**\n     * @notice The approximate number of blocks per year that is assumed by the interest rate model\n     */\n    uint256 public constant blocksPerYear = 2102400;\n\n    /**\n     * @notice The minimum roof value used for calculating borrow rate.\n     */\n    uint256 internal constant minRoofValue = 1e18;\n\n    /**\n     * @notice The multiplier of utilization rate that gives the slope of the interest rate\n     */\n    uint256 public multiplierPerBlock;\n\n    /**\n     * @notice The base interest rate which is the y-intercept when utilization rate is 0\n     */\n    uint256 public baseRatePerBlock;\n\n    /**\n     * @notice The multiplierPerBlock after hitting a specified utilization point\n     */\n    uint256 public jumpMultiplierPerBlock;\n\n    /**\n     * @notice The utilization point at which the interest rate is fixed\n     */\n    uint256 public kink1;\n\n    /**\n     * @notice The utilization point at which the jump multiplier is applied\n     */\n    uint256 public kink2;\n\n    /**\n     * @notice The utilization point at which the rate is fixed\n     */\n    uint256 public roof;\n\n    /**\n     * @notice Construct an interest rate model\n     * @param baseRatePerYear The approximate target base APR, as a mantissa (scaled by 1e18)\n     * @param multiplierPerYear The rate of increase in interest rate wrt utilization (scaled by 1e18)\n     * @param jumpMultiplierPerYear The multiplierPerBlock after hitting a specified utilization point\n     * @param kink1_ The utilization point at which the interest rate is fixed\n     * @param kink2_ The utilization point at which the jump multiplier is applied\n     * @param roof_ The utilization point at which the borrow rate is fixed\n     * @param owner_ The address of the owner, i.e. the Timelock contract (which has the ability to update parameters directly)\n     */\n    constructor(\n        uint256 baseRatePerYear,\n        uint256 multiplierPerYear,\n        uint256 jumpMultiplierPerYear,\n        uint256 kink1_,\n        uint256 kink2_,\n        uint256 roof_,\n        address owner_\n    ) public {\n        owner = owner_;\n\n        updateTripleRateModelInternal(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink1_, kink2_, roof_);\n    }\n\n    /**\n     * @notice Update the parameters of the interest rate model (only callable by owner, i.e. Timelock)\n     * @param baseRatePerYear The approximate target base APR, as a mantissa (scaled by 1e18)\n     * @param multiplierPerYear The rate of increase in interest rate wrt utilization (scaled by 1e18)\n     * @param jumpMultiplierPerYear The multiplierPerBlock after hitting a specified utilization point\n     * @param kink1_ The utilization point at which the interest rate is fixed\n     * @param kink2_ The utilization point at which the jump multiplier is applied\n     * @param roof_ The utilization point at which the borrow rate is fixed\n     */\n    function updateTripleRateModel(\n        uint256 baseRatePerYear,\n        uint256 multiplierPerYear,\n        uint256 jumpMultiplierPerYear,\n        uint256 kink1_,\n        uint256 kink2_,\n        uint256 roof_\n    ) external {\n        require(msg.sender == owner, \"only the owner may call this function.\");\n\n        updateTripleRateModelInternal(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink1_, kink2_, roof_);\n    }\n\n    /**\n     * @notice Calculates the utilization rate of the market: `borrows / (cash + borrows - reserves)`\n     * @param cash The amount of cash in the market\n     * @param borrows The amount of borrows in the market\n     * @param reserves The amount of reserves in the market (currently unused)\n     * @return The utilization rate as a mantissa between [0, 1e18]\n     */\n    function utilizationRate(\n        uint256 cash,\n        uint256 borrows,\n        uint256 reserves\n    ) public view returns (uint256) {\n        // Utilization rate is 0 when there are no borrows\n        if (borrows == 0) {\n            return 0;\n        }\n\n        uint256 util = borrows.mul(1e18).div(cash.add(borrows).sub(reserves));\n        // If the utilization is above the roof, cap it.\n        if (util > roof) {\n            util = roof;\n        }\n        return util;\n    }\n\n    /**\n     * @notice Calculates the current borrow rate per block, with the error code expected by the market\n     * @param cash The amount of cash in the market\n     * @param borrows The amount of borrows in the market\n     * @param reserves The amount of reserves in the market\n     * @return The borrow rate percentage per block as a mantissa (scaled by 1e18)\n     */\n    function getBorrowRate(\n        uint256 cash,\n        uint256 borrows,\n        uint256 reserves\n    ) public view returns (uint256) {\n        uint256 util = utilizationRate(cash, borrows, reserves);\n\n        if (util <= kink1) {\n            return util.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);\n        } else if (util <= kink2) {\n            return kink1.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);\n        } else {\n            uint256 normalRate = kink1.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);\n            uint256 excessUtil = util.sub(kink2);\n            return excessUtil.mul(jumpMultiplierPerBlock).div(1e18).add(normalRate);\n        }\n    }\n\n    /**\n     * @notice Calculates the current supply rate per block\n     * @param cash The amount of cash in the market\n     * @param borrows The amount of borrows in the market\n     * @param reserves The amount of reserves in the market\n     * @param reserveFactorMantissa The current reserve factor for the market\n     * @return The supply rate percentage per block as a mantissa (scaled by 1e18)\n     */\n    function getSupplyRate(\n        uint256 cash,\n        uint256 borrows,\n        uint256 reserves,\n        uint256 reserveFactorMantissa\n    ) public view returns (uint256) {\n        uint256 oneMinusReserveFactor = uint256(1e18).sub(reserveFactorMantissa);\n        uint256 borrowRate = getBorrowRate(cash, borrows, reserves);\n        uint256 rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);\n        return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);\n    }\n\n    /**\n     * @notice Internal function to update the parameters of the interest rate model\n     * @param baseRatePerYear The approximate target base APR, as a mantissa (scaled by 1e18)\n     * @param multiplierPerYear The rate of increase in interest rate wrt utilization (scaled by 1e18)\n     * @param jumpMultiplierPerYear The multiplierPerBlock after hitting a specified utilization point\n     * @param kink1_ The utilization point at which the interest rate is fixed\n     * @param kink2_ The utilization point at which the jump multiplier is applied\n     * @param roof_ The utilization point at which the borrow rate is fixed\n     */\n    function updateTripleRateModelInternal(\n        uint256 baseRatePerYear,\n        uint256 multiplierPerYear,\n        uint256 jumpMultiplierPerYear,\n        uint256 kink1_,\n        uint256 kink2_,\n        uint256 roof_\n    ) internal {\n        require(kink1_ <= kink2_, \"kink1 must less than or equal to kink2\");\n        require(roof_ >= minRoofValue, \"invalid roof value\");\n\n        baseRatePerBlock = baseRatePerYear.div(blocksPerYear);\n        multiplierPerBlock = (multiplierPerYear.mul(1e18)).div(blocksPerYear.mul(kink1_));\n        jumpMultiplierPerBlock = jumpMultiplierPerYear.div(blocksPerYear);\n        kink1 = kink1_;\n        kink2 = kink2_;\n        roof = roof_;\n\n        emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink1, kink2, roof);\n    }\n}\n"
    }
  }
}}