// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC20.sol";
import "./ERC20.sol";
contract Faucet {

    uint256 public allowedAmount = 100000000000000000000;

    address public tokenAddress;

    uint256 constant ONE_DAY = 86400;

    //记录每个地址领取代币的时间，后面可以设定每隔24h可以领取一次
    mapping (address => uint) acquiredAddress;

    //每当每个地址领取了一次代币，便触发当前事件
    event sendToken(address indexed _receiver, uint256 indexed _amount);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        ERC20 token = ERC20(tokenAddress);
        token.mint(100000000000000000000000000);

    }


    function acquireFaucet() external {
        uint number = acquiredAddress[msg.sender];
        uint nowTime = block.timestamp;
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= allowedAmount, "Faucet empty");
        if(number != 0){
            require(nowTime - number >= ONE_DAY, "Please try again after 24 hours from your original request.");
        }
        token.transfer(msg.sender, allowedAmount);
        acquiredAddress[msg.sender] = block.timestamp;
        emit sendToken(msg.sender, allowedAmount);
        //number为0，直接领取
    }
}