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
      "runs": 1000
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
    "contracts/base/PortalBaseV1.sol": {
      "content": "/// Copyright (C) 2022 Portals.fi\n\n/// @author Portals.fi\n/// @notice Base contract inherited by Portal Factories\n\n/// SPDX-License-Identifier: GPL-3.0\npragma solidity 0.8.11;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"../libraries/solmate/utils/SafeTransferLib.sol\";\nimport \"../interface/IWETH.sol\";\nimport \"../interface/IPortalFactory.sol\";\nimport \"../interface/IPortalRegistry.sol\";\n\nabstract contract PortalBaseV1 is Ownable {\n    using SafeTransferLib for address;\n    using SafeTransferLib for ERC20;\n\n    // Active status of this contract. If false, contract is active (i.e un-paused)\n    bool public paused;\n\n    // Fee in basis points (bps)\n    uint256 public fee;\n\n    // Address of the Portal Registry\n    IPortalRegistry public registry;\n\n    // Address of the exchange used for swaps\n    address public immutable exchange;\n\n    // Address of the wrapped network token (e.g. WETH, wMATIC, wFTM, wAVAX, etc.)\n    address public immutable wrappedNetworkToken;\n\n    // Circuit breaker\n    modifier pausable() {\n        require(!paused, \"Paused\");\n        _;\n    }\n\n    constructor(\n        bytes32 protocolId,\n        PortalType portalType,\n        IPortalRegistry _registry,\n        address _exchange,\n        address _wrappedNetworkToken,\n        uint256 _fee\n    ) {\n        wrappedNetworkToken = _wrappedNetworkToken;\n        setFee(_fee);\n        exchange = _exchange;\n        registry = _registry;\n        registry.addPortal(address(this), portalType, protocolId);\n        transferOwnership(registry.owner());\n    }\n\n    /// @notice Transfers tokens or the network token from the caller to this contract\n    /// @param token The address of the token to transfer (address(0) if network token)\n    /// @param quantity The quantity of tokens to transfer from the caller\n    /// @dev quantity must == msg.value when token == address(0)\n    /// @dev msg.value must == 0 when token != address(0)\n    /// @return The quantity of tokens or network tokens transferred from the caller to this contract\n    function _transferFromCaller(address token, uint256 quantity)\n        internal\n        virtual\n        returns (uint256)\n    {\n        if (token == address(0)) {\n            require(\n                msg.value > 0 && msg.value == quantity,\n                \"Invalid quantity or msg.value\"\n            );\n\n            return msg.value;\n        }\n\n        require(\n            quantity > 0 && msg.value == 0,\n            \"Invalid quantity or msg.value\"\n        );\n\n        ERC20(token).safeTransferFrom(msg.sender, address(this), quantity);\n\n        return quantity;\n    }\n\n    /// @notice Returns the quantity of tokens or network tokens after accounting for the fee\n    /// @param quantity The quantity of tokens to subtract the fee from\n    /// @param feeBps The fee in basis points (BPS)\n    /// @return The quantity of tokens or network tokens to transact with less the fee\n    function _getFeeAmount(uint256 quantity, uint256 feeBps)\n        internal\n        pure\n        returns (uint256)\n    {\n        return quantity - (quantity * feeBps) / 10000;\n    }\n\n    /// @notice Executes swap or portal data at the target address\n    /// @param sellToken The sell token\n    /// @param sellAmount The quantity of sellToken (in sellToken base units) to send\n    /// @param buyToken The buy token\n    /// @param target The execution target for the data\n    /// @param data The swap or portal data\n    /// @return amountBought Quantity of buyToken acquired\n    function _execute(\n        address sellToken,\n        uint256 sellAmount,\n        address buyToken,\n        address target,\n        bytes memory data\n    ) internal virtual returns (uint256 amountBought) {\n        if (sellToken == buyToken) {\n            return sellAmount;\n        }\n\n        if (sellToken == address(0) && buyToken == wrappedNetworkToken) {\n            IWETH(wrappedNetworkToken).deposit{ value: sellAmount }();\n            return sellAmount;\n        }\n\n        if (sellToken == wrappedNetworkToken && buyToken == address(0)) {\n            IWETH(wrappedNetworkToken).withdraw(sellAmount);\n            return sellAmount;\n        }\n\n        uint256 valueToSend;\n        if (sellToken == address(0)) {\n            valueToSend = sellAmount;\n        } else {\n            _approve(sellToken, target, sellAmount);\n        }\n\n        uint256 initialBalance = _getBalance(address(this), buyToken);\n\n        require(\n            target == exchange || registry.isPortal(target),\n            \"Unauthorized target\"\n        );\n        (bool success, bytes memory returnData) = target.call{\n            value: valueToSend\n        }(data);\n        require(success, string(returnData));\n\n        amountBought = _getBalance(address(this), buyToken) - initialBalance;\n\n        require(amountBought > 0, \"Invalid execution\");\n    }\n\n    /// @notice Get the token or network token balance of an account\n    /// @param account The owner of the tokens or network tokens whose balance is being queried\n    /// @param token The address of the token (address(0) if network token)\n    /// @return The owner's token or network token balance\n    function _getBalance(address account, address token)\n        internal\n        view\n        returns (uint256)\n    {\n        if (token == address(0)) {\n            return account.balance;\n        } else {\n            return ERC20(token).balanceOf(account);\n        }\n    }\n\n    /// @notice Approve a token for spending with finite allowance\n    /// @param token The ERC20 token to approve\n    /// @param spender The spender of the token\n    /// @param amount The allowance to grant to the spender\n    function _approve(\n        address token,\n        address spender,\n        uint256 amount\n    ) internal {\n        ERC20 _token = ERC20(token);\n        _token.safeApprove(spender, 0);\n        _token.safeApprove(spender, amount);\n    }\n\n    /// @notice Collects tokens or network tokens from this contract\n    /// @param tokens An array of the tokens to withdraw (address(0) if network token)\n    function collect(address[] calldata tokens) external {\n        address collector = registry.collector();\n\n        for (uint256 i = 0; i < tokens.length; i++) {\n            uint256 qty;\n\n            if (tokens[i] == address(0)) {\n                qty = address(this).balance;\n                collector.safeTransferETH(qty);\n            } else {\n                qty = ERC20(tokens[i]).balanceOf(address(this));\n                ERC20(tokens[i]).safeTransfer(collector, qty);\n            }\n        }\n    }\n\n    /// @dev Pause or unpause the contract\n    function pause() external onlyOwner {\n        paused = !paused;\n    }\n\n    /// @notice Sets the fee\n    /// @param _fee The new fee amount between 0.06-1%\n    function setFee(uint256 _fee) public onlyOwner {\n        require(_fee >= 6 && _fee <= 100, \"Invalid Fee\");\n        fee = _fee;\n    }\n\n    /// @notice Updates the registry\n    /// @param _registry The address of the new registry\n    function updateRegistry(IPortalRegistry _registry) external onlyOwner {\n        registry = _registry;\n    }\n\n    /// @notice Reverts if networks tokens are sent directly to this contract\n    receive() external payable {\n        require(msg.sender != tx.origin);\n    }\n}\n"
    },
    "contracts/interface/IPortalFactory.sol": {
      "content": "/// SPDX-License-Identifier: GPL-3.0\n\npragma solidity 0.8.11;\n\nimport \"./IPortalRegistry.sol\";\n\ninterface IPortalFactory {\n    function fee() external view returns (uint256 fee);\n\n    function registry() external view returns (IPortalRegistry registry);\n}\n"
    },
    "contracts/interface/IPortalRegistry.sol": {
      "content": "/// SPDX-License-Identifier: GPL-3.0\n\npragma solidity 0.8.11;\n\nenum PortalType {\n    IN,\n    OUT\n}\n\ninterface IPortalRegistry {\n    function addPortal(\n        address portal,\n        PortalType portalType,\n        bytes32 protocolId\n    ) external;\n\n    function addPortalFactory(\n        address portalFactory,\n        PortalType portalType,\n        bytes32 protocolId\n    ) external;\n\n    function removePortal(bytes32 protocolId, PortalType portalType) external;\n\n    function owner() external view returns (address owner);\n\n    function registrars(address origin) external view returns (bool isDeployer);\n\n    function collector() external view returns (address collector);\n\n    function isPortal(address portal) external view returns (bool isPortal);\n}\n"
    },
    "contracts/interface/IWETH.sol": {
      "content": "/// SPDX-License-Identifier: GPL-3.0\n\npragma solidity 0.8.11;\n\ninterface IWETH {\n    function deposit() external payable;\n\n    function withdraw(uint256 wad) external;\n}"
    },
    "contracts/libraries/solmate/tokens/ERC20.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)\n/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)\n/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.\nabstract contract ERC20 {\n    /*//////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    event Approval(\n        address indexed owner,\n        address indexed spender,\n        uint256 amount\n    );\n\n    /*//////////////////////////////////////////////////////////////\n                            METADATA STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    string public name;\n\n    string public symbol;\n\n    uint8 public immutable decimals;\n\n    /*//////////////////////////////////////////////////////////////\n                              ERC20 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 public totalSupply;\n\n    mapping(address => uint256) public balanceOf;\n\n    mapping(address => mapping(address => uint256)) public allowance;\n\n    /*//////////////////////////////////////////////////////////////\n                            EIP-2612 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 internal immutable INITIAL_CHAIN_ID;\n\n    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;\n\n    mapping(address => uint256) public nonces;\n\n    /*//////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(\n        string memory _name,\n        string memory _symbol,\n        uint8 _decimals\n    ) {\n        name = _name;\n        symbol = _symbol;\n        decimals = _decimals;\n\n        INITIAL_CHAIN_ID = block.chainid;\n        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                               ERC20 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 amount)\n        public\n        virtual\n        returns (bool)\n    {\n        allowance[msg.sender][spender] = amount;\n\n        emit Approval(msg.sender, spender, amount);\n\n        return true;\n    }\n\n    function transfer(address to, uint256 amount)\n        public\n        virtual\n        returns (bool)\n    {\n        balanceOf[msg.sender] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(msg.sender, to, amount);\n\n        return true;\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) public virtual returns (bool) {\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\n\n        if (allowed != type(uint256).max)\n            allowance[from][msg.sender] = allowed - amount;\n\n        balanceOf[from] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(from, to, amount);\n\n        return true;\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                             EIP-2612 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) public virtual {\n        require(deadline >= block.timestamp, \"PERMIT_DEADLINE_EXPIRED\");\n\n        // Unchecked because the only math done is incrementing\n        // the owner's nonce which cannot realistically overflow.\n        unchecked {\n            address recoveredAddress = ecrecover(\n                keccak256(\n                    abi.encodePacked(\n                        \"\\x19\\x01\",\n                        DOMAIN_SEPARATOR(),\n                        keccak256(\n                            abi.encode(\n                                keccak256(\n                                    \"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\"\n                                ),\n                                owner,\n                                spender,\n                                value,\n                                nonces[owner]++,\n                                deadline\n                            )\n                        )\n                    )\n                ),\n                v,\n                r,\n                s\n            );\n\n            require(\n                recoveredAddress != address(0) && recoveredAddress == owner,\n                \"INVALID_SIGNER\"\n            );\n\n            allowance[recoveredAddress][spender] = value;\n        }\n\n        emit Approval(owner, spender, value);\n    }\n\n    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {\n        return\n            block.chainid == INITIAL_CHAIN_ID\n                ? INITIAL_DOMAIN_SEPARATOR\n                : computeDomainSeparator();\n    }\n\n    function computeDomainSeparator() internal view virtual returns (bytes32) {\n        return\n            keccak256(\n                abi.encode(\n                    keccak256(\n                        \"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"\n                    ),\n                    keccak256(bytes(name)),\n                    keccak256(\"1\"),\n                    block.chainid,\n                    address(this)\n                )\n            );\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                        INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 amount) internal virtual {\n        totalSupply += amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(address(0), to, amount);\n    }\n\n    function _burn(address from, uint256 amount) internal virtual {\n        balanceOf[from] -= amount;\n\n        // Cannot underflow because a user's balance\n        // will never be larger than the total supply.\n        unchecked {\n            totalSupply -= amount;\n        }\n\n        emit Transfer(from, address(0), amount);\n    }\n}\n"
    },
    "contracts/libraries/solmate/utils/SafeTransferLib.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\nimport { ERC20 } from \"../tokens/ERC20.sol\";\n\n/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)\n/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.\n/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.\nlibrary SafeTransferLib {\n    event Debug(bool one, bool two, uint256 retsize);\n\n    /*//////////////////////////////////////////////////////////////\n                             ETH OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    function safeTransferETH(address to, uint256 amount) internal {\n        bool success;\n\n        assembly {\n            // Transfer the ETH and store if it succeeded or not.\n            success := call(gas(), to, amount, 0, 0, 0, 0)\n        }\n\n        require(success, \"ETH_TRANSFER_FAILED\");\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                            ERC20 OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    function safeTransferFrom(\n        ERC20 token,\n        address from,\n        address to,\n        uint256 amount\n    ) internal {\n        bool success;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata into memory, beginning with the function selector.\n            mstore(\n                freeMemoryPointer,\n                0x23b872dd00000000000000000000000000000000000000000000000000000000\n            )\n            mstore(add(freeMemoryPointer, 4), from) // Append the \"from\" argument.\n            mstore(add(freeMemoryPointer, 36), to) // Append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 68), amount) // Append the \"amount\" argument.\n\n            success := and(\n                // Set success to whether the call reverted, if not we check it either\n                // returned exactly 1 (can't just be non-zero data), or had no return data.\n                or(\n                    and(eq(mload(0), 1), gt(returndatasize(), 31)),\n                    iszero(returndatasize())\n                ),\n                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.\n                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.\n                // Counterintuitively, this call must be positioned second to the or() call in the\n                // surrounding and() call or else returndatasize() will be zero during the computation.\n                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)\n            )\n        }\n\n        require(success, \"TRANSFER_FROM_FAILED\");\n    }\n\n    function safeTransfer(\n        ERC20 token,\n        address to,\n        uint256 amount\n    ) internal {\n        bool success;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata into memory, beginning with the function selector.\n            mstore(\n                freeMemoryPointer,\n                0xa9059cbb00000000000000000000000000000000000000000000000000000000\n            )\n            mstore(add(freeMemoryPointer, 4), to) // Append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 36), amount) // Append the \"amount\" argument.\n\n            success := and(\n                // Set success to whether the call reverted, if not we check it either\n                // returned exactly 1 (can't just be non-zero data), or had no return data.\n                or(\n                    and(eq(mload(0), 1), gt(returndatasize(), 31)),\n                    iszero(returndatasize())\n                ),\n                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.\n                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.\n                // Counterintuitively, this call must be positioned second to the or() call in the\n                // surrounding and() call or else returndatasize() will be zero during the computation.\n                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)\n            )\n        }\n\n        require(success, \"TRANSFER_FAILED\");\n    }\n\n    function safeApprove(\n        ERC20 token,\n        address to,\n        uint256 amount\n    ) internal {\n        bool success;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata into memory, beginning with the function selector.\n            mstore(\n                freeMemoryPointer,\n                0x095ea7b300000000000000000000000000000000000000000000000000000000\n            )\n            mstore(add(freeMemoryPointer, 4), to) // Append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 36), amount) // Append the \"amount\" argument.\n\n            success := and(\n                // Set success to whether the call reverted, if not we check it either\n                // returned exactly 1 (can't just be non-zero data), or had no return data.\n                or(\n                    and(eq(mload(0), 1), gt(returndatasize(), 31)),\n                    iszero(returndatasize())\n                ),\n                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.\n                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.\n                // Counterintuitively, this call must be positioned second to the or() call in the\n                // surrounding and() call or else returndatasize() will be zero during the computation.\n                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)\n            )\n        }\n\n        require(success, \"APPROVE_FAILED\");\n    }\n}\n"
    },
    "contracts/uniswapV2/UniswapV2PortalOut.sol": {
      "content": "/// Copyright (C) 2022 Portals.fi\n\n/// @author Portals.fi\n/// @notice This contract removes liquidity from Uniswap V2-like pools into any ERC20 token or the network token.\n\n/// SPDX-License-Identifier: GPL-3.0\npragma solidity 0.8.11;\n\nimport \"../base/PortalBaseV1.sol\";\nimport \"./interface/IUniswapV2Factory.sol\";\nimport \"./interface/IUniswapV2Router.sol\";\nimport \"./interface/IUniswapV2Pair.sol\";\nimport \"../interface/IPortalRegistry.sol\";\n\ncontract UniswapV2PortalOut is PortalBaseV1 {\n    using SafeTransferLib for address;\n    using SafeTransferLib for ERC20;\n\n    uint256 internal constant DEADLINE = type(uint256).max;\n\n    /// @notice Emitted when a portal is exited\n    /// @param sellToken The ERC20 token address to spend (address(0) if network token)\n    /// @param sellAmount The quantity of sellToken to Portal out\n    /// @param buyToken The ERC20 token address to buy (address(0) if network token)\n    /// @param buyAmount The quantity of buyToken received\n    /// @param fee The fee in BPS\n    /// @param sender The  msg.sender\n    /// @param partner The front end operator address\n    event PortalOut(\n        address sellToken,\n        uint256 sellAmount,\n        address buyToken,\n        uint256 buyAmount,\n        uint256 fee,\n        address indexed sender,\n        address indexed partner\n    );\n\n    /// Thrown when insufficient liquidity is received after withdrawal\n    /// @param buyAmount The amount of liquidity received\n    /// @param minBuyAmount The minimum acceptable quantity of liquidity received\n    error InsufficientBuy(uint256 buyAmount, uint256 minBuyAmount);\n\n    constructor(\n        bytes32 protocolId,\n        PortalType portalType,\n        IPortalRegistry registry,\n        address exchange,\n        address wrappedNetworkToken,\n        uint256 fee\n    )\n        PortalBaseV1(\n            protocolId,\n            portalType,\n            registry,\n            exchange,\n            wrappedNetworkToken,\n            fee\n        )\n    {}\n\n    /// @notice Remove liquidity from Uniswap V2-like pools into network tokens/ERC20 tokens\n    /// @param sellToken The pool (i.e. pair) address\n    /// @param sellAmount The quantity of sellToken to Portal out\n    /// @param buyToken The ERC20 token address to buy (address(0) if network token)\n    /// @param minBuyAmount The minimum quantity of buyTokens to receive. Reverts otherwise\n    /// @param target The excecution target for the swaps\n    /// @param data  The encoded calls for the buyToken swaps\n    /// @param partner The front end operator address\n    /// @return buyAmount The quantity of buyToken acquired\n    function portalOut(\n        address sellToken,\n        uint256 sellAmount,\n        address buyToken,\n        uint256 minBuyAmount,\n        address target,\n        bytes[] calldata data,\n        address partner,\n        IUniswapV2Router02 router\n    ) external pausable returns (uint256 buyAmount) {\n        sellAmount = _transferFromCaller(sellToken, sellAmount);\n\n        buyAmount = _remove(\n            router,\n            sellToken,\n            sellAmount,\n            buyToken,\n            target,\n            data\n        );\n\n        if (buyAmount < minBuyAmount)\n            revert InsufficientBuy(buyAmount, minBuyAmount);\n\n        buyAmount = _getFeeAmount(buyAmount, fee);\n\n        buyToken == address(0)\n            ? msg.sender.safeTransferETH(buyAmount)\n            : ERC20(buyToken).safeTransfer(msg.sender, buyAmount);\n\n        emit PortalOut(\n            sellToken,\n            sellAmount,\n            buyToken,\n            buyAmount,\n            fee,\n            msg.sender,\n            partner\n        );\n    }\n\n    /// @notice Removes both tokens from the pool and swaps for buyToken\n    /// @param router The router belonging to the protocol to remove liquidity from\n    /// @param sellToken The pair address (i.e. the LP address)\n    /// @param buyToken The ERC20 token address to buy (address(0) if network token)\n    /// @param sellAmount The quantity of LP tokens to remove from the pool\n    /// @param target The excecution target for the swaps\n    /// @param data  The encoded calls for the buyToken swaps\n    /// @return buyAmount The quantity of buyToken acquired\n    function _remove(\n        IUniswapV2Router02 router,\n        address sellToken,\n        uint256 sellAmount,\n        address buyToken,\n        address target,\n        bytes[] calldata data\n    ) internal returns (uint256 buyAmount) {\n        IUniswapV2Pair pair = IUniswapV2Pair(sellToken);\n\n        _approve(sellToken, address(router), sellAmount);\n\n        address token0 = pair.token0();\n        address token1 = pair.token1();\n\n        (uint256 amount0, uint256 amount1) = router.removeLiquidity(\n            token0,\n            token1,\n            sellAmount,\n            1,\n            1,\n            address(this),\n            DEADLINE\n        );\n\n        buyAmount = _execute(token0, amount0, buyToken, target, data[0]);\n        buyAmount += _execute(token1, amount1, buyToken, target, data[1]);\n    }\n}\n"
    },
    "contracts/uniswapV2/interface/IUniswapV2Factory.sol": {
      "content": "/// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.0;\ninterface IUniswapV2Factory {\n    function getPair(address tokenA, address tokenB)\n        external\n        view\n        returns (address);\n}"
    },
    "contracts/uniswapV2/interface/IUniswapV2Pair.sol": {
      "content": "/// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.0;\n\ninterface IUniswapV2Pair {\n    function token0() external pure returns (address);\n\n    function token1() external pure returns (address);\n\n    function getReserves()\n        external\n        view\n        returns (\n            uint112 _reserve0,\n            uint112 _reserve1,\n            uint32 _blockTimestampLast\n        );\n}\n"
    },
    "contracts/uniswapV2/interface/IUniswapV2Router.sol": {
      "content": "/// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.0;\n\ninterface IUniswapV2Router02 {\n    function addLiquidity(\n        address tokenA,\n        address tokenB,\n        uint256 amountADesired,\n        uint256 amountBDesired,\n        uint256 amountAMin,\n        uint256 amountBMin,\n        address to,\n        uint256 deadline\n    )\n        external\n        returns (\n            uint256 amountA,\n            uint256 amountB,\n            uint256 liquidity\n        );\n\n    function removeLiquidity(\n        address tokenA,\n        address tokenB,\n        uint256 liquidity,\n        uint256 amountAMin,\n        uint256 amountBMin,\n        address to,\n        uint256 deadline\n    ) external returns (uint256 amountA, uint256 amountB);\n\n    function swapExactTokensForTokens(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n\n    function factory() external pure returns (address);\n}\n"
    }
  }
}}