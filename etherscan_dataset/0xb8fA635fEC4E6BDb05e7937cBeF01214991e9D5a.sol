{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
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
    "aave/interfaces/ILendingPoolAddressesProvider.sol": {
      "content": "// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.7.5;\n\n/**\n * @title LendingPoolAddressesProvider contract\n * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles\n * - Acting also as factory of proxies and admin of those, so with right to change its implementations\n * - Owned by the Aave Governance\n * @author Aave\n **/\ninterface ILendingPoolAddressesProvider {\n  event MarketIdSet(string newMarketId);\n  event LendingPoolUpdated(address indexed newAddress);\n  event ConfigurationAdminUpdated(address indexed newAddress);\n  event EmergencyAdminUpdated(address indexed newAddress);\n  event LendingPoolConfiguratorUpdated(address indexed newAddress);\n  event LendingPoolCollateralManagerUpdated(address indexed newAddress);\n  event PriceOracleUpdated(address indexed newAddress);\n  event LendingRateOracleUpdated(address indexed newAddress);\n  event ProxyCreated(bytes32 id, address indexed newAddress);\n  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);\n\n  function getMarketId() external view returns (string memory);\n\n  function setMarketId(string calldata marketId) external;\n\n  function setAddress(bytes32 id, address newAddress) external;\n\n  function setAddressAsProxy(bytes32 id, address impl) external;\n\n  function getAddress(bytes32 id) external view returns (address);\n\n  function getLendingPool() external view returns (address);\n\n  function setLendingPoolImpl(address pool) external;\n\n  function getLendingPoolConfigurator() external view returns (address);\n\n  function setLendingPoolConfiguratorImpl(address configurator) external;\n\n  function getLendingPoolCollateralManager() external view returns (address);\n\n  function setLendingPoolCollateralManager(address manager) external;\n\n  function getPoolAdmin() external view returns (address);\n\n  function setPoolAdmin(address admin) external;\n\n  function getEmergencyAdmin() external view returns (address);\n\n  function setEmergencyAdmin(address admin) external;\n\n  function getPriceOracle() external view returns (address);\n\n  function setPriceOracle(address priceOracle) external;\n\n  function getLendingRateOracle() external view returns (address);\n\n  function setLendingRateOracle(address lendingRateOracle) external;\n}\n"
    },
    "aave/interfaces/IProposalIncentivesV2Executor.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\npragma solidity 0.7.5;\n\ninterface IProposalIncentivesV2Executor {\n  function execute() external;\n}\n"
    },
    "aave/proposals/ProposalIncentivesV2Executor.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\npragma solidity 0.7.5;\n\nimport {ILendingPoolAddressesProvider} from '../interfaces/ILendingPoolAddressesProvider.sol';\nimport {IProposalIncentivesV2Executor} from '../interfaces/IProposalIncentivesV2Executor.sol';\n\ncontract ProposalIncentivesV2Executor is IProposalIncentivesV2Executor {\n  bytes32 constant INCENTIVES_CONTROLLER_ID = bytes32(keccak256(bytes('INCENTIVES_CONTROLLER')));\n  address constant INCENTIVES_CONTROLLER_IMPL_ADDRESS = 0xD9ED413bCF58c266F95fE6BA63B13cf79299CE31;\n  address constant LENDING_POOL_ADDRESS_PROVIDER = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;\n\n  function execute() external override {\n    ILendingPoolAddressesProvider(LENDING_POOL_ADDRESS_PROVIDER).setAddressAsProxy(\n      INCENTIVES_CONTROLLER_ID,\n      INCENTIVES_CONTROLLER_IMPL_ADDRESS\n    );\n  }\n}\n"
    }
  }
}}