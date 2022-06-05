{"blob.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\n\npragma solidity ^0.8.0;\n\nimport \"./erc721.sol\";\nimport \"./ownable.sol\";\nimport \"./erc2981.sol\";\n\n\nlibrary Math {\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a \u003c b ? a : b;\n    }\n}\n\n\nlibrary Strings {\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI\u0027s implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n}\n\nlibrary SafeTransferLib {\n    function safeTransferETH(address to, uint256 amount) internal {\n        bool callStatus;\n\n        assembly {\n            // Transfer the ETH and store if it succeeded or not.\n            callStatus := call(gas(), to, amount, 0, 0, 0, 0)\n        }\n\n        require(callStatus, \"ETH_TRANSFER_FAILED\");\n    }\n}\n\ncontract BlobCat is ERC721, Ownable, ERC2981 {\n    string baseURI = \"\";\n    uint256 totalSupply = 0;\n    uint256 public activationTimestamp;\n\n\n    // should be less than difference between stage amounts\n    uint256 public immutable transactionLimit = 20;\n\n    uint256 public blobCatPrice = 0.035 ether;\n\n    uint256 public immutable totalBlobCats = 1000;\n\n    constructor(uint256 _activationTimestamp) ERC721(\"blobcat\", \"BLOBCAT\") {\n        _royaltyRecipient = msg.sender;\n        _royaltyFee = 700;\n        activationTimestamp = _activationTimestamp;\n    }\n\n    function setPrice(uint256 newPrice) onlyOwner public {\n        blobCatPrice = newPrice;\n    }\n\n    function setActivationTimestamp(uint256 _activationTimestamp) onlyOwner public {\n        activationTimestamp = _activationTimestamp;\n    }\n\n\n    function setRoyaltyRecipient(address recipient) onlyOwner public {\n        _royaltyRecipient = recipient;\n    }\n\n    function setRoyaltyFee(uint256 fee) onlyOwner public {\n        _royaltyFee = fee;\n    }\n\n    function setBaseURI(string memory _newBaseURI) onlyOwner public {\n        baseURI = _newBaseURI;\n    }\n\n    function mintBlobCat(uint256 amount) public payable {\n        require(amount \u003e 0, \"blobblobBLOBBLOB blobblob blobblob BLOB blobBLOB BLOBBLOB blobBLOBblobblob blobBLOBblobblob\");\n        require(amount \u003c= transactionLimit, \"blobblobBLOBBLOB blobblob blobblob BLOB BLOBblobblobBLOB blobBLOBblob BLOBblobblobblob BLOBBLOBBLOBBLOBblob\");\n        require(totalSupply + amount \u003c= totalBlobCats, \"BLOBblobblobblob blobblob BLOB blobBLOB BLOBBLOB BLOBBLOBBLOBblob blobblobBLOBBLOB\");\n        require(activationTimestamp \u003c= block.timestamp, \"blobblobblobblob blobBLOBblob BLOBBLOBblobblob blobblobBLOBBLOB\");\n        require(msg.value \u003e= blobCatPrice * amount, \"blobblobBLOB blobBLOB blobblob blobblobBLOB BLOB blobblobBLOBBLOB blobblob blobblob BLOB blobblobblob blob BLOBBLOB blobBLOBblob blobBLOBBLOBBLOB\");\n        require(msg.value == blobCatPrice * amount, \"blobblobBLOB blobBLOB blobblob blobblobBLOB BLOB blobblobBLOBBLOB blobblob blobblob BLOB blobBLOBblobBLOB BLOBBLOBblobblob blobblobblob blob\");\n        uint256 currentSupply = totalSupply;\n        for(uint i; i \u003c amount; i++) {\n            _safeMint(msg.sender, currentSupply + i);\n        }\n        totalSupply += amount;\n    }\n\n    function withdraw() public {\n        SafeTransferLib.safeTransferETH(owner(), address(this).balance);\n    }\n\n    function _baseURI() internal view virtual returns (string memory) {\n        return baseURI;\n    }\n\n    function tokenURI(uint256 tokenId) public view override returns (string memory) {\n        if (bytes(baseURI).length == 0) return \"ipfs://QmUy84PeTDoTWSpLvtXpiiocA9AJL2DeCd2cGfj6UizY3L\";\n        return string(abi.encodePacked(baseURI, Strings.toString(tokenId)));\n\n    }\n\n    function supportsInterface(bytes4 interfaceId)\n        public\n        pure\n        override(ERC721, ERC2981)\n        returns (bool)\n    {\n        return ERC721.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);\n    }\n\n}\n"},"erc2981.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\n\npragma solidity \u003e=0.8.0;\n\nabstract contract ERC2981 {\n    uint256 internal _royaltyFee;\n    address internal _royaltyRecipient;\n\n    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual returns (\n        address receiver,\n        uint256 royaltyAmount\n    ) {\n        receiver = _royaltyRecipient;\n        royaltyAmount = (salePrice * _royaltyFee) / 10000;\n    }\n\n    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {\n        return\n            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165\n            interfaceId == 0x2a55205a; // ERC165 Interface ID for ERC2981\n    }\n}\n"},"erc721.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity \u003e=0.8.0;\n\n/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)\nabstract contract ERC721 {\n    /*//////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 indexed id);\n\n    event Approval(address indexed owner, address indexed spender, uint256 indexed id);\n\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /*//////////////////////////////////////////////////////////////\n                         METADATA STORAGE/LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    string public name;\n\n    string public symbol;\n\n    function tokenURI(uint256 id) public view virtual returns (string memory);\n\n    /*//////////////////////////////////////////////////////////////\n                      ERC721 BALANCE/OWNER STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    mapping(uint256 =\u003e address) internal _ownerOf;\n\n    mapping(address =\u003e uint256) internal _balanceOf;\n\n    function ownerOf(uint256 id) public view virtual returns (address owner) {\n        require((owner = _ownerOf[id]) != address(0), \"NOT_MINTED\");\n    }\n\n    function balanceOf(address owner) public view virtual returns (uint256) {\n        require(owner != address(0), \"ZERO_ADDRESS\");\n\n        return _balanceOf[owner];\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                         ERC721 APPROVAL STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    mapping(uint256 =\u003e address) public getApproved;\n\n    mapping(address =\u003e mapping(address =\u003e bool)) public isApprovedForAll;\n\n    /*//////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(string memory _name, string memory _symbol) {\n        name = _name;\n        symbol = _symbol;\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                              ERC721 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 id) public virtual {\n        address owner = _ownerOf[id];\n\n        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], \"NOT_AUTHORIZED\");\n\n        getApproved[id] = spender;\n\n        emit Approval(owner, spender, id);\n    }\n\n    function setApprovalForAll(address operator, bool approved) public virtual {\n        isApprovedForAll[msg.sender][operator] = approved;\n\n        emit ApprovalForAll(msg.sender, operator, approved);\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 id\n    ) public virtual {\n        require(from == _ownerOf[id], \"WRONG_FROM\");\n\n        require(to != address(0), \"INVALID_RECIPIENT\");\n\n        require(\n            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],\n            \"NOT_AUTHORIZED\"\n        );\n\n        // Underflow of the sender\u0027s balance is impossible because we check for\n        // ownership above and the recipient\u0027s balance can\u0027t realistically overflow.\n        unchecked {\n            _balanceOf[from]--;\n\n            _balanceOf[to]++;\n        }\n\n        _ownerOf[id] = to;\n\n        delete getApproved[id];\n\n        emit Transfer(from, to, id);\n    }\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id\n    ) public virtual {\n        transferFrom(from, to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, \"\") ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        bytes calldata data\n    ) public virtual {\n        transferFrom(from, to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                              ERC165 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {\n        return\n            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165\n            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721\n            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                        INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 id) internal virtual {\n        require(to != address(0), \"INVALID_RECIPIENT\");\n\n        require(_ownerOf[id] == address(0), \"ALREADY_MINTED\");\n\n        // Counter overflow is incredibly unrealistic.\n        unchecked {\n            _balanceOf[to]++;\n        }\n\n        _ownerOf[id] = to;\n\n        emit Transfer(address(0), to, id);\n    }\n\n    function _burn(uint256 id) internal virtual {\n        address owner = _ownerOf[id];\n\n        require(owner != address(0), \"NOT_MINTED\");\n\n        // Ownership check above ensures no underflow.\n        unchecked {\n            _balanceOf[owner]--;\n        }\n\n        delete _ownerOf[id];\n\n        delete getApproved[id];\n\n        emit Transfer(owner, address(0), id);\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                        INTERNAL SAFE MINT LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _safeMint(address to, uint256 id) internal virtual {\n        _mint(to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, \"\") ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function _safeMint(\n        address to,\n        uint256 id,\n        bytes memory data\n    ) internal virtual {\n        _mint(to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n}\n\n/// @notice A generic interface for a contract which properly accepts ERC721 tokens.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)\nabstract contract ERC721TokenReceiver {\n    function onERC721Received(\n        address,\n        address,\n        uint256,\n        bytes calldata\n    ) external virtual returns (bytes4) {\n        return ERC721TokenReceiver.onERC721Received.selector;\n    }\n}\n"},"ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nabstract contract Ownable {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    constructor() {\n        _transferOwnership(msg.sender);\n    }\n\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    modifier onlyOwner() {\n        require(owner() == msg.sender, \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"}}