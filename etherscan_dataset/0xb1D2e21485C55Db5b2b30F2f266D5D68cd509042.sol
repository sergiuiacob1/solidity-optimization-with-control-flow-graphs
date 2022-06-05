{"Admin.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.8.0 \u003c0.9.0;\r\n\r\nimport \u0027./IAdmin.sol\u0027;\r\n\r\nabstract contract Admin is IAdmin {\r\n\r\n    address public admin;\r\n\r\n    modifier _onlyAdmin_() {\r\n        require(msg.sender == admin, \u0027Admin: only admin\u0027);\r\n        _;\r\n    }\r\n\r\n    constructor () {\r\n        admin = msg.sender;\r\n        emit NewAdmin(admin);\r\n    }\r\n\r\n    function setAdmin(address newAdmin) external _onlyAdmin_ {\r\n        admin = newAdmin;\r\n        emit NewAdmin(newAdmin);\r\n    }\r\n\r\n}\r\n"},"IAdmin.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.8.0 \u003c0.9.0;\r\n\r\ninterface IAdmin {\r\n\r\n    event NewAdmin(address indexed newAdmin);\r\n\r\n    function admin() external view returns (address);\r\n\r\n    function setAdmin(address newAdmin) external;\r\n\r\n}\r\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.8.0 \u003c0.9.0;\r\n\r\ninterface IERC20 {\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 amount);\r\n\r\n    function name() external view returns (string memory);\r\n\r\n    function symbol() external view returns (string memory);\r\n\r\n    function decimals() external view returns (uint8);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    function transfer(address to, uint256 amount) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\r\n\r\n}\r\n"},"VoteImplementation.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.8.0 \u003c0.9.0;\r\n\r\nimport \u0027./IERC20.sol\u0027;\r\nimport \u0027./VoteStorage.sol\u0027;\r\n\r\ncontract VoteImplementation is VoteStorage {\r\n\r\n    event NewVoteTopic(string topic, uint256 numOptions, uint256 deadline);\r\n\r\n    event NewVote(address indexed voter, uint256 option);\r\n\r\n    function initializeVote(string memory topic_, uint256 numOptions_, uint256 deadline_) external _onlyAdmin_ {\r\n        require(block.timestamp \u003e deadline, \u0027VoteImplementation.initializeVote: still in vote\u0027);\r\n        topic = topic_;\r\n        numOptions = numOptions_;\r\n        deadline = deadline_;\r\n        delete voters;\r\n        emit NewVoteTopic(topic_, numOptions_, deadline_);\r\n    }\r\n\r\n    function vote(uint256 option) external {\r\n        require(block.timestamp \u003c= deadline, \u0027VoteImplementation.vote: vote ended\u0027);\r\n        require(option \u003e= 1 \u0026\u0026 option \u003c= numOptions, \u0027VoteImplementation.vote: invalid vote option\u0027);\r\n        voters.push(msg.sender);\r\n        votes[msg.sender] = option;\r\n        emit NewVote(msg.sender, option);\r\n    }\r\n\r\n\r\n    //================================================================================\r\n    // Convenient query functions\r\n    //================================================================================\r\n\r\n    function getVoters() external view returns (address[] memory) {\r\n        return voters;\r\n    }\r\n\r\n    function getVotes(address[] memory accounts) external view returns (uint256[] memory) {\r\n        uint256[] memory options = new uint256[](accounts.length);\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            options[i] = votes[accounts[i]];\r\n        }\r\n        return options;\r\n    }\r\n\r\n    function getVotePowerOnEthereum(address account) public view returns (uint256) {\r\n        address deri = 0xA487bF43cF3b10dffc97A9A744cbB7036965d3b9;\r\n        address uniswapV2Pair = 0xA3DfbF2933FF3d96177bde4928D0F5840eE55600; // DERI-USDT\r\n\r\n        // balance in wallet\r\n        uint256 balance1 = IERC20(deri).balanceOf(account);\r\n        // balance in uniswapV2Pair\r\n        uint256 balance2 = IERC20(deri).balanceOf(uniswapV2Pair) * IERC20(uniswapV2Pair).balanceOf(account) / IERC20(uniswapV2Pair).totalSupply();\r\n\r\n        return balance1 + balance2;\r\n    }\r\n\r\n    function getVotePowerOnBNB(address account) public view returns (uint256) {\r\n        address deri = 0xe60eaf5A997DFAe83739e035b005A33AfdCc6df5;\r\n        address pancakePair = 0xDc7188AC11e124B1fA650b73BA88Bf615Ef15256; // DERI-BUSD\r\n        address poolV2 = 0x26bE73Bdf8C113F3630e4B766cfE6F0670Aa09cF; // DERI-based Inno Pool\r\n        address lToken = 0xC246d0aD04a9029A82862BE2fbd16ab1445b1602; // DERI-based Inno Pool LP Token\r\n\r\n        // balance in wallet\r\n        uint256 balance1 = IERC20(deri).balanceOf(account);\r\n        // balance in pancakePair\r\n        uint256 balance2 = IERC20(deri).balanceOf(pancakePair) * IERC20(pancakePair).balanceOf(account) / IERC20(pancakePair).totalSupply();\r\n        // balance in inno pool\r\n        (int256 liquidity, , ) = IPerpetualPool(poolV2).getPoolStateValues();\r\n        uint256 balance3 = uint256(liquidity) * IERC20(lToken).balanceOf(account) / IERC20(lToken).totalSupply();\r\n\r\n        return balance1 + balance2 + balance3;\r\n    }\r\n\r\n    function getVotePowerOnArbitrum(address account) public view returns (uint256) {\r\n        address deri = 0x21E60EE73F17AC0A411ae5D690f908c3ED66Fe12;\r\n\r\n        // balance in wallet\r\n        uint256 balance1 = IERC20(deri).balanceOf(account);\r\n\r\n        return balance1;\r\n    }\r\n\r\n    function getVotePowersOnEthereum(address[] memory accounts) external view returns (uint256[] memory) {\r\n        uint256[] memory powers = new uint256[](accounts.length);\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            powers[i] = getVotePowerOnEthereum(accounts[i]);\r\n        }\r\n        return powers;\r\n    }\r\n\r\n    function getVotePowersOnBNB(address[] memory accounts) external view returns (uint256[] memory) {\r\n        uint256[] memory powers = new uint256[](accounts.length);\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            powers[i] = getVotePowerOnBNB(accounts[i]);\r\n        }\r\n        return powers;\r\n    }\r\n\r\n    function getVotePowersOnArbitrum(address[] memory accounts) external view returns (uint256[] memory) {\r\n        uint256[] memory powers = new uint256[](accounts.length);\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            powers[i] = getVotePowerOnArbitrum(accounts[i]);\r\n        }\r\n        return powers;\r\n    }\r\n\r\n}\r\n\r\ninterface IPerpetualPool {\r\n    function getPoolStateValues() external view returns (int256 liquidity, uint256 lastTimestamp, int256 protocolFeeAccrued);\r\n}\r\n"},"VoteStorage.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity \u003e=0.8.0 \u003c0.9.0;\r\n\r\nimport \u0027./Admin.sol\u0027;\r\n\r\nabstract contract VoteStorage is Admin {\r\n\r\n    address public implementation;\r\n\r\n    string public topic;\r\n\r\n    uint256 public numOptions;\r\n\r\n    uint256 public deadline;\r\n\r\n    // voters may contain duplicated address, if one submits more than one votes\r\n    address[] public voters;\r\n\r\n    // voter address =\u003e vote\r\n    // vote starts from 1, 0 is reserved for no vote\r\n    mapping (address =\u003e uint256) public votes;\r\n\r\n}\r\n"}}