{{
  "language": "Solidity",
  "sources": {
    "WithdrawSplitter.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.13;\n\ncontract WithdrawSplitter {\n    address public constant ukraineAddress = 0x165CD37b4C644C2921454429E7F9358d18A45e14;\n    address public immutable otherAddress; // other address for withdrawal (for example, for artists)\n\n    // proportions:\n    uint16 public immutable ukrainePart;\n    uint16 public immutable otherPart;\n\n    constructor(address receiver_, uint16 ukrainePart_, uint16 otherPart_) {\n        otherAddress = receiver_;\n        ukrainePart = ukrainePart_;\n        otherPart = otherPart_;\n    }\n\n    fallback() external payable { }\n\n    receive() external payable { }\n\n    // anybody - withdraw contract balance to ukraineAddress and otherAddress\n    function withdraw() external {\n        uint256 currentBalance = address(this).balance;\n        uint256 totalPart = ukrainePart + otherPart;\n\n        // amount is divided according to the given proportions\n        uint256 ukraineAmount = currentBalance * ukrainePart / totalPart;\n        uint256 otherAmount = currentBalance * otherPart / totalPart;\n\n        payable(ukraineAddress).transfer(ukraineAmount);\n        payable(otherAddress).transfer(otherAmount);\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "WithdrawSplitter.sol": {}
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  }
}}