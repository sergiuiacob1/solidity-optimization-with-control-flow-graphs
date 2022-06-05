{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
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
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and make it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/governance/GovernanceToken.sol": {
      "content": "// SPDX-License-Identifier: BSD-3-Clause\npragma solidity ^0.8.6;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\n// solhint-disable const-name-snakecase\n// solhint-disable private-vars-leading-underscore\ncontract GovernanceToken is Ownable {\n  /// @notice EIP-20 token name for this token\n  string public constant name = \"DeFiHelper Governance Token\";\n\n  /// @notice EIP-20 token symbol for this token\n  string public constant symbol = \"DFH\";\n\n  /// @notice EIP-20 token decimals for this token\n  uint8 public constant decimals = 18;\n\n  /// @notice Total number of tokens in circulation\n  uint256 public totalSupply = 1_000_000_000e18; // 1 billion GovernanceToken\n\n  /// @notice Allowance amounts on behalf of others\n  mapping(address => mapping(address => uint96)) internal allowances;\n\n  /// @notice Official record of token balances for each account\n  mapping(address => uint96) internal balances;\n\n  /// @notice A record of each accounts delegate\n  mapping(address => address) public delegates;\n\n  /// @notice A checkpoint for marking number of votes from a given block\n  struct Checkpoint {\n    uint32 fromBlock;\n    uint96 votes;\n  }\n\n  /// @notice A record of votes checkpoints for each account, by index\n  mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;\n\n  /// @notice The number of checkpoints for each account\n  mapping(address => uint32) public numCheckpoints;\n\n  /// @notice The EIP-712 typehash for the contract's domain\n  bytes32 public constant DOMAIN_TYPEHASH =\n    keccak256(\"EIP712Domain(string name,uint256 chainId,address verifyingContract)\");\n\n  /// @notice The EIP-712 typehash for the delegation struct used by the contract\n  bytes32 public constant DELEGATION_TYPEHASH = keccak256(\"Delegation(address delegatee,uint256 nonce,uint256 expiry)\");\n\n  /// @notice A record of states for signing / validating signatures\n  mapping(address => uint256) public nonces;\n\n  /// @notice An event thats emitted when an account changes its delegate\n  event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);\n\n  /// @notice An event thats emitted when a delegate account's vote balance changes\n  event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);\n\n  /// @notice The standard EIP-20 transfer event\n  event Transfer(address indexed from, address indexed to, uint256 amount);\n\n  /// @notice The standard EIP-20 approval event\n  event Approval(address indexed owner, address indexed spender, uint256 amount);\n\n  /**\n   * @notice Construct a new GovernanceToken token\n   * @param account The initial account to grant all the tokens\n   */\n  constructor(address account) {\n    balances[account] = uint96(totalSupply);\n    emit Transfer(address(0), account, totalSupply);\n  }\n\n  /**\n   * @notice Creates `amount` tokens and assigns them to `account`, increasing\n   * the total supply.\n   *\n   * @param account Recipient of created token.\n   * @param amount Amount of token to be created.\n   */\n  function mint(address account, uint256 amount) public onlyOwner {\n    _mint(account, amount);\n  }\n\n  /**\n   * @param account Owner of removed token.\n   * @param amount Amount of token to be removed.\n   */\n  function burn(address account, uint256 amount) public onlyOwner {\n    _burn(account, amount);\n  }\n\n  /**\n   * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`\n   * @param account The address of the account holding the funds\n   * @param spender The address of the account spending the funds\n   * @return The number of tokens approved\n   */\n  function allowance(address account, address spender) external view returns (uint256) {\n    return allowances[account][spender];\n  }\n\n  /**\n   * @notice Approve `spender` to transfer up to `amount` from `src`\n   * @dev This will overwrite the approval amount for `spender`\n   *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)\n   * @param spender The address of the account which may transfer tokens\n   * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)\n   * @return Whether or not the approval succeeded\n   */\n  function approve(address spender, uint256 rawAmount) external returns (bool) {\n    uint96 amount;\n    if (rawAmount == 2**256 - 1) {\n      amount = 2**96 - 1;\n    } else {\n      amount = safe96(rawAmount, \"GovernanceToken::approve: amount exceeds 96 bits\");\n    }\n\n    allowances[msg.sender][spender] = amount;\n\n    emit Approval(msg.sender, spender, amount);\n    return true;\n  }\n\n  /**\n   * @notice Get the number of tokens held by the `account`\n   * @param account The address of the account to get the balance of\n   * @return The number of tokens held\n   */\n  function balanceOf(address account) external view returns (uint256) {\n    return balances[account];\n  }\n\n  /**\n   * @notice Transfer `amount` tokens from `msg.sender` to `dst`\n   * @param dst The address of the destination account\n   * @param rawAmount The number of tokens to transfer\n   * @return Whether or not the transfer succeeded\n   */\n  function transfer(address dst, uint256 rawAmount) external returns (bool) {\n    uint96 amount = safe96(rawAmount, \"GovernanceToken::transfer: amount exceeds 96 bits\");\n    _transferTokens(msg.sender, dst, amount);\n    return true;\n  }\n\n  /**\n   * @notice Transfer `amount` tokens from `src` to `dst`\n   * @param src The address of the source account\n   * @param dst The address of the destination account\n   * @param rawAmount The number of tokens to transfer\n   * @return Whether or not the transfer succeeded\n   */\n  function transferFrom(\n    address src,\n    address dst,\n    uint256 rawAmount\n  ) external returns (bool) {\n    address spender = msg.sender;\n    uint96 spenderAllowance = allowances[src][spender];\n    uint96 amount = safe96(rawAmount, \"GovernanceToken::approve: amount exceeds 96 bits\");\n\n    if (spender != src && spenderAllowance != 2**96 - 1) {\n      uint96 newAllowance = sub96(\n        spenderAllowance,\n        amount,\n        \"GovernanceToken::transferFrom: transfer amount exceeds spender allowance\"\n      );\n      allowances[src][spender] = newAllowance;\n\n      emit Approval(src, spender, newAllowance);\n    }\n\n    _transferTokens(src, dst, amount);\n    return true;\n  }\n\n  /**\n   * @notice Delegate votes from `msg.sender` to `delegatee`\n   * @param delegatee The address to delegate votes to\n   */\n  function delegate(address delegatee) public {\n    return _delegate(msg.sender, delegatee);\n  }\n\n  /**\n   * @notice Delegates votes from signatory to `delegatee`\n   * @param delegatee The address to delegate votes to\n   * @param nonce The contract state required to match the signature\n   * @param expiry The time at which to expire the signature\n   * @param v The recovery byte of the signature\n   * @param r Half of the ECDSA signature pair\n   * @param s Half of the ECDSA signature pair\n   */\n  function delegateBySig(\n    address delegatee,\n    uint256 nonce,\n    uint256 expiry,\n    uint8 v,\n    bytes32 r,\n    bytes32 s\n  ) public {\n    bytes32 domainSeparator = keccak256(\n      abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))\n    );\n    bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));\n    bytes32 digest = keccak256(abi.encodePacked(\"\\x19\\x01\", domainSeparator, structHash));\n    address signatory = ecrecover(digest, v, r, s);\n    require(signatory != address(0), \"GovernanceToken::delegateBySig: invalid signature\");\n    require(nonce == nonces[signatory]++, \"GovernanceToken::delegateBySig: invalid nonce\");\n    // solhint-disable-next-line not-rely-on-time\n    require(block.timestamp <= expiry, \"GovernanceToken::delegateBySig: signature expired\");\n    return _delegate(signatory, delegatee);\n  }\n\n  /**\n   * @notice Gets the current votes balance for `account`\n   * @param account The address to get votes balance\n   * @return The number of current votes for `account`\n   */\n  function getCurrentVotes(address account) external view returns (uint96) {\n    uint32 nCheckpoints = numCheckpoints[account];\n    return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;\n  }\n\n  /**\n   * @notice Determine the prior number of votes for an account as of a block number\n   * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.\n   * @param account The address of the account to check\n   * @param blockNumber The block number to get the vote balance at\n   * @return The number of votes the account had as of the given block\n   */\n  function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {\n    require(blockNumber < block.number, \"GovernanceToken::getPriorVotes: not yet determined\");\n\n    uint32 nCheckpoints = numCheckpoints[account];\n    if (nCheckpoints == 0) {\n      return 0;\n    }\n\n    // First check most recent balance\n    if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {\n      return checkpoints[account][nCheckpoints - 1].votes;\n    }\n\n    // Next check implicit zero balance\n    if (checkpoints[account][0].fromBlock > blockNumber) {\n      return 0;\n    }\n\n    uint32 lower = 0;\n    uint32 upper = nCheckpoints - 1;\n    while (upper > lower) {\n      uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow\n      Checkpoint memory cp = checkpoints[account][center];\n      if (cp.fromBlock == blockNumber) {\n        return cp.votes;\n      } else if (cp.fromBlock < blockNumber) {\n        lower = center;\n      } else {\n        upper = center - 1;\n      }\n    }\n    return checkpoints[account][lower].votes;\n  }\n\n  function _delegate(address delegator, address delegatee) internal {\n    address currentDelegate = delegates[delegator];\n    uint96 delegatorBalance = balances[delegator];\n    delegates[delegator] = delegatee;\n\n    emit DelegateChanged(delegator, currentDelegate, delegatee);\n\n    _moveDelegates(currentDelegate, delegatee, delegatorBalance);\n  }\n\n  function _transferTokens(\n    address src,\n    address dst,\n    uint96 amount\n  ) internal {\n    require(src != address(0), \"GovernanceToken::_transferTokens: cannot transfer from the zero address\");\n    require(dst != address(0), \"GovernanceToken::_transferTokens: cannot transfer to the zero address\");\n\n    balances[src] = sub96(balances[src], amount, \"GovernanceToken::_transferTokens: transfer amount exceeds balance\");\n    balances[dst] = add96(balances[dst], amount, \"GovernanceToken::_transferTokens: transfer amount overflows\");\n    emit Transfer(src, dst, amount);\n\n    _moveDelegates(delegates[src], delegates[dst], amount);\n  }\n\n  function _moveDelegates(\n    address srcRep,\n    address dstRep,\n    uint96 amount\n  ) internal {\n    if (srcRep != dstRep && amount > 0) {\n      if (srcRep != address(0)) {\n        uint32 srcRepNum = numCheckpoints[srcRep];\n        uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;\n        uint96 srcRepNew = sub96(srcRepOld, amount, \"GovernanceToken::_moveVotes: vote amount underflows\");\n        _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);\n      }\n\n      if (dstRep != address(0)) {\n        uint32 dstRepNum = numCheckpoints[dstRep];\n        uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;\n        uint96 dstRepNew = add96(dstRepOld, amount, \"GovernanceToken::_moveVotes: vote amount overflows\");\n        _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);\n      }\n    }\n  }\n\n  function _writeCheckpoint(\n    address delegatee,\n    uint32 nCheckpoints,\n    uint96 oldVotes,\n    uint96 newVotes\n  ) internal {\n    uint32 blockNumber = safe32(block.number, \"GovernanceToken::_writeCheckpoint: block number exceeds 32 bits\");\n\n    if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {\n      checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;\n    } else {\n      checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);\n      numCheckpoints[delegatee] = nCheckpoints + 1;\n    }\n\n    emit DelegateVotesChanged(delegatee, oldVotes, newVotes);\n  }\n\n  /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n\n     * Requirements\n     *\n     * - `account` cannot be the zero address.\n     */\n  function _mint(address account, uint256 rawAmount) internal virtual {\n    require(account != address(0), \"GovernanceToken::_mint: mint to the zero address\");\n    uint96 amount = safe96(rawAmount, \"GovernanceToken::_mint: amount exceeds 96 bits\");\n\n    totalSupply += amount;\n    balances[account] = add96(balances[account], amount, \"GovernanceToken::_mint: mint amount overflows\");\n    emit Transfer(address(0), account, amount);\n  }\n\n  /**\n   * @dev Destroys `amount` tokens from `account`, reducing the\n   * total supply.\n   *\n   * Emits a {Transfer} event with `to` set to the zero address.\n   *\n   * Requirements\n   *\n   * - `account` cannot be the zero address.\n   * - `account` must have at least `amount` tokens.\n   */\n  function _burn(address account, uint256 rawAmount) internal virtual {\n    require(account != address(0), \"GovernanceToken::_burn: burn from the zero address\");\n    uint96 amount = safe96(rawAmount, \"GovernanceToken::_burn: amount exceeds 96 bits\");\n\n    balances[account] = sub96(balances[account], amount, \"GovernanceToken::_burn: burn amount exceeds balance\");\n    totalSupply -= amount;\n    emit Transfer(account, address(0), amount);\n  }\n\n  function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {\n    require(n < 2**32, errorMessage);\n    return uint32(n);\n  }\n\n  function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {\n    require(n < 2**96, errorMessage);\n    return uint96(n);\n  }\n\n  function add96(\n    uint96 a,\n    uint96 b,\n    string memory errorMessage\n  ) internal pure returns (uint96) {\n    uint96 c = a + b;\n    require(c >= a, errorMessage);\n    return c;\n  }\n\n  function sub96(\n    uint96 a,\n    uint96 b,\n    string memory errorMessage\n  ) internal pure returns (uint96) {\n    require(b <= a, errorMessage);\n    return a - b;\n  }\n\n  function getChainId() internal view returns (uint256) {\n    uint256 chainId;\n    // solhint-disable-next-line no-inline-assembly\n    assembly {\n      chainId := chainid()\n    }\n    return chainId;\n  }\n}\n"
    },
    "contracts/investments/Vesting.sol": {
      "content": "// SPDX-License-Identifier: BSD-3-Clause\npragma solidity ^0.8.6;\n\nimport \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport \"../governance/GovernanceToken.sol\";\n\ncontract Vesting is ReentrancyGuard {\n  /// @notice Is contract initialized.\n  bool public initialized;\n\n  /// @notice Contract owner.\n  address public owner;\n\n  /// @notice Vesting token.\n  GovernanceToken public token;\n\n  /// @notice Block number of rewards distibution period finish.\n  uint256 public periodFinish;\n\n  /// @notice Distribution amount per block.\n  uint256 public rate;\n\n  /// @notice Block number of last claim.\n  uint256 public lastClaim;\n\n  event Initialized(address indexed owner);\n\n  event Distribute(address indexed recipient, uint256 amount, uint256 duration);\n\n  event Claim(uint256 amount);\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(owner == msg.sender, \"Vesting: caller is not the owner\");\n    _;\n  }\n\n  /**\n   * @dev Throws if called not initialized contract.\n   */\n  modifier onlyInitialized() {\n    require(initialized, \"Vesting: contract not initialized\");\n    _;\n  }\n\n  /**\n   * @param _token Vesting token.\n   */\n  function init(address _token) external {\n    require(!initialized, \"Vesting::init: contract already initialized\");\n    initialized = true;\n    owner = tx.origin;\n    token = GovernanceToken(_token);\n    emit Initialized(tx.origin);\n  }\n\n  /**\n   * @notice Start distribution token.\n   * @param recipient Recipient.\n   * @param amount Vesting amount.\n   * @param duration Vesting duration.\n   */\n  function distribute(\n    address recipient,\n    uint256 amount,\n    uint256 duration\n  ) external onlyOwner onlyInitialized {\n    require(recipient != address(0), \"Vesting::distribute: invalid recipient\");\n    require(duration > 0, \"Vesting::distribute: invalid duration\");\n    require(amount > 0, \"Vesting::distribute: invalid amount\");\n    require(periodFinish == 0, \"Vesting::distribute: already distributed\");\n\n    token.transferFrom(msg.sender, address(this), amount);\n    owner = recipient;\n    token.delegate(recipient);\n    rate = amount / duration;\n    periodFinish = block.number + duration;\n    lastClaim = block.number;\n    emit Distribute(recipient, amount, duration);\n  }\n\n  /**\n   * @return Block number of last claim.\n   */\n  function lastTimeRewardApplicable() public view onlyInitialized returns (uint256) {\n    return periodFinish > block.number ? block.number : periodFinish;\n  }\n\n  /**\n   * @return Earned tokens.\n   */\n  function earned() public view onlyInitialized returns (uint256) {\n    return\n      block.number > periodFinish ? token.balanceOf(address(this)) : rate * (lastTimeRewardApplicable() - lastClaim);\n  }\n\n  /**\n   * @notice Withdraw token.\n   */\n  function claim() external onlyInitialized nonReentrant onlyOwner {\n    uint256 amount = earned();\n    require(amount > 0, \"Vesting::claim: empty\");\n    lastClaim = lastTimeRewardApplicable();\n    token.transfer(owner, amount);\n    emit Claim(amount);\n  }\n}\n"
    }
  }
}}