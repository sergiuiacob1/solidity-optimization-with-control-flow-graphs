// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Termination {
    uint persistent_var;
    event FunctionCalled(string f);

    function assignBeforeTermination() public {
        emit FunctionCalled("assignBeforeTermination");
        uint balance;
        balance = 7919;
        return;
    }
}
