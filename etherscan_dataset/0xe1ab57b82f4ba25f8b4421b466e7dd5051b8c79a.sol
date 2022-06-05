// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
-------------
The SolaVerse
-------------

  /$$$$$$   /$$$$$$  /$$        /$$$$$$
 /$$__  $$ /$$__  $$| $$       /$$__  $$
| $$  \__/| $$  \ $$| $$      | $$  \ $$
|  $$$$$$ | $$  | $$| $$      | $$$$$$$$
 \____  $$| $$  | $$| $$      | $$__  $$
 /$$  \ $$| $$  | $$| $$      | $$  | $$
|  $$$$$$/|  $$$$$$/| $$$$$$$$| $$  | $$
 \______/  \______/ |________/|__/  |__/
*/

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface ISOLA {
	/**
	 * @dev Returns the amount of tokens in existence.
	 */
	function totalSupply() external view returns (uint256);

	/**
	 * @dev Returns the amount of tokens owned by `account`.
	 */
	function balanceOf(address account) external view returns (uint256);

	/**
	 * @dev Moves `amount` tokens from the caller's account to `recipient`.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 * Emits a {Burnt} event.
	 */
	function transfer(address recipient, uint256 amount) external returns (bool);

	/**
	 * @dev Allows our Processor wallets/contracts to transfer SOLA without
	 * having to burn tokens
	 *
	 * Emits a {Transfer} event.
	 */
	function processorTransfer(address recipient, uint amount) external;

	/**
	 * @dev Returns the remaining number of tokens that `spender` will be
	 * allowed to spend on behalf of `owner` through {transferFrom}. This is
	 * zero by default.
	 *
	 * This value changes when {approve} or {transferFrom} are called.
	 */
	function allowance(address owner, address spender) external view returns (uint256);

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * IMPORTANT: Beware that changing an allowance with this method brings the risk
	 * that someone may use both the old and the new allowance by unfortunate
	 * transaction ordering. One possible solution to mitigate this race
	 * condition is to first reduce the spender's allowance to 0 and set the
	 * desired value afterwards:
	 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	 *
	 * Emits an {Approval} event.
	 */
	function approve(address spender, uint256 amount) external returns (bool);

	/**
	 * @dev Moves `amount` tokens from `sender` to `recipient` using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

	/**
	 * @dev Emitted when `value` tokens are moved from one account (`from`) to
	 * another (`to`).
	 *
	 * Note that `value` may be zero.
	 */
	event Transfer(address indexed from, address indexed to, uint256 value);

	/**
	 * @dev Emitted when the allowance of a `spender` for an `owner` is set by
	 * a call to {approve}. `value` is the new allowance.
	 */
	event Approval(address indexed owner, address indexed spender, uint256 value);

	/**
	 * @dev Emitted when the burning Percentage is changed by `owner`.
	 */
	event UpdateDeflationRate(uint32 value);

	/**
	 * @dev Emitted when a transfer() happens.
	 */
	event Burnt(uint256 value);
}





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}





