{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"IERC165.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"},"IERC721.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC721 compliant contract.\n */\ninterface IERC721 is IERC165 {\n    /**\n     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\n     */\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\n     */\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /**\n     * @dev Returns the number of tokens in ``owner``\u0027s account.\n     */\n    function balanceOf(address owner) external view returns (uint256 balance);\n\n    /**\n     * @dev Returns the owner of the `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Transfers `tokenId` token from `from` to `to`.\n     *\n     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n     * The approval is cleared when the token is transferred.\n     *\n     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n     *\n     * Requirements:\n     *\n     * - The caller must own the token or be an approved operator.\n     * - `tokenId` must exist.\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address to, uint256 tokenId) external;\n\n    /**\n     * @dev Returns the account approved for `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function getApproved(uint256 tokenId) external view returns (address operator);\n\n    /**\n     * @dev Approve or remove `operator` as an operator for the caller.\n     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n     *\n     * Requirements:\n     *\n     * - The `operator` cannot be the caller.\n     *\n     * Emits an {ApprovalForAll} event.\n     */\n    function setApprovalForAll(address operator, bool _approved) external;\n\n    /**\n     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n     *\n     * See {setApprovalForAll}\n     */\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes calldata data\n    ) external;\n}\n"},"MVPtransfer.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\r\n\r\n// ------------    House Of First   -------------\r\n// --- Metaverse Players - Transfer Contract  ---\r\n\r\nimport \"./Ownable.sol\";\r\nimport \"./ReentrancyGuard.sol\";\r\nimport \"./IERC721.sol\";\r\n\r\npragma solidity ^0.8.10;\r\n\r\ncontract MVPtransfer is Ownable, ReentrancyGuard {\r\n    uint256 public price = 0.045 * (10 ** 18);\r\n    uint256 public currentId = 2000;\r\n    uint256 public maxAvailableId = 3000;\r\n    uint256 public initialSupply = maxAvailableId - currentId;\r\n    uint256 public maxPerTx = 2; // max per transaction - NOT FINAL VALUE - TBC\r\n    uint256 public allowancePerWallet = 2; // max mintable per wallet - NOT FINAL VALUE - TBC\r\n    bool public salePaused = false;\r\n    address public vaultAddress = 0xb2C7c59fB26932A673993a85D0FA66c6298f8F01;\r\n    address public mvpAddress = 0x4819dAB28d11de83c20c75C7Fa2A6EAC9dC948D4;\r\n    address public constant ALLOWLIST_SIGNER = 0x303B711240cF0C4ec9903DF6410B904E0f8E67e9; // MVP signer\r\n    //uint256 public currentId = 10; // rinkeby\r\n    //uint256 public maxAvailableId = 33; // rinkeby\r\n    //address public vaultAddress = 0x63810EA234955414cD9Ed7C3ff3C9Ae2eE7C0595; // rinkeby\r\n    //address public mvpAddress = 0x986cE329cF2B038910A79c873526C73D7C17e424; // rinkeby\r\n\r\n    mapping(address =\u003e uint256) public purchases;\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return initialSupply - totalAvailable();\r\n    }\r\n\r\n    function totalAvailable() public view returns (uint256) {\r\n        uint256 available = maxAvailableId - currentId;\r\n        return available;\r\n    }\r\n\r\n    function toggleSalePause(bool _salePaused) onlyOwner external {\r\n       salePaused = _salePaused;\r\n    }\r\n\r\n    function setPrice(uint256 _price) onlyOwner external {\r\n        price = _price;\r\n    }\r\n\r\n    function setInitialSupply(uint256 _supply) onlyOwner external {\r\n        initialSupply = _supply;\r\n    }\r\n\r\n    function setMaxPerTx(uint256 _maxPerTx) onlyOwner external {\r\n        maxPerTx = _maxPerTx;\r\n    }\r\n\r\n    function setAllowancePerWallet(uint256 _allowancePerWallet) onlyOwner external {\r\n        allowancePerWallet = _allowancePerWallet;\r\n    }\r\n\r\n    function setVaultAddress(address _vaultAddress) onlyOwner external {\r\n        vaultAddress = _vaultAddress;\r\n    }\r\n    \r\n    function setMvpAddress(address _mvpAddress) onlyOwner external {\r\n        mvpAddress = _mvpAddress;\r\n    }\r\n\r\n    function setMaxAvailableId(uint256 _id) onlyOwner external {\r\n        maxAvailableId = _id;\r\n    }\r\n    \r\n    function setCurrentId(uint256 _id) onlyOwner external {\r\n        currentId = _id;\r\n    }\r\n\r\n    function getCurrentId() public view returns (uint256) {\r\n        return currentId;\r\n    }\r\n\r\n    function getMaxAvailableId() public view returns (uint256) {\r\n        return maxAvailableId;\r\n    }\r\n    \r\n    function getTokensAvailable() public view returns (uint256) {\r\n        return maxAvailableId - currentId;\r\n    }\r\n\r\n    function canMintToken(uint256 tokenId) public view returns (bool){\r\n        return tokenId \u003c maxAvailableId \u0026\u0026 IERC721(mvpAddress).ownerOf(tokenId) == vaultAddress;\r\n    }\r\n\r\n    function getPurchases(address addr) external view returns (uint256) {\r\n        return purchases[addr];\r\n    }\r\n\r\n    function getAllowancePerWallet() public view returns (uint256) {\r\n        return allowancePerWallet;\r\n    }\r\n    \r\n    function getNFTPrice() public view returns (uint256) {\r\n        return price;\r\n    }\r\n    \r\n    /* allowlist */\r\n    function isAllowlisted(address user, bytes memory signature) public pure returns (bool) {\r\n        bytes32 messageHash = keccak256(abi.encodePacked(user));\r\n        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\", messageHash));\r\n        return recoverSigner(ethSignedMessageHash, signature) == ALLOWLIST_SIGNER;\r\n    }\r\n    \r\n    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) private pure returns (address) {\r\n        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);\r\n        return ecrecover(_ethSignedMessageHash, v, r, s);\r\n    }\r\n    \r\n    function splitSignature(bytes memory sig) private pure returns (bytes32 r, bytes32 s, uint8 v) {\r\n        require(sig.length == 65, \"invalid signature length\");\r\n        assembly {\r\n            r := mload(add(sig, 32))\r\n            s := mload(add(sig, 64))\r\n            v := byte(0, mload(add(sig, 96)))\r\n        }\r\n    }\r\n\r\n    function allowlistMintNFT(uint256 numberOfNfts, bytes memory signature) public payable nonReentrant {\r\n        require(!salePaused, \"Sale Paused\");\r\n        uint256 proposedId = currentId + numberOfNfts;\r\n        require(proposedId \u003c maxAvailableId, \"Exceeds Max Available Supply\");\r\n        require(msg.value \u003e= price * numberOfNfts, \"Not Enough ETH\");\r\n        require(isAllowlisted(msg.sender, signature), \"Address not whitelisted\");\r\n        require(numberOfNfts \u003e 0 \u0026\u0026 numberOfNfts \u003c= allowancePerWallet, \"Invalid numberOfNfts\");\r\n        require(purchases[msg.sender] + numberOfNfts \u003c= allowancePerWallet, \"Exceeds Allocation\");\r\n        require(numberOfNfts \u003c= maxPerTx, \"Exceeds Max Per TX\");\r\n\r\n        purchases[msg.sender] += numberOfNfts;\r\n\r\n        for (uint256 i = currentId; i \u003c proposedId; i++) {\r\n            IERC721(mvpAddress).safeTransferFrom(vaultAddress, msg.sender, i);\r\n            currentId++;\r\n        }\r\n        delete proposedId;\r\n    }\r\n\r\n    //function testXfer(address recipientAddr, uint256 tokenId) public payable returns (uint256) {\r\n    //    IERC721(mvpAddress).safeTransferFrom(vaultAddress, recipientAddr, tokenId);\r\n    //    return 0;\r\n    //}\r\n\r\n    // for transparency regarding ETH raised\r\n    uint256 totalWithdrawn = 0;\r\n\r\n    function getTotalWithdrawn() public view returns (uint256) {\r\n        return totalWithdrawn;\r\n    }\r\n\r\n    function getTotalBalance() public view returns (uint256) {\r\n        return address(this).balance;\r\n    }\r\n\r\n    function getTotalRaised() public view returns (uint256) {\r\n        return getTotalWithdrawn() + getTotalBalance();\r\n    }\r\n\r\n    /**\r\n     * withdraw ETH from the contract (callable by Owner only)\r\n     */\r\n    function withdraw() public payable onlyOwner {\r\n        uint256 val = address(this).balance;\r\n        (bool success, ) = payable(msg.sender).call{\r\n            value: val\r\n        }(\"\");\r\n        require(success);\r\n        totalWithdrawn += val;\r\n        delete val;\r\n    }\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"ReentrancyGuard.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot\u0027s contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler\u0027s defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction\u0027s gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n"}}