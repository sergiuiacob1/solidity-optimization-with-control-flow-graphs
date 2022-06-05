/**

 TELEGRAM: https://t.me/JIRO_INUU

*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
contract ERC20Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "ERC20Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "ERC20Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

contract JIROINU is Context, IERC20, ERC20Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isMaxWalletExclude;
    mapping (address => bool) public isBot;
	mapping(address => bool) public boughtEarly;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    address[] private _excluded;
    uint256 public earlyBuyPenaltyEnd;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1e13 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private maximumTokens;
	uint256 private minimumTokensForTaxSwap;
    uint256 private constant BUY = 1;
    uint256 private constant SELL = 2;
    uint256 private constant TRANSFER = 3;
    uint256 private buyOrSellSwitch;
    uint256 private _marketingTax = 3;
    uint256 private _previousMarketingTax = _marketingTax;
    uint256 private _teamTax = 2;
    uint256 private _previousTeamTax = _teamTax;
    uint256 private _liquidityTax = 1;
    uint256 private _previousLiquidityTax = _liquidityTax;
    uint256 private _reflectionsTax = 0;
    uint256 private _previousReflectionsTax = _reflectionsTax;
    uint256 private _divForLiq = _marketingTax + _teamTax + _liquidityTax;

    uint256 private taxBuyMarketing = 3;
    uint256 private taxBuyTeam = 2;
    uint256 private taxBuyLiquidity = 1;
    uint256 private taxBuyReflections = 0;

    uint256 private taxSellMarketing = 3;
    uint256 private taxSellTeam = 2;
    uint256 private taxSellLiquidity = 1;
    uint256 private taxSellReflections = 0;

    uint256 private TradingActiveBlock = 0;
    uint256 private tokensForLiquidity;
    uint256 private tokensForMarketing;
    uint256 private tokensForTeam;
    uint256 private totalBurnedTokens;
    address dead = 0x000000000000000000000000000000000000dEaD;
    address payable public MarketingAddress;
    address payable private TeamAddress;
    address payable private DevAddress;
    address payable public LiquidityAddress;
    IUniswapV2Router02 public uniV2Router;
    address public uniV2Pair;
    bool public limitsOn = false;
    bool public maxWalletOn = true;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public tradingActive = false;
    string private constant _name = "JiroINU";
    string private constant _symbol = "JINU";
    uint8 private constant _decimal = 18;
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event UpdatedLiquidityAddress(address liquidity);
    event UpdatedMarketingAddress(address marketing);
    event UpdatedTeamAddress(address team);
    event BoughtEarly(address indexed sniper);
    event RemovedSniper(address indexed notsnipersupposedly);
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    constructor() payable {
        _rOwned[_msgSender()] = _rTotal.div(10000000000000000000000000000000).mul(1296371181837000000000000000000);
        _rOwned[address(this)] = _rTotal.div(10000000000000000000000000000000).mul(8703628818163000000000000000000);
        maximumTokens = _tTotal.mul(15).div(1000);
        minimumTokensForTaxSwap = _tTotal.mul(5).div(10000);
        MarketingAddress = payable(0x87e64093Df8fe9921dE508d8f51256BA078F105E);
        TeamAddress = payable(0x87e64093Df8fe9921dE508d8f51256BA078F105E);
        DevAddress = payable(0x87e64093Df8fe9921dE508d8f51256BA078F105E);
        LiquidityAddress = payable(owner());
        _isExcluded[dead] = true;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[dead] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[MarketingAddress] = true;
        _isExcludedFromFee[TeamAddress] = true;
        _isExcludedFromFee[DevAddress] = true;
        _isMaxWalletExclude[address(this)] = true;
        _isMaxWalletExclude[_msgSender()] = true;
        _isMaxWalletExclude[dead] = true;
        _isMaxWalletExclude[MarketingAddress] = true;
        _isMaxWalletExclude[TeamAddress] = true;
        _isMaxWalletExclude[DevAddress] = true;

        emit Transfer(address(0), _msgSender(), 1296371181837000000000000000000);
        emit Transfer(address(0), address(this), 8703628818163000000000000000000);
    }
    receive() external payable {}
    function name() public pure override returns (string memory) {
        return _name;
    }
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }
    function decimals() public pure override returns (uint8) {
        return _decimal;
    }
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),
        _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amt must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amt must be less than tot refl");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    function _getValues(uint256 tAmount) private view returns (uint256,uint256,uint256,uint256,uint256,uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }
    function _getTValues(uint256 tAmount)private view returns (uint256,uint256,uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }
    function _getRValues(uint256 tAmount,uint256 tFee,uint256 tLiquidity,uint256 currentRate) private pure returns (uint256,uint256,uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _takeLiquidity(uint256 tLiquidity) private {
        if(buyOrSellSwitch == BUY){
            tokensForMarketing += tLiquidity.mul(taxBuyMarketing).div(_divForLiq);
            tokensForTeam += tLiquidity.mul(taxBuyTeam).div(_divForLiq);
            tokensForLiquidity += tLiquidity.mul(taxBuyLiquidity).div(_divForLiq);
        } else if(buyOrSellSwitch == SELL){
            tokensForMarketing += tLiquidity.mul(taxSellMarketing).div(_divForLiq);
            tokensForTeam += tLiquidity.mul(taxSellTeam).div(_divForLiq);
            tokensForLiquidity += tLiquidity.mul(taxSellLiquidity).div(_divForLiq);
        }
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectionsTax).div(10**2);
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityTax.add(_marketingTax).add(_teamTax)).div(10**2);
    }
    function _approve(address owner,address spender,uint256 amount) private {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function enableTrading() internal onlyOwner {
        tradingActive = true;
        swapAndLiquifyEnabled = true;
        limitsOn = true;
        maxWalletOn = true;
        TradingActiveBlock = block.number;
        earlyBuyPenaltyEnd = block.timestamp.add(96 hours);
    }
    function AirdropsAndLaunch(address[] memory airdropWallets, uint256[] memory amounts) external onlyOwner returns (bool){
        require(!tradingActive, "Trading already active!");
        require(airdropWallets.length < 100, "Can only airdrop 100 wallets per txn due to gas limits");
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 amount = amounts[i];
            _transfer(msg.sender, wallet, amount);
        }
        enableTrading();
        IUniswapV2Router02 _uniV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniV2Router = _uniV2Router;
        _isMaxWalletExclude[address(uniV2Router)] = true;
        _approve(address(this), address(uniV2Router), _tTotal);
        uniV2Pair = IUniswapV2Factory(_uniV2Router.factory()).createPair(address(this), _uniV2Router.WETH());
        _isMaxWalletExclude[address(uniV2Pair)] = true;
        require(address(this).balance > 0, "Must have ETH on contract to launch");
        addLiquidity(balanceOf(address(this)), address(this).balance);
        setLiquidityAddress(dead);
        return true;
    }
    function _transfer(address from,address to,uint256 amount) private {
       require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isBot[from]);
        if(!tradingActive){
            require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading is not active yet.");
        }
        if (maxWalletOn && ! _isMaxWalletExclude[to]) {
            require(balanceOf(to) + amount <= maximumTokens, "Max amount of tokens for wallet reached");
        }
        if(limitsOn){
            if (from != owner() && to != owner() && to != address(0) && to != dead && !inSwapAndLiquify) {
                if(from != owner() && to != uniV2Pair && block.number == TradingActiveBlock){
                    for (uint x = 0; x < 3; x++) {
                        if(block.number == TradingActiveBlock + x) {
                            boughtEarly[to] = true;
                            emit BoughtEarly(to);
                        }
                    }
                }
            }
        }
        uint256 totalTokensToSwap = tokensForLiquidity.add(tokensForMarketing);
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensForTaxSwap;
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && balanceOf(uniV2Pair) > 0 && totalTokensToSwap > 0 && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && to == uniV2Pair && overMinimumTokenBalance) {
            swapTokens();
            }
        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
            buyOrSellSwitch = TRANSFER;
        } else {
            if (from == uniV2Pair) {
                removeAllFee();
                _marketingTax = taxBuyMarketing;
                _teamTax = taxBuyTeam;
                _reflectionsTax = taxBuyReflections;
                _liquidityTax = taxBuyLiquidity;
                buyOrSellSwitch = BUY;
            } 
            else if (to == uniV2Pair) {
                removeAllFee();
                _marketingTax = taxSellMarketing;
                _teamTax = taxSellTeam;
                _reflectionsTax = taxSellReflections;
                _liquidityTax = taxSellLiquidity;
                buyOrSellSwitch = SELL;
                if(boughtEarly[from] && earlyBuyPenaltyEnd > block.timestamp){
                    _marketingTax = 95;
                    _teamTax = 1;
                    _liquidityTax = 2;
                    _reflectionsTax = 0;
                }
            } else {
                require(!boughtEarly[from] || earlyBuyPenaltyEnd <= block.timestamp, "Snipers can't transfer tokens to sell cheaper until penalty timeframe is over.  DM a Mod.");
                removeAllFee();
                buyOrSellSwitch = TRANSFER;
            }
        }
        _tokenTransfer(from, to, amount, takeFee);
    }
    function swapTokens() private lockTheSwap {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForMarketing + tokensForTeam;
        uint256 swapLiquidityTokens = tokensForLiquidity.div(2); //Halve the amount of liquidity tokens
        uint256 amountToSwapForETH = contractBalance.sub(swapLiquidityTokens);
        uint256 initialETHBalance = address(this).balance;
        swapTokensForETH(amountToSwapForETH); 
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForMarketing = ethBalance.mul(tokensForMarketing).div(totalTokensToSwap);
        uint256 ethForTeam = ethBalance.mul(tokensForTeam).div(totalTokensToSwap);
        uint256 ethForLiquidity = ethBalance.sub(ethForMarketing).sub(ethForTeam);
        tokensForLiquidity = 0;
        tokensForMarketing = 0;
        tokensForTeam = 0;
        (bool success,) = address(MarketingAddress).call{value: ethForMarketing}("");
        (success,) = address(TeamAddress).call{value: ethForTeam}("");
        addLiquidity(swapLiquidityTokens, ethForLiquidity);
        if(address(this).balance > 5 * 10**17){
            (success,) = address(DevAddress).call{value: address(this).balance}("");
        }
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router.WETH();
        _approve(address(this), address(uniV2Router), tokenAmount);
        uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniV2Router), tokenAmount);
        uniV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            LiquidityAddress,
            block.timestamp
        );
    }
    function removeAllFee() private {
        if (_marketingTax == 0 && _teamTax == 0 && _liquidityTax == 0 && _reflectionsTax == 0) return;
        _previousMarketingTax = _marketingTax;
        _previousTeamTax = _teamTax;
        _previousLiquidityTax = _liquidityTax;
        _previousReflectionsTax = _reflectionsTax;

        _marketingTax = 0;
        _teamTax = 0;
        _liquidityTax = 0;
        _reflectionsTax = 0;
    }
    function restoreAllFee() private {
        _marketingTax = _previousMarketingTax;
        _teamTax = _previousTeamTax;
        _liquidityTax = _previousLiquidityTax;
        _reflectionsTax = _previousReflectionsTax;
    }
    function _tokenTransfer(address sender,address recipient,uint256 amount,bool takeFee) private {
        if (!takeFee) removeAllFee();
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        if (!takeFee) restoreAllFee();
    }
    function _transferStandard(address sender,address recipient,uint256 tAmount) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferToExcluded(address sender,address recipient,uint256 tAmount) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferFromExcluded(address sender,address recipient,uint256 tAmount) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferBothExcluded(address sender,address recipient,uint256 tAmount) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _tokenTransferNoFee(address sender,address recipient,uint256 amount) private {
        _rOwned[sender] = _rOwned[sender].sub(amount);
        _rOwned[recipient] = _rOwned[recipient].add(amount);

        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromMaxWallet(address account) external onlyOwner {
        _isMaxWalletExclude[account] = true;
    }
    function includeInMaxWallet(address account) external onlyOwner {
        _isMaxWalletExclude[account] = false;
    }
    function isExcludedFromMaxWallet(address account) public view returns (bool) {
        return _isMaxWalletExclude[account];
    }
    function BotAdd(address _user) public onlyOwner {
        require(_user != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        require(!isBot[_user]);
        isBot[_user] = true;
    }
	function BotRemove(address _user) public onlyOwner {
        require(isBot[_user]);
        isBot[_user] = false;
    }
	function removeSniper(address account) external onlyOwner {
        boughtEarly[account] = false;
    }
    function LimitsOn() external onlyOwner {
        limitsOn = true;
    }
    function LimitsOff() external onlyOwner {
        limitsOn = false;
    }
    function TaxSwapEnable() external onlyOwner {
        swapAndLiquifyEnabled = true;
    }
    function TaxSwapDisable() external onlyOwner {
        swapAndLiquifyEnabled = false;
    }
    function enableMaxWallet() external onlyOwner {
        maxWalletOn = true;
    }
    function disableMaxWallet() external onlyOwner {
        maxWalletOn = false;
    }
    function setBuyTax(uint256 _buyMarketingTax, uint256 _buyTeamTax, uint256 _buyLiquidityTax, uint256 _buyReflectionsTax) external onlyOwner {
        taxBuyMarketing = _buyMarketingTax;
        taxBuyTeam = _buyTeamTax;
        taxBuyLiquidity = _buyLiquidityTax;
        taxBuyReflections = _buyReflectionsTax;
    }
    function setSellTax(uint256 _sellMarketingTax, uint256 _sellTeamTax, uint256 _sellLiquidityTax, uint256 _sellReflectionsTax) external onlyOwner {
        taxSellMarketing = _sellMarketingTax;
        taxSellTeam = _sellTeamTax;
        taxSellLiquidity = _sellLiquidityTax;
        taxSellReflections = _sellReflectionsTax;
    }
    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        require(_marketingAddress != address(0), "_marketingAddress address cannot be 0");
        MarketingAddress = payable(_marketingAddress);
        _isExcludedFromFee[MarketingAddress] = true;
        emit UpdatedMarketingAddress(_marketingAddress);
    }
    function setTeamAddress(address _teamAddress) public onlyOwner {
        require(_teamAddress != address(0), "_liquidityAddress address cannot be 0");
        TeamAddress = payable(_teamAddress);
        emit UpdatedTeamAddress(_teamAddress);
    }
    function setLiquidityAddress(address _liquidityAddress) public onlyOwner {
        LiquidityAddress = payable(_liquidityAddress);
        _isExcludedFromFee[LiquidityAddress] = true;
        emit UpdatedLiquidityAddress(_liquidityAddress);
    }
    function setMaxWallet(uint256 _percent, uint256 _divider) external onlyOwner {
        maximumTokens = _tTotal * _percent / _divider;
        require(maximumTokens <= _tTotal * 2 / 100, "Cannot set max wallet to more then 3% of total supply");
    }
    function viewBuyTaxes() public view returns(uint BuyMarketing,uint BuyTeam,uint BuyLiquidity,uint BuyReflections) {
        return (taxBuyMarketing, taxBuyTeam, taxBuyLiquidity, taxBuyReflections);
    }
    function viewSellTaxes() public view returns(uint SellMarketing,uint SellTeam,uint SellLiquidity,uint SellReflections) {
        return (taxSellMarketing, taxSellTeam, taxSellLiquidity, taxSellReflections);
    }
    function forceSwapBack() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= _tTotal * 5 / 10000, "Can only swap back if more than 0.05% of tokens stuck on contract");
        swapTokens();
    }
    function withdrawTokens(uint256 _percent) public onlyOwner {
        require(!tradingActive, "Trading is already active, can not withdraw tokens");
        uint256 amount = balanceOf(address(this)).mul(_percent).div(10**2);
        require(amount > 0, "Must have Tokens on CA");
        _transfer(address(this), owner(), amount);
    }
    function withdrawDevETH() public onlyOwner {
        bool success;
        (success,) = address(DevAddress).call{value: address(this).balance}("");
    }
    function manualAirDrop(address[] memory airdropWallets, uint256[] memory amounts) external onlyOwner{
        require(airdropWallets.length < 100, "Can only airdrop 100 wallets per txn due to gas limits");
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 amount = amounts[i];
            _transfer(msg.sender, wallet, amount);
        }
    }
    function burnPairTokens(uint256 percent) external onlyOwner returns (bool){
        require(percent <= 10, "May not nuke more than 10% of tokens in LP");
        uint256 liquidityPairBalance = this.balanceOf(uniV2Pair);
        uint256 amountToBurn = liquidityPairBalance.mul(percent).div(10**2);
        if (amountToBurn > 0){
            _transfer(uniV2Pair, dead, amountToBurn);
        }
        totalBurnedTokens = balanceOf(dead);
        require(totalBurnedTokens <= _tTotal.mul(50).div(10**2), "Can not burn more then 50% of supply");
        IUniswapV2Pair pair = IUniswapV2Pair(uniV2Pair);
        pair.sync();
        return true;
    }
}