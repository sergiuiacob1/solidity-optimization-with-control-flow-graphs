{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 10000
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
    "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.6.0;\n\ninterface AggregatorV3Interface {\n\n  function decimals() external view returns (uint8);\n  function description() external view returns (string memory);\n  function version() external view returns (uint256);\n\n  // getRoundData and latestRoundData should both raise \"No data present\"\n  // if they do not have data to report, instead of returning unset values\n  // which could be misinterpreted as actual reported values.\n  function getRoundData(uint80 _roundId)\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n  function latestRoundData()\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n}\n"
    },
    "contracts/JBChainlinkV3PriceFeed.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.6;\n\nimport '@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol';\nimport './interfaces/IJBPriceFeed.sol';\nimport './libraries/JBFixedPointNumber.sol';\n\n/** \n  @notice \n  A generalized price feed for the Chainlink AggregatorV3Interface.\n\n  @dev\n  Adheres to -\n  IJBPriceFeed: General interface for the methods in this contract that interact with the blockchain's state according to the protocol's rules.\n*/\ncontract JBChainlinkV3PriceFeed is IJBPriceFeed {\n  // A library that provides utility for fixed point numbers.\n  using JBFixedPointNumber for uint256;\n\n  //*********************************************************************//\n  // --------------------- public stored properties -------------------- //\n  //*********************************************************************//\n\n  /** \n    @notice \n    The feed that prices are reported from.\n  */\n  AggregatorV3Interface public feed;\n\n  //*********************************************************************//\n  // ------------------------- external views -------------------------- //\n  //*********************************************************************//\n\n  /** \n    @notice \n    Gets the current price from the feed, normalized to the specified number of decimals.\n\n    @param _decimals The number of decimals the returned fixed point price should include.\n\n    @return The current price of the feed, as a fixed point number with the specified number of decimals.\n  */\n  function currentPrice(uint256 _decimals) external view override returns (uint256) {\n    // Get the latest round information. Only need the price is needed.\n    (, int256 _price, , , ) = feed.latestRoundData();\n\n    // Get a reference to the number of decimals the feed uses.\n    uint256 _feedDecimals = feed.decimals();\n\n    // Return the price, adjusted to the target decimals.\n    return uint256(_price).adjustDecimals(_feedDecimals, _decimals);\n  }\n\n  //*********************************************************************//\n  // -------------------------- constructor ---------------------------- //\n  //*********************************************************************//\n\n  /** \n    @param _feed The feed to report prices from.\n  */\n  constructor(AggregatorV3Interface _feed) {\n    feed = _feed;\n  }\n}\n"
    },
    "contracts/interfaces/IJBPriceFeed.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.6;\n\ninterface IJBPriceFeed {\n  function currentPrice(uint256 _targetDecimals) external view returns (uint256);\n}\n"
    },
    "contracts/libraries/JBFixedPointNumber.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.6;\n\nlibrary JBFixedPointNumber {\n  function adjustDecimals(\n    uint256 _value,\n    uint256 _decimals,\n    uint256 _targetDecimals\n  ) internal pure returns (uint256) {\n    // If decimals need adjusting, multiply or divide the price by the decimal adjuster to get the normalized result.\n    if (_targetDecimals == _decimals) return _value;\n    else if (_targetDecimals > _decimals) return _value * 10**(_targetDecimals - _decimals);\n    else return _value / 10**(_decimals - _targetDecimals);\n  }\n}\n"
    }
  }
}}