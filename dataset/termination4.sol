// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// unused assignment for persistent variables

contract Termination {
    uint persistent_var;
    event FunctionCalled(string f);

    function assignBeforeTermination(uint x) public {
        emit FunctionCalled("assignBeforeTermination");
        persistent_var = 1;
        if (f1(x) == true) {
            persistent_var = 2;
            return;
        }
        return;
    }

    function f1(uint x) public pure returns (bool) {
        return x > 10;
    }
}
