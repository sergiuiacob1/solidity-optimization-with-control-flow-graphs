// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract VariableIf {
    function declareVariableInsideIf() public pure {
        if (true) {
            uint x = 0;
        } else {
            uint x = 1;
        }
    }

    function declareVariableOutsideIf() public pure {
        uint x;
        if (true) {
            x = 0;
        } else {
            x = 1;
        }
    }
}
