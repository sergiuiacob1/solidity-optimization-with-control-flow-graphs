/**
    SPDX-License-Identifier: MIT
    



        đ SysPin DAO đ

        LAUNCHING THIS WEEK TIME AND DATE TO BE ANNOUNCED

        đŠ KYC: https://auditrates.tech/certificate/certificate_SYSPIN.html
        Audit: Soon

        âšī¸ Tokenomic

        - Token Name: SysPin DAO
        - Token Symbol: $SPIN
        - Total Supply: 1 000 000 000 000
        - Buy TAX: 5%
        - Sell TAX: 15%

        Once every 3 days, all collected taxes will be added to liquidity!

        đ Web: https://syspin.io
        đŖ DC: https://discord.gg/VUeg2Tz7
        đŦ TG: https://t.me/syspinport
        đ TW: https://twitter.com/SyspinToken


     
     
     */















pragma solidity ^0.8.7;



contract  SECRET_LAUNCHPAD {
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    uint constant public decimals = 18;
    uint public totalSupply;
    string public name;
    string public symbol;
    address private owner;

    constructor(string memory _name, string memory _symbol, uint256 _supply) payable public {
        name = _name;
        symbol = _symbol;
        totalSupply = _supply*(10**uint256(decimals));
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0x0), msg.sender, totalSupply);
    }
}