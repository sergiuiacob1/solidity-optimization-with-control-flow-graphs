{"dmap.sol":{"content":"/// SPDX-License-Identifier: AGPL-3.0\n\n// One day, someone is going to try very hard to prevent you\n// from accessing one of these storage slots.\n\npragma solidity 0.8.13;\n\ninterface Dmap {\n    error LOCKED();\n    event Set(\n        address indexed zone,\n        bytes32 indexed name,\n        bytes32 indexed meta,\n        bytes32 indexed data\n    ) anonymous;\n\n    function set(bytes32 name, bytes32 meta, bytes32 data) external;\n    function get(bytes32 slot) external view returns (bytes32 meta, bytes32 data);\n}\n\ncontract _dmap_ {\n    error LOCKED();\n    uint256 constant LOCK = 0x1;\n    constructor(address rootzone) { assembly {\n        sstore(0, LOCK)\n        sstore(1, shl(96, rootzone))\n    }}\n    fallback() external payable { assembly {\n        if eq(36, calldatasize()) {\n            mstore(0, sload(calldataload(4)))\n            mstore(32, sload(add(1, calldataload(4))))\n            return(0, 64)\n        }\n        let name := calldataload(4)\n        let meta := calldataload(36)\n        let data := calldataload(68)\n        mstore(0, caller())\n        mstore(32, name)\n        let slot := keccak256(0, 64)\n        log4(0, 0, caller(), name, meta, data)\n        sstore(add(slot, 1), data)\n        if iszero(or(xor(100, calldatasize()), and(LOCK, sload(slot)))) {\n            sstore(slot, meta)\n            return(0, 0)\n        }\n        if eq(100, calldatasize()) {\n            mstore(0, shl(224, 0xa1422f69))\n            revert(0, 4)\n        }\n        revert(0, 0)\n    }}\n}\n"},"root.sol":{"content":"/// SPDX-License-Identifier: AGPL-3.0\n\npragma solidity 0.8.13;\n\nimport { Dmap } from \u0027./dmap.sol\u0027;\n\ncontract RootZone {\n    Dmap    public immutable dmap;\n    uint256 public           last;\n    bytes32 public           mark;\n    uint256        immutable FREQ = 31 hours;\n    bytes32        immutable LOCK = bytes32(uint(0x1));\n\n    event Hark(bytes32 indexed mark);\n    event Etch(bytes32 indexed name, address indexed zone);\n\n    error ErrPending();\n    error ErrExpired();\n    error ErrPayment();\n    error ErrReceipt();\n\n    constructor(Dmap d) {\n        dmap = d;\n    }\n\n    function hark(bytes32 hash) external payable {\n        if (block.timestamp \u003c last + FREQ) revert ErrPending();\n        if (msg.value != 1 ether) revert ErrPayment();\n        (bool ok, ) = block.coinbase.call{value:(10**18)}(\"\");\n        if (!ok) revert ErrReceipt();\n        last = block.timestamp;\n        mark = hash;\n        emit Hark(mark);\n    }\n\n    function etch(bytes32 salt, bytes32 name, address zone) external {\n        bytes32 hash = keccak256(abi.encode(salt, name, zone));\n        if (hash != mark) revert ErrExpired();\n        dmap.set(name, LOCK, bytes32(bytes20(zone)));\n        emit Etch(name, zone);\n    }\n}\n"}}