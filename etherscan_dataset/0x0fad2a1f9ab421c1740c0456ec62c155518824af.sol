// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//////////////////////////////////////////////
//   ____         ______     __             //
//  /_  / ___ ___/_  __/__  / /_____ ___    //
//   / /_/ -_) _ \/ / / _ \/  '_/ -_) _ \   //
//  /___/\__/_//_/_/  \___/_/\_\\__/_//_/   //
//                     by 0xInuarashi.eth   //
//////////////////////////////////////////////                                      

/*
    ERC20I (ERC20 0xInuarashi Edition)
    Minified and Gas Optimized
    Contributors: 0xInuarashi (Message to Martians, Anonymice), 0xBasset (Ether Orcs)
*/

contract ERC20I {
    // Token Params
    string public name;
    string public symbol;
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // Decimals
    uint8 public constant decimals = 18;

    // Supply
    uint256 public totalSupply;
    
    // Mappings of Balances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Internal Functions
    function _mint(address to_, uint256 amount_) internal virtual {
        totalSupply += amount_;
        balanceOf[to_] += amount_;
        emit Transfer(address(0x0), to_, amount_);
    }
    function _burn(address from_, uint256 amount_) internal virtual {
        balanceOf[from_] -= amount_;
        totalSupply -= amount_;
        emit Transfer(from_, address(0x0), amount_);
    }
    function _approve(address owner_, address spender_, uint256 amount_) internal virtual {
        allowance[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

    // Public Functions
    function approve(address spender_, uint256 amount_) public virtual returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }
    function transfer(address to_, uint256 amount_) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount_;
        balanceOf[to_] += amount_;
        emit Transfer(msg.sender, to_, amount_);
        return true;
    }
    function transferFrom(address from_, address to_, uint256 amount_) public virtual returns (bool) {
        if (allowance[from_][msg.sender] != type(uint256).max) {
            allowance[from_][msg.sender] -= amount_; }
        balanceOf[from_] -= amount_;
        balanceOf[to_] += amount_;
        emit Transfer(from_, to_, amount_);
        return true;
    }

    // 0xInuarashi Custom Functions
    function multiTransfer(address[] memory to_, uint256[] memory amounts_) public virtual {
        require(to_.length == amounts_.length, "ERC20I: To and Amounts length Mismatch!");
        for (uint256 i = 0; i < to_.length; i++) {
            transfer(to_[i], amounts_[i]);
        }
    }
    function multiTransferFrom(address[] memory from_, address[] memory to_, uint256[] memory amounts_) public virtual {
        require(from_.length == to_.length && from_.length == amounts_.length, "ERC20I: From, To, and Amounts length Mismatch!");
        for (uint256 i = 0; i < from_.length; i++) {
            transferFrom(from_[i], to_[i], amounts_[i]);
        }
    }
}

abstract contract ERC20IBurnable is ERC20I {
    function burn(uint256 amount_) external virtual {
        _burn(msg.sender, amount_);
    }
    function burnFrom(address from_, uint256 amount_) public virtual {
        uint256 _currentAllowance = allowance[from_][msg.sender];
        require(_currentAllowance >= amount_, "ERC20IBurnable: Burn amount requested exceeds allowance!");

        if (allowance[from_][msg.sender] != type(uint256).max) {
            allowance[from_][msg.sender] -= amount_; }

        _burn(from_, amount_);
    }
}

abstract contract Ownable {
    address public owner; 
    constructor() { owner = msg.sender; }
    modifier onlyOwner { require(owner == msg.sender, "Not Owner!"); _; }
    function transferOwnership(address new_) external onlyOwner { owner = new_; }
}

abstract contract Minterable is Ownable {
    mapping(address => bool) public minters;
    modifier onlyMinter { require(minters[msg.sender], "Not Minter!"); _; }
    function setMinter(address address_, bool bool_) external onlyOwner {
        minters[address_] = bool_;
    }
}

abstract contract Burnerable is Ownable {
    mapping(address => bool) public burners;
    modifier onlyBurner { require(burners[msg.sender], "Not Burner!"); _; }
    function setBurner(address address_, bool bool_) external onlyOwner {
        burners[address_] = bool_;
    }
}

contract ZenToken is ERC20I("ZenToken", "ZEN"), ERC20IBurnable, 
Minterable, Burnerable {
    function mintAsController(address to_, uint256 amount_) external onlyMinter {
        _mint(to_, amount_);
    }
    function burnAsController(address from_, uint256 amount_) external onlyBurner {
        _burn(from_, amount_);
    }
}