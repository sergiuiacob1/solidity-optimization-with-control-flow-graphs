// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// cyclic assignments

contract Termination7 {
    uint persistent_var;
    event FunctionCalled(string f);
    event FunctionEnd(string f);

    function assignBeforeTermination(uint x) public {
        emit FunctionCalled("assignBeforeTermination");
        uint a; uint b; uint c;
        if (f1(x) == true) {
            a = x;
            b = a;
            c = b;
            a = c;
            return;
        }
        return;
    }

    function f1(uint x) public pure returns (bool) {
        return x > 10;
    }
}
