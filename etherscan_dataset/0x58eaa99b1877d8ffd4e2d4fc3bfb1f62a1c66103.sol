{{
  "language": "Solidity",
  "sources": {
    "src/passport/render/Metadata.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity =0.8.10;\n\nimport {Strings} from \"@openzeppelin/contracts/utils/Strings.sol\";\nimport {DateTime, Date} from \"../../utils/DateTime.sol\";\n\nlibrary Metadata {\n    function getMetadataJson(\n        uint256 tokenId,\n        address owner,\n        uint256 timestamp,\n        string memory imageData\n    ) public pure returns (string memory) {\n        string memory attributes = renderAttributes(tokenId, owner, timestamp);\n        return string(abi.encodePacked(\n            '{\"name\": \"',\n            renderName(tokenId),\n            '\", \"image\": \"data:image/svg+xml;base64,',\n            imageData,\n            '\",\"attributes\":[',\n            attributes,\n            \"]}\"\n        ));\n    }\n\n    function renderName(\n        uint256 id\n    ) public pure returns (string memory) {\n        return string(abi.encodePacked(\"Nation3 Genesis Passport #\", Strings.toString(id)));\n    }\n\n    function renderAttributes(\n        uint256 id,\n        address owner,\n        uint256 timestamp\n    ) public pure returns (string memory) {\n        Date memory ts = DateTime.timestampToDateTime(timestamp);\n\n        return\n            string(abi.encodePacked(\n                attributeString(\"Passport Holder\", Strings.toHexString(uint256(uint160(owner)))),\n                \",\",\n                attributeString(\"Passport Number\", Strings.toString(id)),\n                \",\",\n                attributeString(\n                    \"Issue Date\",\n                    string(abi.encodePacked(Strings.toString(ts.day),'/',Strings.toString(ts.month),'/',Strings.toString(ts.year)))\n                )\n            ));\n    }\n\n    function attributeString(string memory _name, string memory _value)\n        public\n        pure\n        returns (string memory)\n    {\n        return\n            string(abi.encodePacked(\n                \"{\",\n                kv(\"trait_type\", string(abi.encodePacked('\"', _name, '\"'))),\n                \",\",\n                kv(\"value\", string(abi.encodePacked('\"', _value, '\"'))),\n                \"}\"\n            ));\n    }\n\n    function kv(string memory _key, string memory _value)\n        public\n        pure\n        returns (string memory)\n    {\n        return string(abi.encodePacked('\"', _key, '\"', \":\", _value));\n    }\n}\n"
    },
    "src/utils/DateTime.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// Copyright (c) 2018 The Officious BokkyPooBah / Bok Consulting Pty Ltd\n\npragma solidity ^0.8.0;\n\nstruct Date {\n    uint256 year;\n    uint256 month;\n    uint256 day;\n    uint256 hour;\n    uint256 minute;\n    uint256 second;\n}\n\nlibrary DateTime {\n    // for datetime conversion.\n    uint256 private constant SECONDS_PER_DAY = 24 * 60 * 60;\n    uint256 private constant SECONDS_PER_HOUR = 60 * 60;\n    uint256 private constant SECONDS_PER_MINUTE = 60;\n    int256 constant OFFSET19700101 = 2440588;\n\n    function timestampToDateTime(uint256 timestamp) internal pure returns (Date memory) {\n        (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / SECONDS_PER_DAY);\n        uint256 secs = timestamp % SECONDS_PER_DAY;\n        uint256 hour = secs / SECONDS_PER_HOUR;\n        secs = secs % SECONDS_PER_HOUR;\n        uint256 minute = secs / SECONDS_PER_MINUTE;\n        uint256 second = secs % SECONDS_PER_MINUTE;\n\n        return Date(year, month, day, hour, minute, second);\n    }\n\n    // ------------------------------------------------------------------------\n    // Calculate year/month/day from the number of days since 1970/01/01 using\n    // the date conversion algorithm from\n    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php\n    // and adding the offset 2440588 so that 1970/01/01 is day 0\n    //\n    // int L = days + 68569 + offset\n    // int N = 4 * L / 146097\n    // L = L - (146097 * N + 3) / 4\n    // year = 4000 * (L + 1) / 1461001\n    // L = L - 1461 * year / 4 + 31\n    // month = 80 * L / 2447\n    // dd = L - 2447 * month / 80\n    // L = month / 11\n    // month = month + 2 - 12 * L\n    // year = 100 * (N - 49) + year + L\n    // ------------------------------------------------------------------------\n    function _daysToDate(uint256 _days)\n        internal\n        pure\n        returns (\n            uint256 year,\n            uint256 month,\n            uint256 day\n        )\n    {\n        int256 __days = int256(_days);\n\n        int256 L = __days + 68569 + OFFSET19700101;\n        int256 N = (4 * L) / 146097;\n        L = L - (146097 * N + 3) / 4;\n        int256 _year = (4000 * (L + 1)) / 1461001;\n        L = L - (1461 * _year) / 4 + 31;\n        int256 _month = (80 * L) / 2447;\n        int256 _day = L - (2447 * _month) / 80;\n        L = _month / 11;\n        _month = _month + 2 - 12 * L;\n        _year = 100 * (N - 49) + _year + L;\n\n        year = uint256(_year);\n        month = uint256(_month);\n        day = uint256(_day);\n    }\n\n    function isLeapYear(uint256 timestamp) internal pure returns (bool leapYear) {\n        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);\n        leapYear = _isLeapYear(year);\n    }\n\n    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {\n        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": false,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}