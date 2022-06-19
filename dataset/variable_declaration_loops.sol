// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract VariableLoop {
    function declareVariableInsideLoop() public pure {
        for (uint i = 1; i <= 1000; i++) {
            uint x = i * i;
        }
    }

    function declareVariableOutsideLoop() public pure {
        uint x;
        for (uint i = 1; i <= 1000; i++) {
            x = i * i;
        }
    }
}
