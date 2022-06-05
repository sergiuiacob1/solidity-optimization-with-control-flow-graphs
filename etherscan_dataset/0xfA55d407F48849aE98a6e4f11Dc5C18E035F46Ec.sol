{{
  "language": "Solidity",
  "sources": {
    "AutonomousDripper.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport \"ConfirmedOwner.sol\";\nimport \"KeeperCompatible.sol\";\nimport \"VestingWallet.sol\";\nimport \"Pausable.sol\";\n\n/**\n * @title The AutonomousDripper Contract\n * @author gosuto.eth\n * @notice A Chainlink Keeper-compatible version of OpenZeppelin's\n * VestingWallet; removing the need to monitor the interval and/or call release\n * manually. Also adds a (transferable) owner that can set the address of the\n * keeper's registry, pause/unpause the contract and sweep all ether/ERC-20\n * tokens.\n * Takes strong inspiration from https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/upkeeps/EthBalanceMonitor.sol\n */\ncontract AutonomousDripper is VestingWallet, KeeperCompatibleInterface, ConfirmedOwner, Pausable {\n    event EtherSwept(uint256 amount);\n    event ERC20Swept(address indexed token, uint256 amount);\n    event KeeperRegistryAddressUpdated(address oldAddress, address newAddress);\n\n    error OnlyKeeperRegistry();\n\n    uint public lastTimestamp;\n    uint public immutable interval;\n    address[] public assetsWatchlist;\n    address private _keeperRegistryAddress;\n\n    constructor(\n        address initialOwner,\n        address beneficiaryAddress,\n        uint64 startTimestamp,\n        uint64 durationSeconds,\n        uint intervalSeconds,\n        address[] memory watchlistAddresses,\n        address keeperRegistryAddress\n    ) VestingWallet(\n        beneficiaryAddress,\n        startTimestamp,\n        durationSeconds\n    ) ConfirmedOwner(\n        initialOwner\n    ) {\n        lastTimestamp = startTimestamp;\n        interval = intervalSeconds;\n        assetsWatchlist = watchlistAddresses;\n        _keeperRegistryAddress = keeperRegistryAddress;\n    }\n\n    /**\n     * @dev Setter for the list of ERC-20 token addresses to consider for\n     * releasing. Can only be called by the current owner.\n     */\n    function setAssetsWatchlist(address[] calldata newAssetsWatchlist) public virtual onlyOwner {\n        assetsWatchlist = newAssetsWatchlist;\n    }\n\n    /**\n     * @dev Loop over the assetsWatchlist and check their local balance.\n     * Returns a filtered version of the assetsWatchlist for which the local\n     * balance is greater than zero.\n     */\n    function _getAssetsHeld() internal view returns (address[] memory) {\n        address[] memory _assetsHeld = new address[](assetsWatchlist.length);\n        uint256 count = 0;\n        for (uint idx = 0; idx < assetsWatchlist.length; idx++) {\n            uint256 balance = IERC20(assetsWatchlist[idx]).balanceOf(address(this));\n            if (balance > 0) {\n                _assetsHeld[count] = assetsWatchlist[idx];\n                count++;\n            }\n        }\n        if (count != assetsWatchlist.length) {\n            // truncate length of _assetsHeld array by altering first slot\n            assembly {\n                mstore(_assetsHeld, count)\n            }\n        }\n        return _assetsHeld;\n    }\n\n    /**\n     * @dev Runs off-chain at every block to determine if the `performUpkeep`\n     * function should be called on-chain.\n     */\n    function checkUpkeep(bytes calldata) external view override whenNotPaused returns (\n        bool upkeepNeeded, bytes memory checkData\n    ) {\n        if ((block.timestamp - lastTimestamp) > interval) {\n            address[] memory assetsHeld = _getAssetsHeld();\n            if (assetsHeld.length > 0) {\n                return (true, abi.encode(assetsHeld));\n            }\n        }\n    }\n\n    /**\n     * @dev Contains the logic that should be executed on-chain when\n     * `checkUpkeep` returns true.\n     */\n    function performUpkeep(bytes calldata performData) external override onlyKeeperRegistry whenNotPaused {\n        if ((block.timestamp - lastTimestamp) > interval) {\n            address[] memory assetsHeld = abi.decode(performData, (address[]));\n            bool dripped = false;\n            for (uint idx = 0; idx < assetsHeld.length; idx++) {\n                if (IERC20(assetsHeld[idx]).balanceOf(address(this)) > 0) {\n                    VestingWallet.release(assetsHeld[idx]);\n                    dripped = true;\n                }\n            }\n            if (dripped) {\n                lastTimestamp = block.timestamp;\n            }\n        }\n    }\n\n    /**\n     * @dev Sweep the full contract's ether balance to the current owner. Can\n     * only be called by the current owner.\n     */\n    function sweep() public virtual onlyOwner {\n        uint256 balance = address(this).balance;\n        emit EtherSwept(balance);\n        Address.sendValue(payable(super.owner()), balance);\n    }\n\n    /**\n     * @dev Sweep the full contract's balance for an ERC-20 token to the\n     * current owner. Can only be called by the current owner.\n     */\n    function sweep(address token) public virtual onlyOwner {\n        uint256 balance = IERC20(token).balanceOf(address(this));\n        emit ERC20Swept(token, balance);\n        SafeERC20.safeTransfer(IERC20(token), super.owner(), balance);\n    }\n\n    /**\n    * @dev Getter for the keeper registry address.\n    */\n    function getKeeperRegistryAddress() external view returns (address keeperRegistryAddress) {\n        return _keeperRegistryAddress;\n    }\n\n    /**\n    * @dev Setter for the keeper registry address.\n    */\n    function setKeeperRegistryAddress(address keeperRegistryAddress) public onlyOwner {\n        emit KeeperRegistryAddressUpdated(_keeperRegistryAddress, keeperRegistryAddress);\n        _keeperRegistryAddress = keeperRegistryAddress;\n    }\n\n    /**\n    * @dev Pauses the contract, which prevents executing performUpkeep.\n    */\n    function pause() external onlyOwner {\n        _pause();\n    }\n\n    /**\n    * @dev Unpauses the contract.\n    */\n    function unpause() external onlyOwner {\n        _unpause();\n    }\n\n    /**\n     * @dev Release the native token (ether) that have already vested.\n     *\n     * Emits a {TokensReleased} event.\n     */\n    function release() public override onlyOwner {\n        VestingWallet.release();\n    }\n\n    /**\n     * @dev Release the tokens that have already vested.\n     *\n     * Emits a {TokensReleased} event.\n     */\n    function release(address token) public override onlyOwner {\n        VestingWallet.release(token);\n    }\n\n    modifier onlyKeeperRegistry() {\n        if (msg.sender != _keeperRegistryAddress) {\n            revert OnlyKeeperRegistry();\n        }\n        _;\n    }\n}\n"
    },
    "ConfirmedOwner.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"ConfirmedOwnerWithProposal.sol\";\n\n/**\n * @title The ConfirmedOwner contract\n * @notice A contract with helpers for basic contract ownership.\n */\ncontract ConfirmedOwner is ConfirmedOwnerWithProposal {\n  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}\n}\n"
    },
    "ConfirmedOwnerWithProposal.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"OwnableInterface.sol\";\n\n/**\n * @title The ConfirmedOwner contract\n * @notice A contract with helpers for basic contract ownership.\n */\ncontract ConfirmedOwnerWithProposal is OwnableInterface {\n  address private s_owner;\n  address private s_pendingOwner;\n\n  event OwnershipTransferRequested(address indexed from, address indexed to);\n  event OwnershipTransferred(address indexed from, address indexed to);\n\n  constructor(address newOwner, address pendingOwner) {\n    require(newOwner != address(0), \"Cannot set owner to zero\");\n\n    s_owner = newOwner;\n    if (pendingOwner != address(0)) {\n      _transferOwnership(pendingOwner);\n    }\n  }\n\n  /**\n   * @notice Allows an owner to begin transferring ownership to a new address,\n   * pending.\n   */\n  function transferOwnership(address to) public override onlyOwner {\n    _transferOwnership(to);\n  }\n\n  /**\n   * @notice Allows an ownership transfer to be completed by the recipient.\n   */\n  function acceptOwnership() external override {\n    require(msg.sender == s_pendingOwner, \"Must be proposed owner\");\n\n    address oldOwner = s_owner;\n    s_owner = msg.sender;\n    s_pendingOwner = address(0);\n\n    emit OwnershipTransferred(oldOwner, msg.sender);\n  }\n\n  /**\n   * @notice Get the current owner\n   */\n  function owner() public view override returns (address) {\n    return s_owner;\n  }\n\n  /**\n   * @notice validate, transfer ownership, and emit relevant events\n   */\n  function _transferOwnership(address to) private {\n    require(to != msg.sender, \"Cannot transfer to self\");\n\n    s_pendingOwner = to;\n\n    emit OwnershipTransferRequested(s_owner, to);\n  }\n\n  /**\n   * @notice validate access\n   */\n  function _validateOwnership() internal view {\n    require(msg.sender == s_owner, \"Only callable by owner\");\n  }\n\n  /**\n   * @notice Reverts if called by anyone other than the contract owner.\n   */\n  modifier onlyOwner() {\n    _validateOwnership();\n    _;\n  }\n}\n"
    },
    "OwnableInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface OwnableInterface {\n  function owner() external returns (address);\n\n  function transferOwnership(address recipient) external;\n\n  function acceptOwnership() external;\n}\n"
    },
    "KeeperCompatible.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"KeeperBase.sol\";\nimport \"KeeperCompatibleInterface.sol\";\n\nabstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}\n"
    },
    "KeeperBase.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract KeeperBase {\n  error OnlySimulatedBackend();\n\n  /**\n   * @notice method that allows it to be simulated via eth_call by checking that\n   * the sender is the zero address.\n   */\n  function preventExecution() internal view {\n    if (tx.origin != address(0)) {\n      revert OnlySimulatedBackend();\n    }\n  }\n\n  /**\n   * @notice modifier that allows it to be simulated via eth_call by checking\n   * that the sender is the zero address.\n   */\n  modifier cannotExecute() {\n    preventExecution();\n    _;\n  }\n}\n"
    },
    "KeeperCompatibleInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface KeeperCompatibleInterface {\n  /**\n   * @notice method that is simulated by the keepers to see if any work actually\n   * needs to be performed. This method does does not actually need to be\n   * executable, and since it is only ever simulated it can consume lots of gas.\n   * @dev To ensure that it is never called, you may want to add the\n   * cannotExecute modifier from KeeperBase to your implementation of this\n   * method.\n   * @param checkData specified in the upkeep registration so it is always the\n   * same for a registered upkeep. This can easily be broken down into specific\n   * arguments using `abi.decode`, so multiple upkeeps can be registered on the\n   * same contract and easily differentiated by the contract.\n   * @return upkeepNeeded boolean to indicate whether the keeper should call\n   * performUpkeep or not.\n   * @return performData bytes that the keeper should call performUpkeep with, if\n   * upkeep is needed. If you would like to encode data to decode later, try\n   * `abi.encode`.\n   */\n  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);\n\n  /**\n   * @notice method that is actually executed by the keepers, via the registry.\n   * The data returned by the checkUpkeep simulation will be passed into\n   * this method to actually be executed.\n   * @dev The input to this method should not be trusted, and the caller of the\n   * method should not even be restricted to any single registry. Anyone should\n   * be able call it, and the input should be validated, there is no guarantee\n   * that the data passed in is the performData returned from checkUpkeep. This\n   * could happen due to malicious keepers, racing keepers, or simply a state\n   * change while the performUpkeep transaction is waiting for confirmation.\n   * Always validate the data passed in.\n   * @param performData is the data which was passed back from the checkData\n   * simulation. If it is encoded, it can easily be decoded into other types by\n   * calling `abi.decode`. This data should not be trusted, and should be\n   * validated against the contract's current state.\n   */\n  function performUpkeep(bytes calldata performData) external;\n}\n"
    },
    "VestingWallet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (finance/VestingWallet.sol)\npragma solidity ^0.8.0;\n\nimport \"SafeERC20.sol\";\nimport \"Address.sol\";\nimport \"Context.sol\";\nimport \"Math.sol\";\n\n/**\n * @title VestingWallet\n * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens\n * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.\n * The vesting schedule is customizable through the {vestedAmount} function.\n *\n * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.\n * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)\n * be immediately releasable.\n */\ncontract VestingWallet is Context {\n    event EtherReleased(uint256 amount);\n    event ERC20Released(address indexed token, uint256 amount);\n\n    uint256 private _released;\n    mapping(address => uint256) private _erc20Released;\n    address private immutable _beneficiary;\n    uint64 private immutable _start;\n    uint64 private immutable _duration;\n\n    /**\n     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.\n     */\n    constructor(\n        address beneficiaryAddress,\n        uint64 startTimestamp,\n        uint64 durationSeconds\n    ) {\n        require(beneficiaryAddress != address(0), \"VestingWallet: beneficiary is zero address\");\n        _beneficiary = beneficiaryAddress;\n        _start = startTimestamp;\n        _duration = durationSeconds;\n    }\n\n    /**\n     * @dev The contract should be able to receive Eth.\n     */\n    receive() external payable virtual {}\n\n    /**\n     * @dev Getter for the beneficiary address.\n     */\n    function beneficiary() public view virtual returns (address) {\n        return _beneficiary;\n    }\n\n    /**\n     * @dev Getter for the start timestamp.\n     */\n    function start() public view virtual returns (uint256) {\n        return _start;\n    }\n\n    /**\n     * @dev Getter for the vesting duration.\n     */\n    function duration() public view virtual returns (uint256) {\n        return _duration;\n    }\n\n    /**\n     * @dev Amount of eth already released\n     */\n    function released() public view virtual returns (uint256) {\n        return _released;\n    }\n\n    /**\n     * @dev Amount of token already released\n     */\n    function released(address token) public view virtual returns (uint256) {\n        return _erc20Released[token];\n    }\n\n    /**\n     * @dev Release the native token (ether) that have already vested.\n     *\n     * Emits a {TokensReleased} event.\n     */\n    function release() public virtual {\n        uint256 releasable = vestedAmount(uint64(block.timestamp)) - released();\n        _released += releasable;\n        emit EtherReleased(releasable);\n        Address.sendValue(payable(beneficiary()), releasable);\n    }\n\n    /**\n     * @dev Release the tokens that have already vested.\n     *\n     * Emits a {TokensReleased} event.\n     */\n    function release(address token) public virtual {\n        uint256 releasable = vestedAmount(token, uint64(block.timestamp)) - released(token);\n        _erc20Released[token] += releasable;\n        emit ERC20Released(token, releasable);\n        SafeERC20.safeTransfer(IERC20(token), beneficiary(), releasable);\n    }\n\n    /**\n     * @dev Calculates the amount of ether that has already vested. Default implementation is a linear vesting curve.\n     */\n    function vestedAmount(uint64 timestamp) public view virtual returns (uint256) {\n        return _vestingSchedule(address(this).balance + released(), timestamp);\n    }\n\n    /**\n     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.\n     */\n    function vestedAmount(address token, uint64 timestamp) public view virtual returns (uint256) {\n        return _vestingSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);\n    }\n\n    /**\n     * @dev Virtual implementation of the vesting formula. This returns the amout vested, as a function of time, for\n     * an asset given its total historical allocation.\n     */\n    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {\n        if (timestamp < start()) {\n            return 0;\n        } else if (timestamp > start() + duration()) {\n            return totalAllocation;\n        } else {\n            return (totalAllocation * (timestamp - start())) / duration();\n        }\n    }\n}\n"
    },
    "SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC20.sol\";\nimport \"Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "Math.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Standard math utilities missing in the Solidity language.\n */\nlibrary Math {\n    /**\n     * @dev Returns the largest of two numbers.\n     */\n    function max(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a >= b ? a : b;\n    }\n\n    /**\n     * @dev Returns the smallest of two numbers.\n     */\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a < b ? a : b;\n    }\n\n    /**\n     * @dev Returns the average of two numbers. The result is rounded towards\n     * zero.\n     */\n    function average(uint256 a, uint256 b) internal pure returns (uint256) {\n        // (a + b) / 2 can overflow.\n        return (a & b) + (a ^ b) / 2;\n    }\n\n    /**\n     * @dev Returns the ceiling of the division of two numbers.\n     *\n     * This differs from standard division with `/` in that it rounds up instead\n     * of rounding down.\n     */\n    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {\n        // (a + b - 1) / b can overflow on addition, so we distribute.\n        return a / b + (a % b == 0 ? 0 : 1);\n    }\n}\n"
    },
    "Pausable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"Context.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\nabstract contract Pausable is Context {\n    /**\n     * @dev Emitted when the pause is triggered by `account`.\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by `account`.\n     */\n    event Unpaused(address account);\n\n    bool private _paused;\n\n    /**\n     * @dev Initializes the contract in unpaused state.\n     */\n    constructor() {\n        _paused = false;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view virtual returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    modifier whenNotPaused() {\n        require(!paused(), \"Pausable: paused\");\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    modifier whenPaused() {\n        require(paused(), \"Pausable: not paused\");\n        _;\n    }\n\n    /**\n     * @dev Triggers stopped state.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    function _pause() internal virtual whenNotPaused {\n        _paused = true;\n        emit Paused(_msgSender());\n    }\n\n    /**\n     * @dev Returns to normal state.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    function _unpause() internal virtual whenPaused {\n        _paused = false;\n        emit Unpaused(_msgSender());\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
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