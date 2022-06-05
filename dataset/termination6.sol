// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// unused assignment where value comes from function that doesn't change state

contract Termination {
    uint persistent_var;
    event FunctionCalled(string f);
    event BalanceIsEmpty();

    function assignBeforeTermination(uint x) public {
        emit FunctionCalled("assignBeforeTermination");
        uint balance;
        
        if (f1(x) == true) {
            balance = f2(x);
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

    function f2(uint x) public returns (uint) {
        persistent_var = 1;
        return x * 2;
    }
}
