// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

contract DateCSGirl {

    address public owner;
    mapping (address => uint) public dateabilityBalance;

    // When 'DateCSGirl' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. set the deployed smart contract's dateability balance to 520
    constructor() {
        owner = msg.sender;
        dateabilityBalance[address(this)] = 520; //我爱你
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner knows how much more love she can give/receive <3"); //不是我太渣，我只是想给每个男孩一个家
        _;
    }

    // Allow anyone to see dating profile (and not be scammed by Tinder premium)
    function profile() public pure returns(string memory) {
        return "CS Girl v2.0 Dating Profile updates:\n*Bug fixes and improvements\n*New features implemented (got a new six-figure job)\n*Performance enhancements (hits the gym daily so she can eat more free food)\n*UI/UX redesign (wears makeup now)\n*Multilingual support (English, Chinese, Solidity)";
    }

    // Allow anyone to purchase a date
    function buyDate(uint amount) public payable {
        require(msg.value >= amount * 1 ether, "I'm technically priceless, but since you're cute, I'll give you a discount ~ only 1 ETH per date :)");
        require(dateabilityBalance[address(this)] >= amount, "Already has too many side hoes :( Doesn't have enough time to go on another date");
        dateabilityBalance[address(this)] -= amount;
        dateabilityBalance[msg.sender] += amount;
    }

    // Allow the owner to increase the smart contract's dateability balance
    function refill(uint amount) public onlyOwner{
        dateabilityBalance[address(this)] += amount;
    }

    // Allow the owner to withdraw ETH
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
    fallback() external payable {}

}