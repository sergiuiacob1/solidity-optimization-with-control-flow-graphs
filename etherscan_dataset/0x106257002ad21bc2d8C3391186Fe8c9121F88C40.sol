{"Address.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn\u0027t rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length \u003e 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance \u003e= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn\u0027t, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length \u003e 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"},"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"ERC165.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"},"IERC165.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n}\n"},"IERC2981.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Interface for the NFT Royalty Standard.\n *\n * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal\n * support for royalty payments across all NFT marketplaces and ecosystem participants.\n *\n * _Available since v4.5._\n */\ninterface IERC2981 is IERC165 {\n    /**\n     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of\n     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.\n     */\n    function royaltyInfo(uint256 tokenId, uint256 salePrice)\n        external\n        view\n        returns (address receiver, uint256 royaltyAmount);\n}\n"},"IERC721.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC721 compliant contract.\n */\ninterface IERC721 is IERC165 {\n    /**\n     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\n     */\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\n     */\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /**\n     * @dev Returns the number of tokens in ``owner``\u0027s account.\n     */\n    function balanceOf(address owner) external view returns (uint256 balance);\n\n    /**\n     * @dev Returns the owner of the `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes calldata data\n    ) external;\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Transfers `tokenId` token from `from` to `to`.\n     *\n     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n     * The approval is cleared when the token is transferred.\n     *\n     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n     *\n     * Requirements:\n     *\n     * - The caller must own the token or be an approved operator.\n     * - `tokenId` must exist.\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address to, uint256 tokenId) external;\n\n    /**\n     * @dev Approve or remove `operator` as an operator for the caller.\n     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n     *\n     * Requirements:\n     *\n     * - The `operator` cannot be the caller.\n     *\n     * Emits an {ApprovalForAll} event.\n     */\n    function setApprovalForAll(address operator, bool _approved) external;\n\n    /**\n     * @dev Returns the account approved for `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function getApproved(uint256 tokenId) external view returns (address operator);\n\n    /**\n     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n     *\n     * See {setApprovalForAll}\n     */\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\n}\n"},"IERC721Enumerable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC721.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ninterface IERC721Enumerable is IERC721 {\n    /**\n     * @dev Returns the total amount of tokens stored by the contract.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.\n     * Use along with {balanceOf} to enumerate all of ``owner``\u0027s tokens.\n     */\n    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);\n\n    /**\n     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.\n     * Use along with {totalSupply} to enumerate all tokens.\n     */\n    function tokenByIndex(uint256 index) external view returns (uint256);\n}\n"},"IERC721Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC721.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional metadata extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ninterface IERC721Metadata is IERC721 {\n    /**\n     * @dev Returns the token collection name.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the token collection symbol.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.\n     */\n    function tokenURI(uint256 tokenId) external view returns (string memory);\n}\n"},"IERC721Receiver.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @title ERC721 token receiver interface\n * @dev Interface for any contract that wants to support safeTransfers\n * from ERC721 asset contracts.\n */\ninterface IERC721Receiver {\n    /**\n     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}\n     * by `operator` from `from`, this function is called.\n     *\n     * It must return its Solidity selector to confirm the token transfer.\n     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.\n     *\n     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.\n     */\n    function onERC721Received(\n        address operator,\n        address from,\n        uint256 tokenId,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n"},"NFTUtils.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n//import \"@openzeppelin/contracts/interfaces/IERC2981.sol\";\n//import \"@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol\";\n//import \"@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol\";\n//import \"@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol\";\n//import \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\nimport \"./IERC2981.sol\";\nimport \"./IERC721Receiver.sol\";\nimport \"./IERC721Metadata.sol\";\nimport \"./IERC721Enumerable.sol\";\nimport \"./IERC20.sol\";\n\nimport \"./wnft_interfaces.sol\";\n\ninterface IHarvestStrategy {\n    function canHarvest(uint256 _pid, address _forUser, uint256[] memory _wnfTokenIds) external view returns (bool);\n}\n\ninterface INFTMasterChef {\n    event AddPoolInfo(IERC721Metadata nft, IWrappedNFT wnft, uint256 startBlock, \n                    RewardInfo[] rewards, uint256 depositFee, IERC20 dividendToken, bool withUpdate);\n    event SetStartBlock(uint256 pid, uint256 startBlock);\n    event UpdatePoolReward(uint256 pid, uint256 rewardIndex, uint256 rewardBlock, uint256 rewardForEachBlock, uint256 rewardPerNFTForEachBlock);\n    event SetPoolDepositFee(uint256 pid, uint256 depositFee);\n    event SetHarvestStrategy(IHarvestStrategy harvestStrategy);\n    event SetPoolDividendToken(uint256 pid, IERC20 dividendToken);\n\n    event AddTokenRewardForPool(uint256 pid, uint256 addTokenPerPool, uint256 addTokenPerBlock, bool withTokenTransfer);\n    event AddDividendForPool(uint256 pid, uint256 addDividend);\n\n    event UpdateDevAddress(address payable devAddress);\n    event EmergencyStop(address user, address to);\n    event ClosePool(uint256 pid, address payable to);\n\n    event Deposit(address indexed user, uint256 indexed pid, uint256[] tokenIds);\n    event Withdraw(address indexed user, uint256 indexed pid, uint256[] wnfTokenIds);\n    event WithdrawWithoutHarvest(address indexed user, uint256 indexed pid, uint256[] wnfTokenIds);\n    event Harvest(address indexed user, uint256 indexed pid, uint256[] wnftTokenIds, \n                    uint256 mining, uint256 dividend);\n\n    // Info of each NFT.\n    struct NFTInfo {\n        bool deposited;     // If the NFT is deposited.\n        uint256 rewardDebt; // Reward debt.\n\n        uint256 dividendDebt; // Dividend debt.\n    }\n\n    //Info of each Reward \n    struct RewardInfo {\n        uint256 rewardBlock;\n        uint256 rewardForEachBlock;    //Reward for each block, can only be set one with rewardPerNFTForEachBlock\n        uint256 rewardPerNFTForEachBlock;    //Reward for each block for every NFT, can only be set one with rewardForEachBlock\n    }\n\n    // Info of each pool.\n    struct PoolInfo {\n        IWrappedNFT wnft;// Address of wnft contract.\n\n        uint256 startBlock; // Reward start block.\n\n        uint256 currentRewardIndex;// the current reward phase index for poolsRewardInfos\n        uint256 currentRewardEndBlock;  // the current reward end block.\n\n        uint256 amount;     // How many NFTs the pool has.\n        \n        uint256 lastRewardBlock;  // Last block number that token distribution occurs.\n        uint256 accTokenPerShare; // Accumulated tokens per share, times 1e12.\n        \n        IERC20 dividendToken;\n        uint256 accDividendPerShare;\n\n        uint256 depositFee;// ETH charged when user deposit.\n    }\n    \n    function poolLength() external view returns (uint256);\n    function poolRewardLength(uint256 _pid) external view returns (uint256);\n\n    function poolInfos(uint256 _pid) external view returns (PoolInfo memory poolInfo);\n    function poolsRewardInfos(uint256 _pid, uint256 _rewardInfoId) external view returns (uint256 _rewardBlock, uint256 _rewardForEachBlock, uint256 _rewardPerNFTForEachBlock);\n    function poolNFTInfos(uint256 _pid, uint256 _nftTokenId) external view returns (bool _deposited, uint256 _rewardDebt, uint256 _dividendDebt);\n\n    function getPoolCurrentReward(uint256 _pid) external view returns (RewardInfo memory _rewardInfo, uint256 _currentRewardIndex);\n    function getPoolEndBlock(uint256 _pid) external view returns (uint256 _poolEndBlock);\n    function isPoolEnd(uint256 _pid) external view returns (bool);\n\n    function pending(uint256 _pid, uint256[] memory _wnftTokenIds) external view returns (uint256 _mining, uint256 _dividend);\n    function deposit(uint256 _pid, uint256[] memory _tokenIds) external payable;\n    function withdraw(uint256 _pid, uint256[] memory _wnftTokenIds) external;\n    function withdrawWithoutHarvest(uint256 _pid, uint256[] memory _wnftTokenIds) external;\n    function harvest(uint256 _pid, address _forUser, uint256[] memory _wnftTokenIds) external returns (uint256 _mining, uint256 _dividend);\n}\n\ncontract NFTUtils { \n    struct UserInfo {\n        uint256 mining;\n        uint256 dividend;\n        uint256 nftQuantity;\n        uint256 wnftQuantity;\n        bool isNFTApproved;\n        bool isWNFTApproved;\n    }\n\n    function getNFTMasterChefInfos(INFTMasterChef _nftMasterchef, uint256 _pid, address _owner, uint256 _fromTokenId, uint256 _toTokenId) external view\n                returns (INFTMasterChef.PoolInfo memory _poolInfo, INFTMasterChef.RewardInfo memory _rewardInfo, UserInfo memory _userInfo, \n                        uint256 _currentRewardIndex, uint256 _endBlock, IERC721Metadata _nft)\n     {\n        require(address(_nftMasterchef) != address(0), \"NFTUtils: nftMasterchef can not be zero\");\n        // INFTMasterChef nftMasterchef = _nftMasterchef; \n        _poolInfo = _nftMasterchef.poolInfos(_pid);\n        (_rewardInfo, _currentRewardIndex)  = _nftMasterchef.getPoolCurrentReward(_pid);\n        _endBlock = _nftMasterchef.getPoolEndBlock(_pid);\n\n       if (_owner != address(0)) {\n         uint256[] memory wnftTokenIds = ownedNFTTokens(_poolInfo.wnft, _owner, _fromTokenId, _toTokenId);\n         _userInfo = UserInfo({mining: 0, dividend: 0, nftQuantity: 0, wnftQuantity: 0, isNFTApproved: false, isWNFTApproved: false});\n         if (wnftTokenIds.length \u003e 0) {\n             (_userInfo.mining, _userInfo.dividend) = _nftMasterchef.pending(_pid, wnftTokenIds);\n         }\n    \n         IWrappedNFT wnft = _poolInfo.wnft;\n         _userInfo.nftQuantity = wnft.nft().balanceOf(_owner);\n         _userInfo.wnftQuantity = wnft.balanceOf(_owner);\n         _userInfo.isNFTApproved = wnft.nft().isApprovedForAll(_owner, address(wnft));\n         _userInfo.isWNFTApproved = wnft.isApprovedForAll(_owner, address(_nftMasterchef));\n         _nft = wnft.nft();\n       }\n    }\n\n    function ownedNFTTokens(IERC721 _nft, address _owner, uint256 _fromTokenId, uint256 _toTokenId) public view returns (uint256[] memory _totalTokenIds) {\n        if(address(_nft) == address(0) || _owner == address(0)){\n            return _totalTokenIds;\n        }\n        if (_nft.supportsInterface(type(IERC721Enumerable).interfaceId)) {\n            IERC721Enumerable nftEnumerable = IERC721Enumerable(address(_nft));\n            _totalTokenIds = ownedNFTEnumerableTokens(nftEnumerable, _owner);\n        }else{\n            _totalTokenIds = ownedNFTNotEnumerableTokens(_nft, _owner, _fromTokenId, _toTokenId);\n        }\n    }\n    \n    function ownedNFTEnumerableTokens(IERC721Enumerable _nftEnumerable, address _owner) public view returns (uint256[] memory _totalTokenIds) {\n        if(address(_nftEnumerable) == address(0) || _owner == address(0)){\n            return _totalTokenIds;\n        }\n        uint256 balance = _nftEnumerable.balanceOf(_owner);\n        if (balance \u003e 0) {\n            _totalTokenIds = new uint256[](balance);\n            for (uint256 i = 0; i \u003c balance; i++) {\n                uint256 tokenId = _nftEnumerable.tokenOfOwnerByIndex(_owner, i);\n                _totalTokenIds[i] = tokenId;\n            }\n        }\n    }\n\n    function ownedNFTNotEnumerableTokens(IERC721 _nft, address _owner, uint256 _fromTokenId, uint256 _toTokenId) public view returns (uint256[] memory _totalTokenIds) {\n        if(address(_nft) == address(0) || _owner == address(0)){\n            return _totalTokenIds;\n        }\n        uint256 number;\n        for (uint256 tokenId = _fromTokenId; tokenId \u003c= _toTokenId; tokenId ++) {\n            if (_tokenIdExists(_nft, tokenId)) {\n                address tokenOwner = _nft.ownerOf(tokenId);\n                if (tokenOwner == _owner) {\n                    number ++;\n                }\n            }\n        }\n        if(number \u003e 0){\n            _totalTokenIds = new uint256[](number);\n            uint256 index;\n            for (uint256 tokenId = _fromTokenId; tokenId \u003c= _toTokenId; tokenId ++) {\n                if (_tokenIdExists(_nft, tokenId)) {\n                    address tokenOwner = _nft.ownerOf(tokenId);\n                    if (tokenOwner == _owner) {\n                        _totalTokenIds[index] = tokenId;\n                        index ++;\n                    }\n                }\n            }\n        }\n    }\n\n    function _tokenIdExists(IERC721 _nft, uint256 _tokenId) internal view returns (bool){\n        if(_nft.supportsInterface(type(IWrappedNFT).interfaceId)){\n            IWrappedNFT wnft = IWrappedNFT(address(_nft));\n            return wnft.exists(_tokenId);\n        }\n        return true;\n    }\n\n    function supportERC721(IERC721 _nft) external view returns (bool){\n        return _nft.supportsInterface(type(IERC721).interfaceId);\n    }\n\n    function supportERC721Metadata(IERC721 _nft) external view returns (bool){\n        return _nft.supportsInterface(type(IERC721Metadata).interfaceId);\n    }\n\n    function supportERC721Enumerable(IERC721 _nft) external view returns (bool){\n        return _nft.supportsInterface(type(IERC721Enumerable).interfaceId);\n    }\n\n    function supportIWrappedNFT(IERC721 _nft) external view returns (bool){\n        return _nft.supportsInterface(type(IWrappedNFT).interfaceId);\n    }\n\n    function supportIWrappedNFTEnumerable(IERC721 _nft) external view returns (bool){\n        return _nft.supportsInterface(type(IWrappedNFTEnumerable).interfaceId);\n    }\n}\n"},"Strings.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI\u0027s implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp \u003e\u003e= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i \u003e 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value \u0026 0xf];\n            value \u003e\u003e= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"},"wnft_interfaces.sol":{"content":"// SPDX-License-Identifier: MIT\n// StarBlock DAO Contracts\n\npragma solidity ^0.8.0;\n\nimport \"./IERC2981.sol\";\nimport \"./IERC721Receiver.sol\";\nimport \"./IERC721Metadata.sol\";\nimport \"./IERC721Enumerable.sol\";\n\ninterface IERC2981Mutable is IERC165, IERC2981 {\n    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) external;\n    function deleteDefaultRoyalty() external;\n}\n\ninterface IBaseWrappedNFT is IERC165, IERC2981Mutable, IERC721Receiver, IERC721, IERC721Metadata {\n    event DelegatorChanged(address _delegator);\n    event Deposit(address _forUser, uint256[] _tokenIds);\n    event Withdraw(address _forUser, uint256[] _wnftTokenIds);\n\n    function nft() external view returns (IERC721Metadata);\n    function factory() external view returns (IWrappedNFTFactory);\n\n    function deposit(address _forUser, uint256[] memory _tokenIds) external;\n    function withdraw(address _forUser, uint256[] memory _wnftTokenIds) external;\n\n    function exists(uint256 _tokenId) external view returns (bool);\n    \n    function delegator() external view returns (address);\n    function setDelegator(address _delegator) external;\n    \n    function isEnumerable() external view returns (bool);\n}\n\ninterface IWrappedNFT is IBaseWrappedNFT {\n    function totalSupply() external view returns (uint256);\n}\n\ninterface IWrappedNFTEnumerable is IWrappedNFT, IERC721Enumerable {\n    function totalSupply() external view override(IWrappedNFT, IERC721Enumerable) returns (uint256);\n}\n\ninterface IWrappedNFTFactory {\n    event WrappedNFTDeployed(IERC721Metadata _nft, IWrappedNFT _wnft, bool _isEnumerable);\n    event WNFTDelegatorChanged(address _wnftDelegator);\n\n    function wnftDelegator() external view returns (address);\n\n    function deployWrappedNFT(IERC721Metadata _nft, bool _isEnumerable) external returns (IWrappedNFT);\n    function wnfts(IERC721Metadata _nft) external view returns (IWrappedNFT);\n    function wnftsNumber() external view returns (uint);\n}"}}