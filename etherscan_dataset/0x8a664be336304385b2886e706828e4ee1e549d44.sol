{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}"},"LinkTokenInterface.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface LinkTokenInterface {\n  function allowance(address owner, address spender) external view returns (uint256 remaining);\n\n  function approve(address spender, uint256 value) external returns (bool success);\n\n  function balanceOf(address owner) external view returns (uint256 balance);\n\n  function decimals() external view returns (uint8 decimalPlaces);\n\n  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);\n\n  function increaseApproval(address spender, uint256 subtractedValue) external;\n\n  function name() external view returns (string memory tokenName);\n\n  function symbol() external view returns (string memory tokenSymbol);\n\n  function totalSupply() external view returns (uint256 totalTokensIssued);\n\n  function transfer(address to, uint256 value) external returns (bool success);\n\n  function transferAndCall(\n    address to,\n    uint256 value,\n    bytes calldata data\n  ) external returns (bool success);\n\n  function transferFrom(\n    address from,\n    address to,\n    uint256 value\n  ) external returns (bool success);\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}"},"SBOXRandomSeedGenerator.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.7;\n\nimport \"./LinkTokenInterface.sol\";\nimport \"./VRFCoordinatorV2Interface.sol\";\nimport \"./VRFConsumerBaseV2.sol\";\nimport \"./Ownable.sol\";\n\ncontract SBOXRandomSeedGenerator is VRFConsumerBaseV2, Ownable {\n  event SBOXRandomSeedDrafted(\n    uint256 indexed SBOXWeekIndex,\n    uint256 indexed RandomSeed\n  );\n\n  VRFCoordinatorV2Interface COORDINATOR;\n  LinkTokenInterface LINKTOKEN;\n\n  uint256[] public sboxRandomSeeds;\n\n  // Your subscription ID.\n  uint64 s_subscriptionId;\n\n  // Rinkeby coordinator. For other networks,\n  // see https://docs.chain.link/docs/vrf-contracts/#configurations\n  address vrfCoordinator;\n\n  // Rinkeby LINK token contract. For other networks,\n  // see https://docs.chain.link/docs/vrf-contracts/#configurations\n  address linkTokenContract;\n\n  // The gas lane to use, which specifies the maximum gas price to bump to.\n  // For a list of available gas lanes on each network,\n  // see https://docs.chain.link/docs/vrf-contracts/#configurations\n  bytes32 gasKeyHash;\n\n  uint32 callbackGasLimit = 300000;\n  uint16 requestConfirmations = 3;\n\n  uint256 public s_requestId;\n\n  constructor(\n    uint64 subscriptionId,\n    address _vrfCoordinator,\n    address _linkTokenContract,\n    bytes32 _gasKeyHash\n  ) VRFConsumerBaseV2(_vrfCoordinator) {\n    vrfCoordinator = _vrfCoordinator;\n    linkTokenContract = _linkTokenContract;\n    gasKeyHash = _gasKeyHash;\n\n    COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);\n    LINKTOKEN = LinkTokenInterface(_linkTokenContract);\n    s_subscriptionId = subscriptionId;\n  }\n\n  // Assumes the subscription is funded sufficiently.\n  function requestRandomWords() external onlyOwner {\n    // Will revert if subscription is not set and funded.\n    s_requestId = COORDINATOR.requestRandomWords(\n      gasKeyHash,\n      s_subscriptionId,\n      requestConfirmations,\n      callbackGasLimit,\n      1\n    );\n  }\n\n  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)\n    internal\n    override\n  {\n    if (requestId != s_requestId) {\n      revert(\"Invalid request ID\");\n    }\n    uint256 randomWord = randomWords[0];\n    sboxRandomSeeds.push(randomWord);\n    emit SBOXRandomSeedDrafted(randomWords.length, randomWord);\n  }\n}"},"VRFConsumerBaseV2.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/** ****************************************************************************\n * @notice Interface for contracts using VRF randomness\n * *****************************************************************************\n * @dev PURPOSE\n *\n * @dev Reggie the Random Oracle (not his real job) wants to provide randomness\n * @dev to Vera the verifier in such a way that Vera can be sure he\u0027s not\n * @dev making his output up to suit himself. Reggie provides Vera a public key\n * @dev to which he knows the secret key. Each time Vera provides a seed to\n * @dev Reggie, he gives back a value which is computed completely\n * @dev deterministically from the seed and the secret key.\n *\n * @dev Reggie provides a proof by which Vera can verify that the output was\n * @dev correctly computed once Reggie tells it to her, but without that proof,\n * @dev the output is indistinguishable to her from a uniform random sample\n * @dev from the output space.\n *\n * @dev The purpose of this contract is to make it easy for unrelated contracts\n * @dev to talk to Vera the verifier about the work Reggie is doing, to provide\n * @dev simple access to a verifiable source of randomness. It ensures 2 things:\n * @dev 1. The fulfillment came from the VRFCoordinator\n * @dev 2. The consumer contract implements fulfillRandomWords.\n * *****************************************************************************\n * @dev USAGE\n *\n * @dev Calling contracts must inherit from VRFConsumerBase, and can\n * @dev initialize VRFConsumerBase\u0027s attributes in their constructor as\n * @dev shown:\n *\n * @dev   contract VRFConsumer {\n * @dev     constructor(\u003cother arguments\u003e, address _vrfCoordinator, address _link)\n * @dev       VRFConsumerBase(_vrfCoordinator) public {\n * @dev         \u003cinitialization with other arguments goes here\u003e\n * @dev       }\n * @dev   }\n *\n * @dev The oracle will have given you an ID for the VRF keypair they have\n * @dev committed to (let\u0027s call it keyHash). Create subscription, fund it\n * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface\n * @dev subscription management functions).\n * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,\n * @dev callbackGasLimit, numWords),\n * @dev see (VRFCoordinatorInterface for a description of the arguments).\n *\n * @dev Once the VRFCoordinator has received and validated the oracle\u0027s response\n * @dev to your request, it will call your contract\u0027s fulfillRandomWords method.\n *\n * @dev The randomness argument to fulfillRandomWords is a set of random words\n * @dev generated from your requestId and the blockHash of the request.\n *\n * @dev If your contract could have concurrent requests open, you can use the\n * @dev requestId returned from requestRandomWords to track which response is associated\n * @dev with which randomness request.\n * @dev See \"SECURITY CONSIDERATIONS\" for principles to keep in mind,\n * @dev if your contract could have multiple requests in flight simultaneously.\n *\n * @dev Colliding `requestId`s are cryptographically impossible as long as seeds\n * @dev differ.\n *\n * *****************************************************************************\n * @dev SECURITY CONSIDERATIONS\n *\n * @dev A method with the ability to call your fulfillRandomness method directly\n * @dev could spoof a VRF response with any random value, so it\u0027s critical that\n * @dev it cannot be directly called by anything other than this base contract\n * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).\n *\n * @dev For your users to trust that your contract\u0027s random behavior is free\n * @dev from malicious interference, it\u0027s best if you can write it so that all\n * @dev behaviors implied by a VRF response are executed *during* your\n * @dev fulfillRandomness method. If your contract must store the response (or\n * @dev anything derived from it) and use it later, you must ensure that any\n * @dev user-significant behavior which depends on that stored value cannot be\n * @dev manipulated by a subsequent VRF request.\n *\n * @dev Similarly, both miners and the VRF oracle itself have some influence\n * @dev over the order in which VRF responses appear on the blockchain, so if\n * @dev your contract could have multiple VRF requests in flight simultaneously,\n * @dev you must ensure that the order in which the VRF responses arrive cannot\n * @dev be used to manipulate your contract\u0027s user-significant behavior.\n *\n * @dev Since the block hash of the block which contains the requestRandomness\n * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful\n * @dev miner could, in principle, fork the blockchain to evict the block\n * @dev containing the request, forcing the request to be included in a\n * @dev different block with a different hash, and therefore a different input\n * @dev to the VRF. However, such an attack would incur a substantial economic\n * @dev cost. This cost scales with the number of blocks the VRF oracle waits\n * @dev until it calls responds to a request. It is for this reason that\n * @dev that you can signal to an oracle you\u0027d like them to wait longer before\n * @dev responding to the request (however this is not enforced in the contract\n * @dev and so remains effective only in the case of unmodified oracle software).\n */\nabstract contract VRFConsumerBaseV2 {\n  error OnlyCoordinatorCanFulfill(address have, address want);\n  address private immutable vrfCoordinator;\n\n  /**\n   * @param _vrfCoordinator address of VRFCoordinator contract\n   */\n  constructor(address _vrfCoordinator) {\n    vrfCoordinator = _vrfCoordinator;\n  }\n\n  /**\n   * @notice fulfillRandomness handles the VRF response. Your contract must\n   * @notice implement it. See \"SECURITY CONSIDERATIONS\" above for important\n   * @notice principles to keep in mind when implementing your fulfillRandomness\n   * @notice method.\n   *\n   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this\n   * @dev signature, and will call it once it has verified the proof\n   * @dev associated with the randomness. (It is triggered via a call to\n   * @dev rawFulfillRandomness, below.)\n   *\n   * @param requestId The Id initially returned by requestRandomness\n   * @param randomWords the VRF output expanded to the requested number of words\n   */\n  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;\n\n  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF\n  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating\n  // the origin of the call\n  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {\n    if (msg.sender != vrfCoordinator) {\n      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);\n    }\n    fulfillRandomWords(requestId, randomWords);\n  }\n}"},"VRFCoordinatorV2Interface.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface VRFCoordinatorV2Interface {\n  /**\n   * @notice Get configuration relevant for making requests\n   * @return minimumRequestConfirmations global min for request confirmations\n   * @return maxGasLimit global max for request gas limit\n   * @return s_provingKeyHashes list of registered key hashes\n   */\n  function getRequestConfig()\n    external\n    view\n    returns (\n      uint16,\n      uint32,\n      bytes32[] memory\n    );\n\n  /**\n   * @notice Request a set of random words.\n   * @param keyHash - Corresponds to a particular oracle job which uses\n   * that key for generating the VRF proof. Different keyHash\u0027s have different gas price\n   * ceilings, so you can select a specific one to bound your maximum per request cost.\n   * @param subId  - The ID of the VRF subscription. Must be funded\n   * with the minimum subscription balance required for the selected keyHash.\n   * @param minimumRequestConfirmations - How many blocks you\u0027d like the\n   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS\n   * for why you may want to request more. The acceptable range is\n   * [minimumRequestBlockConfirmations, 200].\n   * @param callbackGasLimit - How much gas you\u0027d like to receive in your\n   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords\n   * may be slightly less than this amount because of gas used calling the function\n   * (argument decoding etc.), so you may need to request slightly more than you expect\n   * to have inside fulfillRandomWords. The acceptable range is\n   * [0, maxGasLimit]\n   * @param numWords - The number of uint256 random values you\u0027d like to receive\n   * in your fulfillRandomWords callback. Note these numbers are expanded in a\n   * secure way by the VRFCoordinator from a single random value supplied by the oracle.\n   * @return requestId - A unique identifier of the request. Can be used to match\n   * a request to a response in fulfillRandomWords.\n   */\n  function requestRandomWords(\n    bytes32 keyHash,\n    uint64 subId,\n    uint16 minimumRequestConfirmations,\n    uint32 callbackGasLimit,\n    uint32 numWords\n  ) external returns (uint256 requestId);\n\n  /**\n   * @notice Create a VRF subscription.\n   * @return subId - A unique subscription id.\n   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.\n   * @dev Note to fund the subscription, use transferAndCall. For example\n   * @dev  LINKTOKEN.transferAndCall(\n   * @dev    address(COORDINATOR),\n   * @dev    amount,\n   * @dev    abi.encode(subId));\n   */\n  function createSubscription() external returns (uint64 subId);\n\n  /**\n   * @notice Get a VRF subscription.\n   * @param subId - ID of the subscription\n   * @return balance - LINK balance of the subscription in juels.\n   * @return reqCount - number of requests for this subscription, determines fee tier.\n   * @return owner - owner of the subscription.\n   * @return consumers - list of consumer address which are able to use this subscription.\n   */\n  function getSubscription(uint64 subId)\n    external\n    view\n    returns (\n      uint96 balance,\n      uint64 reqCount,\n      address owner,\n      address[] memory consumers\n    );\n\n  /**\n   * @notice Request subscription owner transfer.\n   * @param subId - ID of the subscription\n   * @param newOwner - proposed new owner of the subscription\n   */\n  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;\n\n  /**\n   * @notice Request subscription owner transfer.\n   * @param subId - ID of the subscription\n   * @dev will revert if original owner of subId has\n   * not requested that msg.sender become the new owner.\n   */\n  function acceptSubscriptionOwnerTransfer(uint64 subId) external;\n\n  /**\n   * @notice Add a consumer to a VRF subscription.\n   * @param subId - ID of the subscription\n   * @param consumer - New consumer which can use the subscription\n   */\n  function addConsumer(uint64 subId, address consumer) external;\n\n  /**\n   * @notice Remove a consumer from a VRF subscription.\n   * @param subId - ID of the subscription\n   * @param consumer - Consumer to remove from the subscription\n   */\n  function removeConsumer(uint64 subId, address consumer) external;\n\n  /**\n   * @notice Cancel a subscription\n   * @param subId - ID of the subscription\n   * @param to - Where to send the remaining LINK to\n   */\n  function cancelSubscription(uint64 subId, address to) external;\n}"}}