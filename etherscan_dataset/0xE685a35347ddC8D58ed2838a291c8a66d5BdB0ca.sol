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
      "runs": 690
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
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@rari-capital/solmate/src/tokens/ERC20.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)\n/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)\n/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.\nabstract contract ERC20 {\n    /*///////////////////////////////////////////////////////////////\n                                  EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\n\n    /*///////////////////////////////////////////////////////////////\n                             METADATA STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    string public name;\n\n    string public symbol;\n\n    uint8 public immutable decimals;\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC20 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 public totalSupply;\n\n    mapping(address => uint256) public balanceOf;\n\n    mapping(address => mapping(address => uint256)) public allowance;\n\n    /*///////////////////////////////////////////////////////////////\n                             EIP-2612 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    bytes32 public constant PERMIT_TYPEHASH =\n        keccak256(\"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\");\n\n    uint256 internal immutable INITIAL_CHAIN_ID;\n\n    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;\n\n    mapping(address => uint256) public nonces;\n\n    /*///////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(\n        string memory _name,\n        string memory _symbol,\n        uint8 _decimals\n    ) {\n        name = _name;\n        symbol = _symbol;\n        decimals = _decimals;\n\n        INITIAL_CHAIN_ID = block.chainid;\n        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC20 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 amount) public virtual returns (bool) {\n        allowance[msg.sender][spender] = amount;\n\n        emit Approval(msg.sender, spender, amount);\n\n        return true;\n    }\n\n    function transfer(address to, uint256 amount) public virtual returns (bool) {\n        balanceOf[msg.sender] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(msg.sender, to, amount);\n\n        return true;\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) public virtual returns (bool) {\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\n\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\n\n        balanceOf[from] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(from, to, amount);\n\n        return true;\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              EIP-2612 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) public virtual {\n        require(deadline >= block.timestamp, \"PERMIT_DEADLINE_EXPIRED\");\n\n        // Unchecked because the only math done is incrementing\n        // the owner's nonce which cannot realistically overflow.\n        unchecked {\n            bytes32 digest = keccak256(\n                abi.encodePacked(\n                    \"\\x19\\x01\",\n                    DOMAIN_SEPARATOR(),\n                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))\n                )\n            );\n\n            address recoveredAddress = ecrecover(digest, v, r, s);\n\n            require(recoveredAddress != address(0) && recoveredAddress == owner, \"INVALID_SIGNER\");\n\n            allowance[recoveredAddress][spender] = value;\n        }\n\n        emit Approval(owner, spender, value);\n    }\n\n    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {\n        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();\n    }\n\n    function computeDomainSeparator() internal view virtual returns (bytes32) {\n        return\n            keccak256(\n                abi.encode(\n                    keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"),\n                    keccak256(bytes(name)),\n                    keccak256(\"1\"),\n                    block.chainid,\n                    address(this)\n                )\n            );\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                       INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 amount) internal virtual {\n        totalSupply += amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(address(0), to, amount);\n    }\n\n    function _burn(address from, uint256 amount) internal virtual {\n        balanceOf[from] -= amount;\n\n        // Cannot underflow because a user's balance\n        // will never be larger than the total supply.\n        unchecked {\n            totalSupply -= amount;\n        }\n\n        emit Transfer(from, address(0), amount);\n    }\n}\n"
    },
    "contracts/interfaces/Tether.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface Tether {\r\n    function approve(address spender, uint256 value) external;\r\n\r\n    function balanceOf(address user) external view returns (uint256);\r\n\r\n    function transfer(address to, uint256 value) external;\r\n}\r\n"
    },
    "contracts/interfaces/curve/ICurvePool.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n// solhint-disable func-name-mixedcase, var-name-mixedcase\r\npragma solidity >=0.6.12;\r\n\r\ninterface CurvePool {\r\n    function exchange_underlying(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx,\r\n        uint256 min_dy,\r\n        address receiver\r\n    ) external returns (uint256);\r\n\r\n    function exchange(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx,\r\n        uint256 min_dy,\r\n        address receiver\r\n    ) external returns (uint256);\r\n\r\n    function exchange(\r\n        uint256 i,\r\n        uint256 j,\r\n        uint256 dx,\r\n        uint256 min_dy\r\n    ) external returns (uint256);\r\n\r\n    function get_dy_underlying(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function get_dy(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function approve(address _spender, uint256 _value) external returns (bool);\r\n\r\n    function add_liquidity(uint256[2] memory amounts, uint256 _min_mint_amount) external;\r\n\r\n    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;\r\n\r\n    function add_liquidity(uint256[4] memory amounts, uint256 _min_mint_amount) external;\r\n\r\n    function remove_liquidity_one_coin(\r\n        uint256 tokenAmount,\r\n        int128 i,\r\n        uint256 min_amount\r\n    ) external returns (uint256);\r\n\r\n    function remove_liquidity_one_coin(\r\n        uint256 tokenAmount,\r\n        uint256 i,\r\n        uint256 min_amount\r\n    ) external returns (uint256);\r\n\r\n    function remove_liquidity_one_coin(\r\n        uint256 tokenAmount,\r\n        int128 i,\r\n        uint256 min_amount,\r\n        address receiver\r\n    ) external returns (uint256);\r\n}\r\n"
    },
    "contracts/interfaces/curve/ICurveThreeCryptoPool.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface CurveThreeCryptoPool {\r\n    function exchange(\r\n        uint256 i,\r\n        uint256 j,\r\n        uint256 dx,\r\n        uint256 min_dy\r\n    ) payable external;\r\n\r\n    function get_dy(\r\n        uint256 i,\r\n        uint256 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;\r\n}\r\n"
    },
    "contracts/interfaces/curve/ICurveThreePool.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface CurveThreePool {\r\n    function exchange(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx,\r\n        uint256 min_dy\r\n    ) external;\r\n\r\n    function get_dy_underlying(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function get_dy(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;\r\n\r\n    function remove_liquidity_one_coin(\r\n        uint256 amount,\r\n        int128 i,\r\n        uint256 minAmount\r\n    ) external;\r\n}\r\n"
    },
    "contracts/magic-crv/RewardHarvester.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n// solhint-disable func-name-mixedcase\r\npragma solidity ^0.8.10;\r\n\r\nimport \"@rari-capital/solmate/src/tokens/ERC20.sol\";\r\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\r\nimport \"../interfaces/Tether.sol\";\r\nimport \"../interfaces/curve/ICurveThreeCryptoPool.sol\";\r\nimport \"../interfaces/curve/ICurveThreePool.sol\";\r\nimport \"../interfaces/curve/ICurvePool.sol\";\r\n\r\ninterface ICurveVoter {\r\n    function lock() external;\r\n\r\n    function claimAll(address recipient) external returns (uint256 amount);\r\n\r\n    function claim(address recipient) external returns (uint256 amount);\r\n}\r\n\r\ncontract RewardHarvester is Ownable {\r\n    error InsufficientOutput();\r\n    error NotAllowed();\r\n\r\n    ERC20 public constant CRV = ERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);\r\n    ERC20 public constant CRV3 = ERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);\r\n    ERC20 public constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\r\n    CurveThreePool public constant CRV3POOL = CurveThreePool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);\r\n    CurvePool public constant CRVETH = CurvePool(0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511);\r\n    Tether public constant USDT = Tether(0xdAC17F958D2ee523a2206206994597C13D831ec7);\r\n    CurveThreeCryptoPool public constant TRICRYPTO = CurveThreeCryptoPool(0xD51a44d3FaE010294C616388b506AcdA1bfAAE46);\r\n    ICurveVoter public immutable curveVoter;\r\n\r\n    mapping(address => bool) public allowedHarvesters;\r\n\r\n    modifier onlyAllowedHarvesters() {\r\n        if (!allowedHarvesters[msg.sender] && msg.sender != owner()) {\r\n            revert NotAllowed();\r\n        }\r\n        _;\r\n    }\r\n\r\n    constructor(ICurveVoter _curveVoter) {\r\n        curveVoter = _curveVoter;\r\n        USDT.approve(address(TRICRYPTO), type(uint256).max);\r\n        WETH.approve(address(CRVETH), type(uint256).max);\r\n    }\r\n\r\n    function setAllowedHarvester(address account, bool allowed) external onlyOwner {\r\n        allowedHarvesters[account] = allowed;\r\n    }\r\n\r\n    function harvest(uint256 minAmountOut) external onlyAllowedHarvesters returns (uint256 amountOut) {\r\n        uint256 crvAmount = curveVoter.claim(address(this));\r\n\r\n        if (crvAmount != 0) {\r\n            amountOut = _harvest(crvAmount, minAmountOut);\r\n        }\r\n    }\r\n\r\n    function harvestAll(uint256 minAmountOut) external onlyAllowedHarvesters returns (uint256 amountOut) {\r\n        uint256 crvAmount = curveVoter.claimAll(address(this));\r\n\r\n        if (crvAmount != 0) {\r\n            amountOut = _harvest(crvAmount, minAmountOut);\r\n        }\r\n    }\r\n\r\n    function _harvest(uint256 crvAmount, uint256 minAmountOut) private returns (uint256 amountOut) {\r\n        // 3CRV -> USDT\r\n        CRV3POOL.remove_liquidity_one_coin(crvAmount, 2, 0);\r\n\r\n        // USDT -> WETH\r\n        TRICRYPTO.exchange(0, 2, USDT.balanceOf(address(this)), 0);\r\n\r\n        // WETH -> CRV\r\n        amountOut = CRVETH.exchange(0, 1, WETH.balanceOf(address(this)), 0);\r\n\r\n        if (amountOut < minAmountOut) {\r\n            revert InsufficientOutput();\r\n        }\r\n\r\n        CRV.transfer(address(curveVoter), amountOut);\r\n        curveVoter.lock();\r\n    }\r\n}\r\n"
    }
  }
}}