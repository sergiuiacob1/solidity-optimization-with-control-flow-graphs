// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Termination {
    uint persistent_var;
    event FunctionCalled(string f);

    function assignBeforeTermination(uint x) public {
        emit FunctionCalled("assignBeforeTermination");
        uint a;
        uint b;

        if (f1(x) == true) {
            a = 2;
            b = 3;
            a = a + b;
            return;
        }

        return;
    }

    function f1(uint x) public pure returns (bool) {
        return x > 10;
    }
}
