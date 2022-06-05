{"ISwapperGeneric.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e= 0.6.12;\ninterface IERC20 {\n    function totalSupply() external view returns (uint256);\n\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /// @notice EIP 2612\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) external;\n}\ninterface ISwapperGeneric {\n    /// @notice Withdraws \u0027amountFrom\u0027 of token \u0027from\u0027 from the BentoBox account for this swapper.\n    /// Swaps it for at least \u0027amountToMin\u0027 of token \u0027to\u0027.\n    /// Transfers the swapped tokens of \u0027to\u0027 into the BentoBox using a plain ERC20 transfer.\n    /// Returns the amount of tokens \u0027to\u0027 transferred to BentoBox.\n    /// (The BentoBox skim function will be used by the caller to get the swapped funds).\n    function swap(\n        IERC20 fromToken,\n        IERC20 toToken,\n        address recipient,\n        uint256 shareToMin,\n        uint256 shareFrom\n    ) external returns (uint256 extraShare, uint256 shareReturned);\n\n    /// @notice Calculates the amount of token \u0027from\u0027 needed to complete the swap (amountFrom),\n    /// this should be less than or equal to amountFromMax.\n    /// Withdraws \u0027amountFrom\u0027 of token \u0027from\u0027 from the BentoBox account for this swapper.\n    /// Swaps it for exactly \u0027exactAmountTo\u0027 of token \u0027to\u0027.\n    /// Transfers the swapped tokens of \u0027to\u0027 into the BentoBox using a plain ERC20 transfer.\n    /// Transfers allocated, but unused \u0027from\u0027 tokens within the BentoBox to \u0027refundTo\u0027 (amountFromMax - amountFrom).\n    /// Returns the amount of \u0027from\u0027 tokens withdrawn from BentoBox (amountFrom).\n    /// (The BentoBox skim function will be used by the caller to get the swapped funds).\n    function swapExact(\n        IERC20 fromToken,\n        IERC20 toToken,\n        address recipient,\n        address refundTo,\n        uint256 shareFromSupplied,\n        uint256 shareToExact\n    ) external returns (uint256 shareUsed, uint256 shareReturned);\n}"},"USTSwapperWormhole.sol":{"content":"// SPDX-License-Identifier: MIT\n// pragma solidity 0.8.13;\npragma solidity \u003e= 0.6.12;\nimport \"ISwapperGeneric.sol\";\n\ninterface CurvePool {\n    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy, address receiver) external returns (uint256);\n    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy, address receiver) external returns (uint256);\n    function approve(address _spender, uint256 _value) external returns (bool);\n    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;\n}\n\ninterface CurvePoolStandard {\n    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);\n    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);\n    function approve(address _spender, uint256 _value) external returns (bool);\n    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;\n}\n\ninterface IBentoBoxV1 {\n    function withdraw(IERC20 token, address from, address to, uint256 amount, uint256 share) external returns(uint256, uint256);\n    function deposit(IERC20 token, address from, address to, uint256 amount, uint256 share) external returns(uint256, uint256);\n}\n\ninterface Migrator {\n    function migrate(uint256 _amount) external;\n    function approve(address spender, uint256 amount) external;\n}\n\ncontract USTSwapperWormhole is ISwapperGeneric {\n\n    // Local variables\n    IBentoBoxV1 public constant degenBox = IBentoBoxV1(0xd96f48665a1410C0cd669A88898ecA36B9Fc2cce);\n    CurvePool constant public UST2POOL = CurvePool(0x55A8a39bc9694714E2874c1ce77aa1E599461E18);  //Remove this one\n\n    IERC20 public constant MIM = IERC20(0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3);\n    IERC20 public constant UST = IERC20(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD);\n    IERC20 public constant USTWormhole = IERC20(0xa693B19d2931d498c5B318dF961919BB4aee87a5);\n    IERC20 public constant _3CRV = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);\n\n    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);\n    IERC20 public constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);\n\n    CurvePoolStandard constant public UST3Crv = CurvePoolStandard(0x890f4e345B1dAED0367A877a1612f86A1f86985f); //Wrapped one for tests\n    CurvePoolStandard constant public MIM3Crv = CurvePoolStandard(0x5a6A4D54456819380173272A5E8E9B9904BdF41B);\n\n    CurvePoolStandard constant public USTWormhole3Crv = CurvePoolStandard(0xCEAF7747579696A2F0bb206a14210e3c9e6fB269);\n\n    Migrator constant public MigratorUST = Migrator(0xF39C29d8f6851d87c40c83b61078EB7384f7Cb51);\n\n\n\n    constructor() public {      \n        MIM.approve(address(degenBox), type(uint256).max);        \n        _3CRV.approve(address(MIM3Crv), type(uint256).max);        \n        USTWormhole.approve(address(USTWormhole3Crv), type(uint256).max);        \n        UST.approve(address(MigratorUST), type(uint256).max);\n    }\n\n\n    // Swaps to a flexible amount, from an exact input amount\n    /// @inheritdoc ISwapperGeneric\n    function swap(\n        IERC20 fromToken,\n        IERC20 toToken,\n        address recipient,\n        uint256 shareToMin,\n        uint256 shareFrom\n    ) public override returns (uint256 extraShare, uint256 shareReturned) {\n        \n        (uint256 amountFrom, ) = degenBox.withdraw(UST, address(this), address(this), 0, shareFrom);\n        MigratorUST.migrate(amountFrom);\n\n\n        uint256 amountTo3Crv = USTWormhole3Crv.exchange(0, 1, amountFrom / 1000000000000, 0);\n        uint256 amountTo = MIM3Crv.exchange(1, 0, amountTo3Crv, 0);\n        \n        (, shareReturned) = degenBox.deposit(MIM, address(this), recipient, amountTo, 0);\n        extraShare = shareReturned - shareToMin;\n\n    }\n\n    // Swaps to an exact amount, from a flexible input amount\n    /// @inheritdoc ISwapperGeneric\n    function swapExact(\n        IERC20 fromToken,\n        IERC20 toToken,\n        address recipient,\n        address refundTo,\n        uint256 shareFromSupplied,\n        uint256 shareToExact\n    ) public override returns (uint256 shareUsed, uint256 shareReturned) {\n\n        return (0,0);\n    }\n}"}}