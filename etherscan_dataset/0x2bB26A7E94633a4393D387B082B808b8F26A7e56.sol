{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": false
      },
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
    "contracts/release/infrastructure/price-feeds/primitives/UsdEthSimulatedAggregator.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../../interfaces/IChainlinkAggregator.sol\";\n\n/// @title UsdEthSimulatedAggregator Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A simulated aggregator for providing the inverse rate of the Chainlink ETH/USD aggregator\ncontract UsdEthSimulatedAggregator {\n    // The quote asset of this feed is ETH, so 18 decimals makes sense,\n    // both in terms of a mocked Chainlink aggregator and for greater precision\n    uint8 private constant DECIMALS = 18;\n    // 10 ** (Local precision (DECIMALS) + EthUsd aggregator decimals)\n    int256 private constant INVERSE_RATE_NUMERATOR = 10**26;\n\n    IChainlinkAggregator private immutable ETH_USD_AGGREGATOR_CONTRACT;\n\n    constructor(address _ethUsdAggregator) public {\n        ETH_USD_AGGREGATOR_CONTRACT = IChainlinkAggregator(_ethUsdAggregator);\n    }\n\n    /// @notice The decimals used for rate precision of this simulated aggregator\n    /// @return decimals_ The number of decimals\n    function decimals() external pure returns (uint8 decimals_) {\n        return DECIMALS;\n    }\n\n    /// @notice The latest round data for this simulated aggregator\n    /// @return roundId_ The `roundId` value returned by the Chainlink aggregator\n    /// @return answer_ The `answer` value returned by the Chainlink aggregator, inverted to USD/ETH\n    /// @return startedAt_ The `startedAt` value returned by the Chainlink aggregator\n    /// @return updatedAt_ The `updatedAt` value returned by the Chainlink aggregator\n    /// @return answeredInRound_ The `answeredInRound` value returned by the Chainlink aggregator\n    /// @dev All values are returned directly from the target Chainlink ETH/USD aggregator,\n    /// other than `answer_`, which is inverted to give the USD/ETH rate,\n    /// and is given the local precision of `DECIMALS`.\n    function latestRoundData()\n        external\n        view\n        returns (\n            uint80 roundId_,\n            int256 answer_,\n            uint256 startedAt_,\n            uint256 updatedAt_,\n            uint80 answeredInRound_\n        )\n    {\n        int256 ethUsdAnswer;\n        (\n            roundId_,\n            ethUsdAnswer,\n            startedAt_,\n            updatedAt_,\n            answeredInRound_\n        ) = ETH_USD_AGGREGATOR_CONTRACT.latestRoundData();\n\n        // Does not attempt to make sense of a negative answer\n        if (ethUsdAnswer > 0) {\n            answer_ = INVERSE_RATE_NUMERATOR / ethUsdAnswer;\n        }\n\n        return (roundId_, answer_, startedAt_, updatedAt_, answeredInRound_);\n    }\n}\n"
    },
    "contracts/release/interfaces/IChainlinkAggregator.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IChainlinkAggregator Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IChainlinkAggregator {\n    function latestRoundData()\n        external\n        view\n        returns (\n            uint80,\n            int256,\n            uint256,\n            uint256,\n            uint80\n        );\n}\n"
    }
  }
}}