/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor () {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	/**
	 * @dev Returns the address of the current owner.
	 */
	function owner() public view virtual returns (address) {
		return _owner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	/**
	 * @dev Leaves the contract without owner. It will not be possible to call
	 * `onlyOwner` functions anymore. Can only be called by the current owner.
	 *
	 * NOTE: Renouncing ownership will leave the contract without an owner,
	 * thereby removing any functionality that is only available to the owner.
	 */
	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}





contract SOLA is Ownable, ISOLA
{
	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply;
	uint256 private _maxSupply = 100000000000 * (10 ** 18);

	string private _name = "The SolaVerse";
	string private _symbol = "SOLA";

	uint32 public deflationRate = 0;

	address[] processorAddresses;

	constructor () {}


	/**
	 * @dev Guard for functions that only Processors are allowed to call.
	 */
	modifier onlyProcessor
	{
		require(isProcessor(msg.sender) == true, "SOLA: Only Processors can call this method.");
		_;
	}


	/**
	 * @dev Returns the name of the token.
	 */
	function name() external view returns (string memory) {
		return _name;
	}


	/**
	 * @dev Returns the symbol of the token, usually a shorter version of the
	 * name.
	 */
	function symbol() external view returns (string memory) {
		return _symbol;
	}


	/**
	 * @dev Returns the number of decimals used to get its user representation.
	 * For example, if `decimals` equals `2`, a balance of `505` tokens should
	 * be displayed to a user as `5,05` (`505 / 10 ** 2`).
	 *
	 * Tokens usually opt for a value of 18, imitating the relationship between
	 * Ether and Wei. This is the value {ERC20} uses, unless this function is
	 * overloaded;
	 *
	 * NOTE: This information is only used for _display_ purposes: it in
	 * no way affects any of the arithmetic of the contract, including
	 * {IERC20-balanceOf} and {IERC20-transfer}.
	 */
	function decimals() external pure returns (uint8) {
		return 18;
	}


	/**
	 * @dev See {IERC20-totalSupply}.
	 */
	function totalSupply() external view override returns (uint256) {
		return _totalSupply;
	}


	/**
	 * @dev See {IERC20-balanceOf}.
	 */
	function balanceOf(address account) external view override returns (uint256) {
		return _balances[account];
	}


	/**
	 * @dev See {IERC20-transfer}.
	 *
	 * Requirements:
	 *
	 * - `recipient` cannot be the zero address.
	 * - the caller must have a balance of at least `amount`.
	 */
	function transfer(address recipient, uint256 amount) external override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}


	/**
	 * @dev See {IERC20-allowance}.
	 */
	function allowance(address owner, address spender) external view override returns (uint256) {
		return _allowances[owner][spender];
	}


	/**
	 * @dev See {IERC20-approve}.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 */
	function approve(address spender, uint256 amount) external override returns (bool) {
		_approve(msg.sender, spender, amount);
		return true;
	}


	/**
	 * @dev See {IERC20-transferFrom}.
	 *
	 * Emits an {Approval} event indicating the updated allowance. This is not
	 * required by the EIP. See the note at the beginning of {ERC20}.
	 *
	 * Requirements:
	 *
	 * - `sender` and `recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `amount`.
	 * - the caller must have allowance for ``sender``'s tokens of at least
	 * `amount`.
	 */
	function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
		_transfer(sender, recipient, amount);

		uint256 currentAllowance = _allowances[sender][_msgSender()];
		require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
		_approve(sender, _msgSender(), currentAllowance - amount);

		return true;
	}


	/**
	 * @dev Atomically increases the allowance granted to `spender` by the caller.
	 *
	 * This is an alternative to {approve} that can be used as a mitigation for
	 * problems described in {IERC20-approve}.
	 *
	 * Emits an {Approval} event indicating the updated allowance.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 */
	function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
		return true;
	}


	/**
	 * @dev Atomically decreases the allowance granted to `spender` by the caller.
	 *
	 * This is an alternative to {approve} that can be used as a mitigation for
	 * problems described in {IERC20-approve}.
	 *
	 * Emits an {Approval} event indicating the updated allowance.
	 *
	 * Requirements:
	 *
	 * - `spender` cannot be the zero address.
	 * - `spender` must have allowance for the caller of at least
	 * `subtractedValue`.
	 */
	function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
		uint256 currentAllowance = _allowances[msg.sender][spender];
		require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
		_approve(msg.sender, spender, currentAllowance - subtractedValue);

		return true;
	}


	/**
	 * @dev Sets `deflationRate` as the percent of SOLA to burn on each transfer
	 *
	 * Emits an {UpdateDeflationRate} event.
	 */
	function economyUpdate(uint16 _deflationRate) external onlyOwner
	{
		deflationRate = _deflationRate;
		emit UpdateDeflationRate(deflationRate);
	}


	/**
	 * @dev Check to see if the sender is in our list of Processor addresses.
	 *
	 * Returns boolean
	 */
	function isProcessor(address _sender) internal view returns(bool)
	{
		bool is_processor = false;
		uint length = processorAddresses.length;

		for (uint i = 0; i < length; i++)
		{
			if (_sender == processorAddresses[i])
			{
				is_processor = true;
			}
		}

		return is_processor;
	}


	/**
	 * @dev Add the supplied address to the list of Processor addresses.
	 */
	function addProcessorAddress(address _address) external onlyOwner
	{
		require(msg.sender != address(0));
		require(isProcessor(_address) == false, "SOLA: That address is already in the list.");
		processorAddresses.push(_address);
	}


	/**
	 * @dev Remove the supplied address from the list of Processors.
	 */
	function removeProcessorAddress(address _address) external onlyOwner
	{
		require(msg.sender != address(0));
		uint length = processorAddresses.length;

		for (uint i = 0; i < length; i++)
		{
			if (processorAddresses[i] == _address)
			{
				processorAddresses[i] = processorAddresses[length-1];
				processorAddresses.pop();
			}
		}
	}


	/**
	 * @dev Get the list of the Processor wallet/contract addresses.
	 *
	 * Returns an array of Addresses.
	 */
	function getProcessorAddresses() public view returns(address[] memory)
	{
		return processorAddresses;
	}


	/**
	 * @dev Variation of the transfer() function that will allow our Processor wallets
	 * to distribute SOLA without incurring the deflationary burn.
	 *
	 * Emits a {Transfer} event.
	 *
	 * Requirements:
	 *
	 * - `sender` cannot be the zero address.
	 * - `_recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `amount`.
	 */
	function processorTransfer(address _recipient, uint _amount) external override onlyProcessor
	{
		require(msg.sender != address(0), "SOLA: transfer from the zero address");
		require(_recipient != address(0), "SOLA: transfer to the zero address");

		uint256 senderBalance = _balances[msg.sender];
		require(senderBalance >= _amount, "SOLA: transfer amount exceeds balance");

		_balances[msg.sender] = senderBalance - _amount;
		_balances[_recipient] += _amount;

		emit Transfer(msg.sender, _recipient, _amount);
	}


	/**
	 * @dev Moves tokens `amount` from `sender` to `recipient`.
	 *
	 * This is internal function is equivalent to {transfer}, and can be used to
	 * e.g. implement automatic token fees, slashing mechanisms, etc.
	 *
	 * Emits a {Transfer} event.
	 * Emits a {Burnt} event.
	 *
	 * Requirements:
	 *
	 * - `sender` cannot be the zero address.
	 * - `recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `amount`.
	 */
	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");

		uint256 senderBalance = _balances[sender];
		require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

		if (deflationRate > 0)
		{
			uint256 deflationAmount = amount / 100 * deflationRate / 100000;
			_balances[sender] = senderBalance - amount;
			_balances[recipient] += (amount - deflationAmount);
			_totalSupply -= deflationAmount;

			emit Burnt(deflationAmount);
		}
		else
		{
			_balances[sender] = senderBalance - amount;
			_balances[recipient] += amount;
		}

		emit Transfer(sender, recipient, amount);
	}


	/** @dev Creates `amount` tokens and assigns them to `account`, increasing
	 * the total supply.
	 *
	 * Emits a {Transfer} event with `from` set to the zero address.
	 *
	 * Requirements:
	 *
	 * - `to` cannot be the zero address.
	 */
	function mint(address account, uint256 amount) external onlyOwner {
		require(account != address(0), "ERC20: mint to the zero address");
		require(_maxSupply > _totalSupply, "ERC20: you are trying to mint more than the max supply.");

		uint256 _amount = _maxSupply - _totalSupply;
		if (_amount > amount) {
			_amount = amount;
		}

		_totalSupply += _amount;
		_balances[account] += _amount;
		emit Transfer(address(0), account, _amount);
	}


	/**
	 * @dev Destroys `amount` tokens from `account`, reducing the
	 * total supply.
	 *
	 * Emits a {Transfer} event with `to` set to the zero address.
	 *
	 * Requirements:
	 *
	 * - `account` cannot be the zero address.
	 * - `account` must have at least `amount` tokens.
	 */
	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");

		uint256 accountBalance = _balances[account];
		require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
		_balances[account] = accountBalance - amount;
		_totalSupply -= amount;

		emit Transfer(account, address(0), amount);
	}


	/**
	 * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
	 *
	 * This internal function is equivalent to `approve`, and can be used to
	 * e.g. set automatic allowances for certain subsystems, etc.
	 *
	 * Emits an {Approval} event.
	 *
	 * Requirements:
	 *
	 * - `owner` cannot be the zero address.
	 * - `spender` cannot be the zero address.
	 */
	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
}