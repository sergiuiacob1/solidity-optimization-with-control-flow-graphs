// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract DataFlowAnalysis {
    uint256 persistent_var;

    function variableTracing(uint256 n) public pure returns (uint256) {
        uint256 x; // x is 0
        if (n > 10) {
            x = 1; // x is 1
        } else {
            x = 2; // x is 2
        }
        // x is in {1, 2}
        return x;
    }
}
