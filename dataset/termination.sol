// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Termination {
    uint persistent_var;

    function assignBeforeTermination(uint x) public returns (uint){
        uint[100] memory balance;
        if (f1(x) == true) {
            // if the below are removed, it uses less gas
            // even with this config:
            //    optimizer: {
            //     "yul": true,
            //     enabled: true,
            //     runs: 200
            // },
            // "viaIR": true
            // which means the optimizer doesn't remove assignments before a termination flow

            persistent_var = 666013; // should not be removed
            x = 2; // redundant assignment
            uint y = 3; // redundant variable declaration
            uint z = 4; // redundant variable declaration

            y = 420;

            uint v1_inline_function; uint v2_inline_function;
            (v1_inline_function, v2_inline_function) = f2(); // assignments should removed, but what about f2()?
            balance[5] = 123141;
            return 0;
        }
        return balance[5];
    }

    function f1(uint x) public pure returns (bool) {
        return x > 10;
    }

    function f2() public pure returns (uint, uint) {
        return (1, 2);
    }
}

// Usecases:
// v1, v2 = f() <-- doar v1 este folosit. in cazul asta, ramane si v2 acolo, nu putem modifica spec-ul functiei sau ceva
