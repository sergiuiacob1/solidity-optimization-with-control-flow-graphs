// File: contracts/Interfaces/IStake.sol



pragma solidity >=0.8.4;
interface IStake {

    struct Deposit {
    uint256 amount;
    uint40 time;
    }

    struct Staker {
    uint256 dividend_amount;
    uint40 last_payout;
    uint256 total_invested_amount;
    uint256 total_withdrawn_amount;
    Deposit[] deposits;
    }
    
    event NewDeposit(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    function withdraw(uint256 amountToWithdraw, uint40 timestamp)  external;

    function withdrawAmount(address _addr) external returns(uint256) ;
}

interface IMStake {

    // struct Deposit {
    // uint256 amount;
    // uint40 time;
    // }

    struct Staker {
    uint256 dividend_amount;
    uint40 last_payout;
    uint256 total_invested_amount;
    uint256 total_withdrawn_amount;
    uint256 amount;
    uint40 time;
    }
    
    event NewDeposit(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    function withdraw(uint256 amountToWithdraw)  external;

    function withdrawAmount(address _addr) external returns(uint256) ;
}
// File: contracts/Interfaces/ITokenERC20.sol



pragma solidity >=0.8.4;

interface ITokenERC20 {

event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);

    event FrozenFunds(address target, bool frozen);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) external returns (bool success);

    function burn(uint256 _value) external returns (bool success);

    function burnFrom(address _from, uint256 _value) external returns (bool success);

    
}
// File: contracts/Owned.sol


pragma solidity ^0.8.4;



contract owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Caller should be Owner");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

// File: contracts/TokenERC20.sol


pragma solidity ^0.8.4;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

contract TokenERC20 is ITokenERC20, owned{
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;            
        name = tokenName;                        
        symbol = tokenSymbol;           
    }

    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != address(0x0), "should Transfer to correct address");

        require(balanceOf[_from] >= _value, "Not enough balance from the sender");

        require(balanceOf[_to] + _value > balanceOf[_to], "overflows");

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }


    function transfer(address _to, uint256 _value) public override returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "You are not allowed to transfer passed amount");    
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public override
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public override
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }


    function burn(uint256 _value) public override returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance of tokens to burn");  
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;               
        emit Burn(msg.sender, _value);
        return true;
    }

   
    function burnFrom(address _from, uint256 _value) public override returns (bool success) {
        require(balanceOf[_from] >= _value, "Not enough balance of tokens to burn");               
        require(_value <= allowance[_from][msg.sender], "Not allowed to burn such amount of tokens");
        balanceOf[_from] -= _value;                     
        allowance[_from][msg.sender] -= _value;             
        totalSupply -= _value;         
        emit Burn(_from, _value);
        return true;
    }
}
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/MSPaceStakeContract.sol



pragma solidity ^0.8.4;





