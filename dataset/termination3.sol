// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Termination {
    uint persistent_var;
    event FunctionCalled(string f);
    event BalanceIsEmpty();

    function assignBeforeTermination(uint x) public {
        emit FunctionCalled("assignBeforeTermination");
        uint balance;
        
        balance = 10006;
        if (f1(x) == true) {
            balance = 10007;
            return;
        }

        if (balance == 0) {
            emit BalanceIsEmpty();
        }
        return;
    }

    function f1(uint x) public pure returns (bool) {
        return x > 10;
    }
}
