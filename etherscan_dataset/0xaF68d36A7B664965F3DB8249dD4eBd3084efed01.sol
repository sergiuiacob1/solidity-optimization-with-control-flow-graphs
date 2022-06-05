{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "remappings": [],
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
  },
  "sources": {
    "contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: GNU GPLv3\n\n// OpenZeppelin Contracts v4.3.2 (access/Ownable.sol)\n\npragma solidity =0.8.9;\n\nimport {Context} from '../utils/Context.sol';\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner\n */\nabstract contract Ownable is Context {\n    address private _owner;\n    address private _master;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner\n     */\n    constructor(address masterAddress) {\n        _transferOwnership(_msgSender());\n        _master = masterAddress;\n    }\n\n    /**\n     * @dev Returns the address of the current owner\n     * @return _owner - owner address\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), 'ONA');\n        _;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the master\n     */\n    modifier onlyMaster() {\n        require(owner() == _msgSender(), 'ONA');\n        _;\n    }\n\n    /**\n     * @dev Transfering the owner ship to master role in case of emergency\n     *\n     * NOTE: Renouncing ownership will transfer the contract ownership to master role\n     */\n\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(_master);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`)\n     * Can only be called by the current owner\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), 'OCNZA');\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`)\n     * Internal function without access restriction\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "contracts/mutlicall/Multicall2.sol": {
      "content": "/// SPDX-License-Identifier: GNU GPLv3\n\npragma solidity =0.8.9;\npragma abicoder v2;\n\n/// @title Multicall2 - Aggregate results from multiple read-only function calls\n/// @author Michael Elliot <mike@makerdao.com>\n/// @author Joshua Levine <joshua@makerdao.com>\n/// @author Nick Johnson <arachnid@notdot.net>\n\nimport '../access/Ownable.sol';\n\ncontract Multicall2 is Ownable {\n    /**\n     * @dev initialize multicall and set master as owner on the contract\n     */\n    constructor(address master) Ownable(master) {}\n\n    /**\n     * @dev Call stores of calling data - target and callData\n     */\n    struct Call {\n        address target;\n        bytes callData;\n    }\n\n    /**\n     * @dev Result stores status and return data\n     */\n    struct Result {\n        bool success;\n        bytes returnData;\n    }\n\n    /**\n     * @dev aggregate the multiple calls.\n     * @param calls - call details\n     * @return blockNumber - block number\n     * @return returnData - return data\n     */\n    function aggregate(Call[] memory calls) public onlyOwner returns (uint256 blockNumber, bytes[] memory returnData) {\n        blockNumber = block.number;\n        returnData = new bytes[](calls.length);\n        for (uint256 i = 0; i < calls.length; i++) {\n            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);\n            require(success, 'MACF');\n            returnData[i] = ret;\n        }\n    }\n\n    /**\n     * @dev block and aggregate calls\n     * @param calls - call data\n     * @return blockNumber - block number\n     * @return blockHash - block hash\n     * @return returnData - return Data\n     */\n    function blockAndAggregate(Call[] memory calls)\n        public\n        onlyOwner\n        returns (\n            uint256 blockNumber,\n            bytes32 blockHash,\n            Result[] memory returnData\n        )\n    {\n        (blockNumber, blockHash, returnData) = tryBlockAndAggregate(true, calls);\n    }\n\n    /**\n     * @dev returns block hash of the current block\n     * @return blockHash - current block hash\n     */\n    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {\n        blockHash = blockhash(blockNumber);\n    }\n\n    /**\n     * @dev returns block number of the current block\n     * @return blockNumber - current block number\n     */\n    function getBlockNumber() public view returns (uint256 blockNumber) {\n        blockNumber = block.number;\n    }\n\n    /**\n     * @dev returns the miner's address of current block\n     * @return coinbase - miner\n     */\n    function getCurrentBlockCoinbase() public view returns (address coinbase) {\n        coinbase = block.coinbase;\n    }\n\n    /**\n     * @dev returns the current block difficulty\n     * @return difficulty - block difficulty\n     */\n    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {\n        difficulty = block.difficulty;\n    }\n\n    /**\n     * @dev returns the current block gaslimit\n     * @return gaslimit - gas limit\n     */\n    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {\n        gaslimit = block.gaslimit;\n    }\n\n    /**\n     * @dev returns the current block timestamp\n     * @return timestamp - current time stamp\n     */\n    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {\n        timestamp = block.timestamp;\n    }\n\n    /**\n     * @dev returns the balance of address in parent chain token\n     * @return balance - address balance\n     */\n    function getEthBalance(address addr) public view returns (uint256 balance) {\n        balance = addr.balance;\n    }\n\n    /**\n     * @dev returns the previous block hash\n     * @return blockHash - last block hash\n     */\n    function getLastBlockHash() public view returns (bytes32 blockHash) {\n        blockHash = blockhash(block.number - 1);\n    }\n\n    /**\n     * @dev returns the aggregated calls\n     * @param requireSuccess - reuires success only\n     * @param calls - need call data\n     * @return returnData - it has status and return data\n     */\n    function tryAggregate(bool requireSuccess, Call[] memory calls) public onlyOwner returns (Result[] memory returnData) {\n        returnData = new Result[](calls.length);\n        for (uint256 i = 0; i < calls.length; i++) {\n            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);\n\n            if (requireSuccess) {\n                require(success, 'M2ACF');\n            }\n\n            returnData[i] = Result(success, ret);\n        }\n    }\n\n    /**\n     * @dev block calls blockNumberwise and aggregate.\n     * @param requireSuccess - only successed call\n     * @param calls - multi calls\n     * @return blockNumber - block number\n     * @return blockHash - block hash\n     * @return returnData - aggregater data\n     */\n    function tryBlockAndAggregate(bool requireSuccess, Call[] memory calls)\n        public\n        onlyOwner\n        returns (\n            uint256 blockNumber,\n            bytes32 blockHash,\n            Result[] memory returnData\n        )\n    {\n        blockNumber = block.number;\n        blockHash = blockhash(block.number);\n        returnData = tryAggregate(requireSuccess, calls);\n    }\n}\n"
    },
    "contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: GNU GPLv3\n\n// OpenZeppelin Contracts v4.3.2 (utils/Context.sol)\n\npragma solidity =0.8.9;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\n\nabstract contract Context {\n    /**\n     * @dev returns the caller address\n     */\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    /**\n     * @dev returns the caller message data\n     */\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    }
  }
}}