contract MSpaceStake is owned, IMStake {
	using SafeMath for uint256;
	using SafeMath for uint40;
    // using SafeERC20 for IERC20;

    uint256 public invested_amount;
    uint256 public withdrawn_amount;
    bool public stakeLive;
    bool public withdrawLive;
    
    TokenERC20 public MSPACE;

    mapping(address => Staker) public stakers;
    
	address public gameDevWallet;
    address public coinAddress;

    uint256 public minumTime;
    uint256 public mediumTime;
    uint256 public maximumTime;
    uint256 public endTime;
    uint256 public timestampSeconds;

    struct Percentage {
        bool valid;
        uint256 dividend;
        uint256 divisor;
    }

    mapping(uint256 => Percentage) public percentage;

    constructor(address _gameDevWallet, address _coinAddress) {
        require(!isContract(gameDevWallet));
		gameDevWallet = _gameDevWallet;
        coinAddress = _coinAddress;
        MSPACE = TokenERC20(_coinAddress);
        minumTime = 30;
        mediumTime = 90;
        maximumTime = 180;
        endTime = 365;
        timestampSeconds = 86400;
        percentage[1].valid = true;
        percentage[1].dividend = 111;
        percentage[1].divisor = 200;
        percentage[2].valid = true;
        percentage[2].dividend = 833;
        percentage[2].divisor = 1000;
        percentage[3].valid = true;
        percentage[3].dividend = 1667;
        percentage[3].divisor = 1000;
    }

    function updateMinumTime(uint256 _new) public onlyOwner{
        minumTime = _new;
    }

    function updateEndTime(uint256 _new) public onlyOwner{
        endTime = _new;
    }

    function updateMediumTime(uint256 _new) public onlyOwner{
        mediumTime = _new;
    }

    function updateTimeStampSeconds(uint256 _new) public onlyOwner{
        timestampSeconds = _new;
    }

    function toggleStakeStatus() public onlyOwner{
        stakeLive = !stakeLive;
    }

    function toggleWithdrawStatus() public onlyOwner{
        withdrawLive = !withdrawLive;
    }

    function updatemMaximumTime(uint256 _new) public onlyOwner{
        maximumTime = _new;
    }

    function updatePercentage(uint256 percentageLevel, uint256 dividend, uint256 divisor) public onlyOwner{
        require(percentage[percentageLevel].valid, "percentage not active");
        percentage[percentageLevel].dividend = dividend;
        percentage[percentageLevel].divisor = divisor;
    }


    function updateGameDevWallet(address _newGameDevWallet) public onlyOwner {
        gameDevWallet = _newGameDevWallet;
    }

    function updateCoinAddress(address _coinAddress) public onlyOwner {
        coinAddress = _coinAddress;
    }

    function _withdrawAmount(address _addr) private {
        uint256 amount = this.withdrawAmount(_addr);

        if(amount > 0) {
            stakers[_addr].last_payout = uint40(block.timestamp);
            stakers[_addr].dividend_amount += amount;
        }
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "deposit is invalid");
        require(stakeLive, "Not yet allowed to stake");

        uint256 newAmount = this.withdrawAmount(msg.sender) + amount;

        MSPACE.transferFrom(msg.sender, gameDevWallet, amount);
        Staker storage staker = stakers[msg.sender];

        staker.total_invested_amount+= amount;
        staker.amount = newAmount;
        staker.time = uint40(block.timestamp);
        invested_amount+= amount;
        
        emit NewDeposit(msg.sender, amount);
    }
    
    function withdraw(uint256 amountToWithdraw) external override{
        require(withdrawLive, "Not yet allowed to withdraw");
        Staker storage staker = stakers[msg.sender];

        _withdrawAmount(msg.sender);

        require(staker.amount >= amountToWithdraw, "Not enough balance to withdraw");

        require(staker.dividend_amount > 0, "Zero amount");

        uint256 amount = staker.dividend_amount;

        uint256 newAmount = staker.dividend_amount - amountToWithdraw;

        uint40 newTime = (staker.time - ((uint40(block.timestamp) - staker.time) / 2));

        staker.amount = newAmount;
        staker.dividend_amount = 0;
        staker.total_withdrawn_amount += amountToWithdraw;
        staker.time = newTime;
        withdrawn_amount += amountToWithdraw;

        MSPACE.transferFrom(gameDevWallet, msg.sender, amountToWithdraw);
        
        emit Withdraw(msg.sender, amount);
    }

    function withdrawAmount(address _addr) view external override returns(uint256) {
        Staker storage staker = stakers[_addr];
        uint256 value = 0;
        
        uint daysDeposited = (uint40(block.timestamp) - staker.time) / timestampSeconds;

        if(daysDeposited >= minumTime && daysDeposited < mediumTime && daysDeposited <= endTime){
            value += (((staker.amount) * daysDeposited * percentage[1].dividend / percentage[1].divisor) / 100) + staker.amount; // 1/3
        }
        else if(daysDeposited >= mediumTime && daysDeposited < maximumTime && daysDeposited <= endTime){
            value += (((staker.amount) * daysDeposited * percentage[2].dividend / percentage[2].divisor) / 100)+ staker.amount; // 1/2
        }
        else if(daysDeposited >= maximumTime && daysDeposited <= endTime) {
            value += (((staker.amount) * daysDeposited * percentage[3].dividend / percentage[3].divisor) / 100)+ staker.amount; // 1
        }
        else if(daysDeposited < minumTime) {
            value += 0;
        }

        return value;
    }

    
    function addressDetails(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested_amount, uint256 total_withdrawn_amount) {
        Staker storage staker = stakers[_addr];

        uint256 amount = this.withdrawAmount(_addr);

        return (
            amount + staker.dividend_amount,
            staker.total_invested_amount,
            staker.total_withdrawn_amount
        );
    }

    function contractDetails() view external returns(uint256 _invested_amount, uint256 _withdrawn_amount) {
        return (invested_amount, withdrawn_amount);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}