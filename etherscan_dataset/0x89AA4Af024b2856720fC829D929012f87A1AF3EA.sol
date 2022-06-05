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
    "contracts/UnifarmCohortRegistryUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: GNU GPLv3\n\npragma solidity =0.8.9;\n\nimport {UnifarmCohortRegistryUpgradeableStorage} from './storage/UnifarmCohortRegistryUpgradeableStorage.sol';\nimport {OwnableUpgradeable} from './access/OwnableUpgradeable.sol';\nimport {Initializable} from './proxy/Initializable.sol';\nimport {IUnifarmCohortRegistryUpgradeable} from './interfaces/IUnifarmCohortRegistryUpgradeable.sol';\n\n/// @title UnifarmCohortRegistryUpgradeable Contract\n/// @author UNIFARM\n/// @notice maintain collection of cohorts of unifarm\n/// @dev All State mutation function are restricted to only owner access and multicall\n\ncontract UnifarmCohortRegistryUpgradeable is\n    IUnifarmCohortRegistryUpgradeable,\n    Initializable,\n    OwnableUpgradeable,\n    UnifarmCohortRegistryUpgradeableStorage\n{\n    /// @notice modifier for vailidate sender\n    modifier onlyMulticallOrOwner() {\n        onlyOwnerOrMulticall();\n        _;\n    }\n\n    /**\n     * @notice initialize Unifarm Registry contract\n     * @param master master role address\n     * @param trustedForwarder trusted forwarder address\n     * @param  multiCall_ multicall contract address\n     */\n\n    function __UnifarmCohortRegistryUpgradeable_init(\n        address master,\n        address trustedForwarder,\n        address multiCall_\n    ) external initializer {\n        __UnifarmCohortRegistryUpgradeable_init_unchained(multiCall_);\n        __Ownable_init(master, trustedForwarder);\n    }\n\n    /**\n     * @dev internal function to set registry state\n     * @param  multiCall_ multicall contract address\n     */\n\n    function __UnifarmCohortRegistryUpgradeable_init_unchained(address multiCall_) internal {\n        multiCall = multiCall_;\n    }\n\n    /**\n     * @dev modifier to prevent malicious user\n     */\n\n    function onlyOwnerOrMulticall() internal view {\n        require(_msgSender() == multiCall || _msgSender() == owner(), 'ONA');\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function setTokenMetaData(\n        address cohortId,\n        uint32 fid_,\n        address farmToken_,\n        uint256 userMinStake_,\n        uint256 userMaxStake_,\n        uint256 totalStakeLimit_,\n        uint8 decimals_,\n        bool skip_\n    ) external override onlyMulticallOrOwner {\n        require(fid_ > 0, 'WFID');\n        require(farmToken_ != address(0), 'IFT');\n        require(userMaxStake_ > 0 && totalStakeLimit_ > 0, 'IC');\n        require(totalStakeLimit_ > userMaxStake_, 'IC');\n\n        tokenDetails[cohortId][fid_] = TokenMetaData({\n            fid: fid_,\n            farmToken: farmToken_,\n            userMinStake: userMinStake_,\n            userMaxStake: userMaxStake_,\n            totalStakeLimit: totalStakeLimit_,\n            decimals: decimals_,\n            skip: skip_\n        });\n\n        emit TokenMetaDataDetails(cohortId, farmToken_, fid_, userMinStake_, userMaxStake_, totalStakeLimit_, decimals_, skip_);\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function setCohortDetails(\n        address cohortId,\n        string memory cohortVersion_,\n        uint256 startBlock_,\n        uint256 endBlock_,\n        uint256 epochBlocks_,\n        bool hasLiquidityMining_,\n        bool hasContainsWrappedToken_,\n        bool hasCohortLockinAvaliable_\n    ) external override onlyMulticallOrOwner {\n        require(cohortId != address(0), 'ICI');\n        require(endBlock_ > startBlock_, 'IBR');\n\n        cohortDetails[cohortId] = CohortDetails({\n            cohortVersion: cohortVersion_,\n            startBlock: startBlock_,\n            endBlock: endBlock_,\n            epochBlocks: epochBlocks_,\n            hasLiquidityMining: hasLiquidityMining_,\n            hasContainsWrappedToken: hasContainsWrappedToken_,\n            hasCohortLockinAvaliable: hasCohortLockinAvaliable_\n        });\n\n        emit AddedCohortDetails(\n            cohortId,\n            cohortVersion_,\n            startBlock_,\n            endBlock_,\n            epochBlocks_,\n            hasLiquidityMining_,\n            hasContainsWrappedToken_,\n            hasCohortLockinAvaliable_\n        );\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function addBoosterPackage(\n        address cohortId_,\n        address paymentToken_,\n        address boosterVault_,\n        uint256 bpid_,\n        uint256 boosterPackAmount_\n    ) external override onlyMulticallOrOwner {\n        require(bpid_ > 0, 'WBPID');\n        boosterInfo[cohortId_][bpid_] = BoosterInfo({\n            cohortId: cohortId_,\n            paymentToken: paymentToken_,\n            boosterVault: boosterVault_,\n            boosterPackAmount: boosterPackAmount_\n        });\n        emit BoosterDetails(cohortId_, bpid_, paymentToken_, boosterPackAmount_);\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function updateMulticall(address newMultiCallAddress) external override onlyOwner {\n        require(newMultiCallAddress != multiCall, 'SMA');\n        multiCall = newMultiCallAddress;\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function setWholeCohortLock(address cohortId, bool status) external override onlyMulticallOrOwner {\n        require(cohortId != address(0), 'ICI');\n        wholeCohortLock[cohortId] = status;\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function setCohortLockStatus(\n        address cohortId,\n        bytes4 actionToLock,\n        bool status\n    ) external override onlyMulticallOrOwner {\n        require(cohortId != address(0), 'ICI');\n        lockCohort[cohortId][actionToLock] = status;\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function setCohortTokenLockStatus(\n        bytes32 cohortSalt,\n        bytes4 actionToLock,\n        bool status\n    ) external override onlyMulticallOrOwner {\n        tokenLockedStatus[cohortSalt][actionToLock] = status;\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function validateStakeLock(address cohortId, uint32 farmId) public view override {\n        bytes32 salt = keccak256(abi.encodePacked(cohortId, farmId));\n        require(!wholeCohortLock[cohortId] && !lockCohort[cohortId][STAKE_MAGIC_VALUE] && !tokenLockedStatus[salt][STAKE_MAGIC_VALUE], 'LC');\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function validateUnStakeLock(address cohortId, uint32 farmId) public view override {\n        bytes32 salt = keccak256(abi.encodePacked(cohortId, farmId));\n        require(!wholeCohortLock[cohortId] && !lockCohort[cohortId][UNSTAKE_MAGIC_VALUE] && !tokenLockedStatus[salt][UNSTAKE_MAGIC_VALUE], 'LC');\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function getCohortToken(address cohortId, uint32 farmId)\n        public\n        view\n        override\n        returns (\n            uint32 fid,\n            address farmToken,\n            uint256 userMinStake,\n            uint256 userMaxStake,\n            uint256 totalStakeLimit,\n            uint8 decimals,\n            bool skip\n        )\n    {\n        TokenMetaData memory token = tokenDetails[cohortId][farmId];\n        return (token.fid, token.farmToken, token.userMinStake, token.userMaxStake, token.totalStakeLimit, token.decimals, token.skip);\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function getCohort(address cohortId)\n        public\n        view\n        override\n        returns (\n            string memory cohortVersion,\n            uint256 startBlock,\n            uint256 endBlock,\n            uint256 epochBlocks,\n            bool hasLiquidityMining,\n            bool hasContainsWrappedToken,\n            bool hasCohortLockinAvaliable\n        )\n    {\n        CohortDetails memory cohort = cohortDetails[cohortId];\n        return (\n            cohort.cohortVersion,\n            cohort.startBlock,\n            cohort.endBlock,\n            cohort.epochBlocks,\n            cohort.hasLiquidityMining,\n            cohort.hasContainsWrappedToken,\n            cohort.hasCohortLockinAvaliable\n        );\n    }\n\n    /**\n     * @inheritdoc IUnifarmCohortRegistryUpgradeable\n     */\n\n    function getBoosterPackDetails(address cohortId, uint256 bpid)\n        public\n        view\n        override\n        returns (\n            address cohortId_,\n            address paymentToken_,\n            address boosterVault,\n            uint256 boosterPackAmount\n        )\n    {\n        BoosterInfo memory booster = boosterInfo[cohortId][bpid];\n        return (booster.cohortId, booster.paymentToken, booster.boosterVault, booster.boosterPackAmount);\n    }\n\n    uint256[49] private __gap;\n}\n"
    },
    "contracts/access/OwnableUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: GNU GPLv3\n\n// OpenZeppelin Contracts v4.3.2 (access/Ownable.sol)\n\npragma solidity =0.8.9;\n\nimport {ERC2771ContextUpgradeable} from '../metatx/ERC2771ContextUpgradeable.sol';\nimport {Initializable} from '../proxy/Initializable.sol';\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner\n */\n\nabstract contract OwnableUpgradeable is Initializable, ERC2771ContextUpgradeable {\n    address private _owner;\n    address private _master;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner\n     */\n    function __Ownable_init(address master, address trustedForwarder) internal initializer {\n        __Ownable_init_unchained(master);\n        __ERC2771ContextUpgradeable_init(trustedForwarder);\n    }\n\n    function __Ownable_init_unchained(address masterAddress) internal initializer {\n        _transferOwnership(_msgSender());\n        _master = masterAddress;\n    }\n\n    /**\n     * @dev Returns the address of the current owner\n     * @return _owner - _owner address\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), 'ONA');\n        _;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the master\n     */\n    modifier onlyMaster() {\n        require(_master == _msgSender(), 'OMA');\n        _;\n    }\n\n    /**\n     * @dev Transfering the owner ship to master role in case of emergency\n     *\n     * NOTE: Renouncing ownership will transfer the contract ownership to master role\n     */\n\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(_master);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`)\n     * Can only be called by the current owner\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), 'INA');\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`)\n     * Internal function without access restriction\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n\n    uint256[49] private __gap;\n}\n"
    },
    "contracts/interfaces/IUnifarmCohortRegistryUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: GNU GPLv3\n\npragma solidity =0.8.9;\npragma abicoder v2;\n\n/// @title IUnifarmCohortRegistryUpgradeable Interface\n/// @author UNIFARM\n/// @notice All External functions of Unifarm Cohort Registry.\n\ninterface IUnifarmCohortRegistryUpgradeable {\n    /**\n     * @notice set tokenMetaData for a particular cohort farm\n     * @dev only called by owner access or multicall\n     * @param cohortId cohort address\n     * @param fid_ farm id\n     * @param farmToken_ farm token address\n     * @param userMinStake_ user minimum stake\n     * @param userMaxStake_ user maximum stake\n     * @param totalStakeLimit_ total stake limit\n     * @param decimals_ token decimals\n     * @param skip_ it can be skip or not during unstake\n     */\n\n    function setTokenMetaData(\n        address cohortId,\n        uint32 fid_,\n        address farmToken_,\n        uint256 userMinStake_,\n        uint256 userMaxStake_,\n        uint256 totalStakeLimit_,\n        uint8 decimals_,\n        bool skip_\n    ) external;\n\n    /**\n     * @notice a function to set particular cohort details\n     * @dev only called by owner access or multicall\n     * @param cohortId cohort address\n     * @param cohortVersion_ cohort version\n     * @param startBlock_ start block of a cohort\n     * @param endBlock_ end block of a cohort\n     * @param epochBlocks_ epochBlocks of a cohort\n     * @param hasLiquidityMining_ true if lp tokens can be stake here\n     * @param hasContainsWrappedToken_ true if wTokens exist in rewards\n     * @param hasCohortLockinAvaliable_ cohort lockin flag\n     */\n\n    function setCohortDetails(\n        address cohortId,\n        string memory cohortVersion_,\n        uint256 startBlock_,\n        uint256 endBlock_,\n        uint256 epochBlocks_,\n        bool hasLiquidityMining_,\n        bool hasContainsWrappedToken_,\n        bool hasCohortLockinAvaliable_\n    ) external;\n\n    /**\n     * @notice to add a booster pack in a particular cohort\n     * @dev only called by owner access or multicall\n     * @param cohortId_ cohort address\n     * @param paymentToken_ payment token address\n     * @param boosterVault_ booster vault address\n     * @param bpid_ booster pack Id\n     * @param boosterPackAmount_ booster pack amount\n     */\n\n    function addBoosterPackage(\n        address cohortId_,\n        address paymentToken_,\n        address boosterVault_,\n        uint256 bpid_,\n        uint256 boosterPackAmount_\n    ) external;\n\n    /**\n     * @notice update multicall contract address\n     * @dev only called by owner access\n     * @param newMultiCallAddress new multicall address\n     */\n\n    function updateMulticall(address newMultiCallAddress) external;\n\n    /**\n     * @notice lock particular cohort contract\n     * @dev only called by owner access or multicall\n     * @param cohortId cohort contract address\n     * @param status true for lock vice-versa false for unlock\n     */\n\n    function setWholeCohortLock(address cohortId, bool status) external;\n\n    /**\n     * @notice lock particular cohort contract action. (`STAKE` | `UNSTAKE`)\n     * @dev only called by owner access or multicall\n     * @param cohortId cohort address\n     * @param actionToLock magic value STAKE/UNSTAKE\n     * @param status true for lock vice-versa false for unlock\n     */\n\n    function setCohortLockStatus(\n        address cohortId,\n        bytes4 actionToLock,\n        bool status\n    ) external;\n\n    /**\n     * @notice lock the particular farm action (`STAKE` | `UNSTAKE`) in a cohort\n     * @param cohortSalt mixture of cohortId and tokenId\n     * @param actionToLock magic value STAKE/UNSTAKE\n     * @param status true for lock vice-versa false for unlock\n     */\n\n    function setCohortTokenLockStatus(\n        bytes32 cohortSalt,\n        bytes4 actionToLock,\n        bool status\n    ) external;\n\n    /**\n     * @notice validate cohort stake locking status\n     * @param cohortId cohort address\n     * @param farmId farm Id\n     */\n\n    function validateStakeLock(address cohortId, uint32 farmId) external view;\n\n    /**\n     * @notice validate cohort unstake locking status\n     * @param cohortId cohort address\n     * @param farmId farm Id\n     */\n\n    function validateUnStakeLock(address cohortId, uint32 farmId) external view;\n\n    /**\n     * @notice get farm token details in a specific cohort\n     * @param cohortId particular cohort address\n     * @param farmId farmId of particular cohort\n     * @return fid farm Id\n     * @return farmToken farm Token Address\n     * @return userMinStake amount that user can minimum stake\n     * @return userMaxStake amount that user can maximum stake\n     * @return totalStakeLimit total stake limit for the specific farm\n     * @return decimals farm token decimals\n     * @return skip it can be skip or not during unstake\n     */\n\n    function getCohortToken(address cohortId, uint32 farmId)\n        external\n        view\n        returns (\n            uint32 fid,\n            address farmToken,\n            uint256 userMinStake,\n            uint256 userMaxStake,\n            uint256 totalStakeLimit,\n            uint8 decimals,\n            bool skip\n        );\n\n    /**\n     * @notice get specific cohort details\n     * @param cohortId cohort address\n     * @return cohortVersion specific cohort version\n     * @return startBlock start block of a unifarm cohort\n     * @return endBlock end block of a unifarm cohort\n     * @return epochBlocks epoch blocks in particular cohort\n     * @return hasLiquidityMining indicator for liquidity mining\n     * @return hasContainsWrappedToken true if contains wrapped token in cohort rewards\n     * @return hasCohortLockinAvaliable denotes cohort lockin\n     */\n\n    function getCohort(address cohortId)\n        external\n        view\n        returns (\n            string memory cohortVersion,\n            uint256 startBlock,\n            uint256 endBlock,\n            uint256 epochBlocks,\n            bool hasLiquidityMining,\n            bool hasContainsWrappedToken,\n            bool hasCohortLockinAvaliable\n        );\n\n    /**\n     * @notice get booster pack details for a specific cohort\n     * @param cohortId cohort address\n     * @param bpid booster pack Id\n     * @return cohortId_ cohort address\n     * @return paymentToken_ payment token address\n     * @return boosterVault booster vault address\n     * @return boosterPackAmount booster pack amount\n     */\n\n    function getBoosterPackDetails(address cohortId, uint256 bpid)\n        external\n        view\n        returns (\n            address cohortId_,\n            address paymentToken_,\n            address boosterVault,\n            uint256 boosterPackAmount\n        );\n\n    /**\n     * @notice emit on each farm token update\n     * @param cohortId cohort address\n     * @param farmToken farm token address\n     * @param fid farm Id\n     * @param userMinStake amount that user can minimum stake\n     * @param userMaxStake amount that user can maximum stake\n     * @param totalStakeLimit total stake limit for the specific farm\n     * @param decimals farm token decimals\n     * @param skip it can be skip or not during unstake\n     */\n\n    event TokenMetaDataDetails(\n        address indexed cohortId,\n        address indexed farmToken,\n        uint32 indexed fid,\n        uint256 userMinStake,\n        uint256 userMaxStake,\n        uint256 totalStakeLimit,\n        uint8 decimals,\n        bool skip\n    );\n\n    /**\n     * @notice emit on each update of cohort details\n     * @param cohortId cohort address\n     * @param cohortVersion specific cohort version\n     * @param startBlock start block of a unifarm cohort\n     * @param endBlock end block of a unifarm cohort\n     * @param epochBlocks epoch blocks in particular unifarm cohort\n     * @param hasLiquidityMining indicator for liquidity mining\n     * @param hasContainsWrappedToken true if contains wrapped token in cohort rewards\n     * @param hasCohortLockinAvaliable denotes cohort lockin\n     */\n\n    event AddedCohortDetails(\n        address indexed cohortId,\n        string indexed cohortVersion,\n        uint256 startBlock,\n        uint256 endBlock,\n        uint256 epochBlocks,\n        bool indexed hasLiquidityMining,\n        bool hasContainsWrappedToken,\n        bool hasCohortLockinAvaliable\n    );\n\n    /**\n     * @notice emit on update of each booster pacakge\n     * @param cohortId the cohort address\n     * @param bpid booster pack id\n     * @param paymentToken the payment token address\n     * @param boosterPackAmount the booster pack amount\n     */\n\n    event BoosterDetails(address indexed cohortId, uint256 indexed bpid, address paymentToken, uint256 boosterPackAmount);\n}\n"
    },
    "contracts/metatx/ERC2771ContextUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: GNU GPLv3\n\npragma solidity =0.8.9;\n\nimport {Initializable} from '../proxy/Initializable.sol';\n\n/**\n * @dev Context variant with ERC2771 support\n */\n\n// solhint-disable\nabstract contract ERC2771ContextUpgradeable is Initializable {\n    /**\n     * @dev holds the trust forwarder\n     */\n\n    address public trustedForwarder;\n\n    /**\n     * @dev context upgradeable initializer\n     * @param tForwarder trust forwarder\n     */\n\n    function __ERC2771ContextUpgradeable_init(address tForwarder) internal initializer {\n        __ERC2771ContextUpgradeable_init_unchained(tForwarder);\n    }\n\n    /**\n     * @dev called by initializer to set trust forwarder\n     * @param tForwarder trust forwarder\n     */\n\n    function __ERC2771ContextUpgradeable_init_unchained(address tForwarder) internal {\n        trustedForwarder = tForwarder;\n    }\n\n    /**\n     * @dev check if the given address is trust forwarder\n     * @param forwarder forwarder address\n     * @return isForwarder true/false\n     */\n\n    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {\n        return forwarder == trustedForwarder;\n    }\n\n    /**\n     * @dev if caller is trusted forwarder will return exact sender.\n     * @return sender wallet address\n     */\n\n    function _msgSender() internal view virtual returns (address sender) {\n        if (isTrustedForwarder(msg.sender)) {\n            // The assembly code is more direct than the Solidity version using `abi.decode`.\n            assembly {\n                sender := shr(96, calldataload(sub(calldatasize(), 20)))\n            }\n        } else {\n            return msg.sender;\n        }\n    }\n\n    /**\n     * @dev returns msg data for called function\n     * @return function call data\n     */\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        if (isTrustedForwarder(msg.sender)) {\n            return msg.data[:msg.data.length - 20];\n        } else {\n            return msg.data;\n        }\n    }\n}\n"
    },
    "contracts/proxy/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)\n\npragma solidity =0.8.9;\n\nimport '../utils/AddressUpgradeable.sol';\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n *\n * [CAUTION]\n * ====\n * Avoid leaving a contract uninitialized\n *\n * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation\n * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the\n * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:\n *\n * [.hljs-theme-light.nopadding]\n * ```\n * /// @custom:oz-upgrades-unsafe-allow constructor\n * constructor() initializer {}\n * ```\n * ====\n */\nabstract contract Initializable {\n    /**\n     * @dev Indicates that the contract has been initialized\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice\n     */\n    modifier initializer() {\n        // If the contract is initializing we ignore whether _initialized is set in order to support multiple\n        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the\n        // contract may have been reentered\n        require(_initializing ? _isConstructor() : !_initialized, 'CIAI');\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n\n    /**\n     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the\n     * {initializer} modifier, directly or indirectly\n     */\n    modifier onlyInitializing() {\n        require(_initializing, 'CINI');\n        _;\n    }\n\n    function _isConstructor() private view returns (bool) {\n        return !AddressUpgradeable.isContract(address(this));\n    }\n}\n"
    },
    "contracts/storage/UnifarmCohortRegistryUpgradeableStorage.sol": {
      "content": "// SPDX-License-Identifier: GNU GPLv3\n\npragma solidity =0.8.9;\n\nabstract contract UnifarmCohortRegistryUpgradeableStorage {\n    /// @notice TokenMetaData struct hold the token information.\n    struct TokenMetaData {\n        // farm id\n        uint32 fid;\n        // farm token address.\n        address farmToken;\n        // user min stake for validation.\n        uint256 userMinStake;\n        // user max stake for validation.\n        uint256 userMaxStake;\n        // total stake limit for validation.\n        uint256 totalStakeLimit;\n        // token decimals\n        uint8 decimals;\n        // can be skip during unstaking\n        bool skip;\n    }\n\n    /// @notice CohortDetails struct hold the cohort details\n    struct CohortDetails {\n        // cohort version of a cohort.\n        string cohortVersion;\n        // start block of a cohort.\n        uint256 startBlock;\n        // end block of a cohort.\n        uint256 endBlock;\n        // epoch blocks of a cohort.\n        uint256 epochBlocks;\n        // indicator for liquidity mining to seprate UI things.\n        bool hasLiquidityMining;\n        // true if contains any wrapped token in reward.\n        bool hasContainsWrappedToken;\n        // true if cohort locking feature available.\n        bool hasCohortLockinAvaliable;\n    }\n\n    /// @notice struct to hold booster configuration for each cohort\n    struct BoosterInfo {\n        // cohort contract address\n        address cohortId;\n        // what will be payment token.\n        address paymentToken;\n        // booster vault address\n        address boosterVault;\n        // payable amount in terms of PARENT Chain token or ERC20 Token.\n        uint256 boosterPackAmount;\n    }\n\n    /// @notice mapping contains each cohort details.\n    mapping(address => CohortDetails) public cohortDetails;\n\n    /// @notice contains token details by farmId\n    mapping(address => mapping(uint32 => TokenMetaData)) public tokenDetails;\n\n    /// @notice contains booster information for specific cohort.\n    mapping(address => mapping(uint256 => BoosterInfo)) public boosterInfo;\n\n    /// @notice holds lock status for whole cohort\n    mapping(address => bool) public wholeCohortLock;\n\n    /// @notice hold lock status for specific action in specific cohort.\n    mapping(address => mapping(bytes4 => bool)) public lockCohort;\n\n    /// @notice hold lock status for specific farm action in a cohort.\n    mapping(bytes32 => mapping(bytes4 => bool)) public tokenLockedStatus;\n\n    /// @notice magic value of stake action\n    bytes4 public constant STAKE_MAGIC_VALUE = bytes4(keccak256('STAKE'));\n\n    /// @notice magic value of unstake action\n    bytes4 public constant UNSTAKE_MAGIC_VALUE = bytes4(keccak256('UNSTAKE'));\n\n    /// @notice multicall address\n    address public multiCall;\n}\n"
    },
    "contracts/utils/AddressUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)\n\npragma solidity =0.8.9;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary AddressUpgradeable {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, 'Address: insufficient balance');\n\n        (bool success, ) = recipient.call{value: amount}('');\n        require(success, 'Address: unable to send value, recipient may have reverted');\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, 'Address: low-level call failed');\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, 'Address: insufficient balance for call');\n        require(isContract(target), 'Address: call to non-contract');\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, 'Address: low-level static call failed');\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), 'Address: static call to non-contract');\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    }
  }
}}