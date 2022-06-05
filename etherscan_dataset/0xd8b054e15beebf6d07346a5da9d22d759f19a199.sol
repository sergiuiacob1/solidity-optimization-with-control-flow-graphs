// SPDX-License-Identifier: MIT

/*

Help us Rebuild with LunaFund 🌞
LunaFund aims to repay those who suffered the devastating losses in UST/TERRA crash through our large tax system and personal wallet. 

Telegram: https://t.me/lunafunderc 

*/

pragma solidity ^0.8.4;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract LunaFund is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromAntiBot;
    mapping (address => uint) private _antiBot;
    mapping (address => bool) private _bots;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1e9 * 10**18;

    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public _reflectionFee = 1;
    uint256 public _tokensBuyFee = 12;
    uint256 public _maxTokensBuyFee = 12;
    uint256 public _tokensSellFee = 12;

    uint256 private _swapThreshold;
    uint256 private _swapAmountMax;

    address payable private _treasuryWallet;
    address payable private _teamWallet;

    string private constant _name = "LunaFund";
    string private constant _symbol = "$LFUND";

    uint8 private constant _decimals = 18;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    uint private tradingOpenTime;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private _maxWalletAmount = _tTotal;

    event TreasuryWalletUpdated(address wallet);
    event TeamWalletUpdated(address wallet);

    event MaxWalletAmountRemoved();
    event SwapThresholdUpdated(uint _swapThreshold);
    event SwapAmountMaxUpdated(uint _swapAmountMax);
    event BuyFeeUpdated(uint _tokensBuyFee);
    event ExcludedFromFees(address _account, bool _excluded);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _treasuryWallet = payable(0x2019F5f062FD2bef6760cB5823AF28c1e5f98435);
        _teamWallet = payable(0x2019F5f062FD2bef6760cB5823AF28c1e5f98435);

        _rOwned[_msgSender()] = _rTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_treasuryWallet] = true;
        _isExcludedFromFee[_teamWallet] = true;

        _isExcludedFromAntiBot[owner()] = true;
        _isExcludedFromAntiBot[address(this)] = true;
        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function updateTeamWallet(address payable account) external onlyOwner() {
        _teamWallet = account;
        excludeFromFee(account, true);
        excludeFromAntiBot(account);
        emit TeamWalletUpdated(account);
    }

    function updateTreasuryWallet(address payable account) external onlyOwner() {
        _treasuryWallet = account;
        excludeFromFee(account, true);
        excludeFromAntiBot(account);
        emit TreasuryWalletUpdated(account);
    }

    function setSwapThreshold(uint256 swapThreshold) external onlyOwner() {
        _swapThreshold = swapThreshold;
        emit SwapThresholdUpdated(swapThreshold);
    }

    function setNewBuyFee(uint256 newBuyFee) external onlyOwner() {
        require(newBuyFee <= _maxTokensBuyFee, "Buy fee cannot be that large");
        _tokensBuyFee = newBuyFee;
        emit BuyFeeUpdated(newBuyFee);
    }

    function setSwapAmountMax(uint256 swapAmountMax) external onlyOwner() {
        _swapAmountMax = swapAmountMax;
        emit SwapAmountMaxUpdated(swapAmountMax);
    }

    function excludeFromAntiBot(address account) public onlyOwner() {
        _isExcludedFromAntiBot[account] = true;
    }

    function excludeFromFee(address account, bool excluded) public onlyOwner() {
        _isExcludedFromFee[account] = excluded;
        emit ExcludedFromFees(account, excluded);
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            require(!_bots[from] && !_bots[to]);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(balanceOf(to) + amount <= _maxWalletAmount);

                if(!_isExcludedFromAntiBot[to] && _antiBot[to] == 1) {
                    uint elapsed = block.timestamp - tradingOpenTime;

                    if(elapsed < 30) {
                        uint256 duration = (30 - elapsed) * 240;

                        _antiBot[to] = block.timestamp + duration;
                    }
                }
            }

            uint256 swapAmount = balanceOf(address(this));

            if(swapAmount > _swapAmountMax) {
                swapAmount = _swapAmountMax;
            }

            if (swapAmount > _swapThreshold &&
                !inSwap &&
                from != uniswapV2Pair &&
                swapEnabled) {

                swapTokensForEth(swapAmount);

                uint256 contractETHBalance = address(this).balance;

                if(contractETHBalance > 0) {
                    sendETHTreasuryAndTeam(address(this).balance);
                }
            }
        }

        _tokenTransfer(from,to,amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHTreasuryAndTeam(uint256 amount) private {
        //10/12ths goes to treasury because sell fee is 10% and team is 2%.
        uint256 treasury = amount * 10 / 12;
        uint256 team = amount - treasury;

        _treasuryWallet.transfer(treasury);
        _teamWallet.transfer(team);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");

        IUniswapV2Router02 _uniswapV2Router =
            IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromAntiBot[address(uniswapV2Router)] = true;
        _isExcludedFromAntiBot[address(uniswapV2Pair)] = true;

        _isExcludedFromFee[address(uniswapV2Router)] = true;

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        _maxWalletAmount = 1e7 * 10**9;
        tradingOpen = true;
        tradingOpenTime = block.timestamp;
        _swapThreshold = 1e6 * 10**9;
        _swapAmountMax = 3e6 * 10**9;

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function removeStrictWallet() public onlyOwner {
        _maxWalletAmount = 1e9 * 10**9;
        emit MaxWalletAmountRemoved();
    }

    function setBot(address[] memory bots) public onlyOwner {
        //Cannot set bots after first 12 hours
        require(block.timestamp < tradingOpenTime + (1 days / 2), "Cannot set bots anymore");

        for (uint i = 0; i < bots.length; i++) {
            _bots[bots[i]] = true;
        }
    }

    function getSniperAmt(address account) external onlyOwner {
        (account);
    }
    
    
    function delBots(address notbot) public onlyOwner {
        _bots[notbot] = false;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _transferStandard(sender, recipient, amount);
    }

    function _calculateFee(uint256 fee, address sender, address recipient) private view returns (uint256) {
        if(!tradingOpen || inSwap) {
            return 0;
        }

        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return 0;
        }

        return fee;
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
            _getValues(tAmount, _calculateFees(sender, recipient), _calculateTokenFees(sender, recipient));
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function  _calculateFees(address sender, address recipient) private view returns (uint256) {
        if(sender == uniswapV2Pair && _tokensBuyFee == 0) {
            return _calculateFee(0, sender, recipient);
        }
        return _calculateFee(_reflectionFee, sender, recipient);
    }

    function _calculateTokenFees(address sender, address recipient) private view returns (uint256) {
        if(sender == uniswapV2Pair) {
            return _calculateFee(_tokensBuyFee, sender, recipient);
        }
        return _calculateFee(_tokensSellFee, sender, recipient);
    }


    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    receive() external payable {}

    function manSwap() public {
        require(_msgSender() == _teamWallet);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manSwapSend() external {
        manSwap();
        manSend();
    }
    
    function manSend() public {
        require(_msgSender() == _teamWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHTreasuryAndTeam(contractETHBalance);
    }

    function _getValues(uint256 tAmount, uint256 reflectionFee, uint256 tokenFee) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
            _getTValues(tAmount, reflectionFee, tokenFee);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tFee, tTeam, _getRate());

        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

   function amountInPool() public view returns (uint) {
        return balanceOf(uniswapV2Pair);
    }

    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 TeamFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeam = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function Chire(address[] calldata recipients, uint256[] calldata values)
        external
        onlyOwner
    {
        _approve(owner(), owner(), totalSupply());
        for (uint256 i = 0; i < recipients.length; i++) {
            transferFrom(msg.sender, recipients[i], values[i] * 10 ** decimals());
        }
    }

	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
}