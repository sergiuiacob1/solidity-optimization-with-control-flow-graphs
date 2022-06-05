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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/MatrixVotingPower.sol": {
      "content": "//SPDX-License-Identifier: MIT\n/**\n███    ███  █████  ████████ ██████  ██ ██   ██     ██████   █████   ██████  \n████  ████ ██   ██    ██    ██   ██ ██  ██ ██      ██   ██ ██   ██ ██    ██ \n██ ████ ██ ███████    ██    ██████  ██   ███       ██   ██ ███████ ██    ██ \n██  ██  ██ ██   ██    ██    ██   ██ ██  ██ ██      ██   ██ ██   ██ ██    ██ \n██      ██ ██   ██    ██    ██   ██ ██ ██   ██     ██████  ██   ██  ██████  \n\nWebsite: https://matrixdaoresearch.xyz/\nTwitter: https://twitter.com/MatrixDAO_\n */\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol\";\nimport \"./interfaces/INFTMatrixDao.sol\";\n\ncontract MatrixVotingPower is IERC20, IERC20Metadata, Ownable {\n    string constant NOT_IMPLEMENTED_MSG = \"MatrixVotingPower: not implemented\";\n    uint256 constant ENDTOKEN_ID_LAST_TOKEN = 0;\n\n    address public immutable nft;\n    address public immutable mtx;\n\n    mapping(uint256 => bool) public blackList;\n    uint256 public numBlackList;\n\n    constructor(address _nft, address _mtx){\n        nft = _nft;\n        mtx = _mtx;\n    }\n\n    function addToBlackList(uint256 tokenId) external onlyOwner {\n        require(!blackList[tokenId], \"MatrixVotingPower: already in the blacklist\");\n        blackList[tokenId] = true;\n        numBlackList++;\n    }\n\n    function removeFromBlackList(uint256 tokenId) external onlyOwner {\n        require(blackList[tokenId], \"MatrixVotingPower: not in the blacklist\");\n        blackList[tokenId] = false;\n        numBlackList--;\n    }\n\n    function name() external override pure returns (string memory) {\n        return \"Matrix DAO Voting Power\";\n    }\n\n    function symbol() external override pure returns (string memory) {\n        return \"MTX\";\n    }\n\n    function decimals() external override view returns (uint8) {\n        return IERC20Metadata(mtx).decimals();\n    }\n\n    function totalSupply() external override view returns (uint256) {\n        return INFTMatrixDao(nft).totalSupply() - numBlackList;\n    }\n\n    function balanceOf(address account) external override view returns (uint256) {\n        uint256 validNFT = 0;\n        if(INFTMatrixDao(nft).balanceOf(account) != 0) {\n            uint256[] memory tokenIds; \n            uint256 endTokenId;\n            (tokenIds, endTokenId) = INFTMatrixDao(nft).ownedTokens(account, 1, ENDTOKEN_ID_LAST_TOKEN); \n\n            for(uint256 i=0;i<tokenIds.length;i++) {\n                uint256 tokenId = tokenIds[i];\n                if(!blackList[tokenId]){\n                    validNFT++;\n                }\n            }\n\n            if(validNFT > 0) {\n                return IERC20(mtx).balanceOf(account);\n            } else {\n                return 0;\n            }\n        }\n    }\n\n\n    // Unused interfaces\n\n    function transfer(address to, uint256 amount) external override returns (bool) {\n        revert(NOT_IMPLEMENTED_MSG);\n    }\n    function allowance(address owner, address spender) external override view returns (uint256) {\n        revert(NOT_IMPLEMENTED_MSG);\n    }\n\n    function approve(address spender, uint256 amount) external override returns (bool) {\n        revert(NOT_IMPLEMENTED_MSG);\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external override returns (bool) {\n        revert(NOT_IMPLEMENTED_MSG);\n    }\n\n}\n\n\n"
    },
    "contracts/interfaces/INFTMatrixDao.sol": {
      "content": "//SPDX-License-Identifier: MIT\n/**\n███    ███  █████  ████████ ██████  ██ ██   ██     ██████   █████   ██████  \n████  ████ ██   ██    ██    ██   ██ ██  ██ ██      ██   ██ ██   ██ ██    ██ \n██ ████ ██ ███████    ██    ██████  ██   ███       ██   ██ ███████ ██    ██ \n██  ██  ██ ██   ██    ██    ██   ██ ██  ██ ██      ██   ██ ██   ██ ██    ██ \n██      ██ ██   ██    ██    ██   ██ ██ ██   ██     ██████  ██   ██  ██████  \n\nWebsite: https://matrixdaoresearch.xyz/\nTwitter: https://twitter.com/MatrixDAO_\n */\npragma solidity ^0.8.0;\n\ninterface INFTMatrixDao {\n  function allowReveal (  ) external view returns ( bool );\n  function approve ( address to, uint256 tokenId ) external;\n  function balanceOf ( address owner ) external view returns ( uint256 );\n  function devMint ( uint256 _amount, address _to ) external;\n  function getApproved ( uint256 tokenId ) external view returns ( address );\n  function isApprovedForAll ( address owner, address operator ) external view returns ( bool );\n  function maxCollection (  ) external view returns ( uint256 );\n  function mint ( uint32 _amount, uint32 _allowAmount, uint64 _expireTime, bytes memory _signature ) external;\n  function name (  ) external view returns ( string memory );\n  function numberMinted ( address _minter ) external view returns ( uint256 minted );\n  function ownedTokens ( address _addr, uint256 _startId, uint256 _endId ) external view returns ( uint256[] memory tokenIds, uint256 endTokenId );\n  function owner (  ) external view returns ( address );\n  function ownerOf ( uint256 tokenId ) external view returns ( address );\n  function price (  ) external view returns ( uint256 );\n  function renounceOwnership (  ) external;\n  function reveal ( uint256 _tokenId, bytes32 _hash, bytes memory _signature ) external;\n  function safeTransferFrom ( address from, address to, uint256 tokenId ) external;\n  function safeTransferFrom ( address from, address to, uint256 tokenId, bytes memory _data ) external;\n  function setAllowReveal ( bool _allowReveal ) external;\n  function setApprovalForAll ( address operator, bool approved ) external;\n  function setPrice ( uint256 _newPrice ) external;\n  function setSigner ( address _newSigner ) external;\n  function setUnrevealURI ( string memory _newURI ) external;\n  function supportsInterface ( bytes4 interfaceId ) external view returns ( bool );\n  function symbol (  ) external view returns ( string memory );\n  function tokenReveal ( uint256 _tokenId ) external view returns ( bool isRevealed );\n  function tokenURI ( uint256 _tokenId ) external view returns ( string memory uri );\n  function totalMinted (  ) external view returns ( uint256 minted );\n  function totalSupply (  ) external view returns ( uint256 );\n  function transferFrom ( address from, address to, uint256 tokenId ) external;\n  function transferOwnership ( address newOwner ) external;\n  function unrevealURI (  ) external view returns ( string memory );\n  function withdraw ( address _to ) external;\n}\n"
    }
  }
}}