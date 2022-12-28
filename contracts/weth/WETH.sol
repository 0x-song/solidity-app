// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{
    constructor() ERC20("WETH", "WETH"){
        
    }

    event Deposit(address indexed _address, uint indexed _amount);

    event Withdrawal(address indexed _address, uint indexed _amount);

    fallback() external payable{
        deposit();
    }

    receive() external payable{
        deposit();
    }

    function deposit() public payable{
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function Withdraw(uint _amount) public{
        require(balanceOf(msg.sender) >= _amount, "Insuffient amount");
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdrawal(msg.sender, _amount);
    } 
}