// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC20.sol";
contract Airdrop {
    
    /**
     * _token表示代币合约地址
     * _airdropList表示需要空投的地址列表
     * _amounts表示一共需要空投代币的数量
     */
    function airdropTokens(address _token, address[] calldata _airdropList, uint256[] calldata _amounts) external{
        //地址列表和数量列表的长度应该相同
        require(_airdropList.length  == _amounts.length, "length of address do not equal with amounts");
        IERC20 token = IERC20(_token);
        uint amounts = checkSum(_amounts);
        require(token.allowance(msg.sender, address(this)) >= amounts, "Approve ERC20 Token");
        for (uint i = 0; i < _airdropList.length; i++) {
            token.transferFrom(msg.sender, _airdropList[i], _amounts[i]);
        }
    }

    /**
     * 计算一共需要空投的代币总量
     */
    function checkSum(uint256[] calldata _amounts) internal pure returns (uint number){
        for (uint i = 0; i < _amounts.length; i++) {
            number += _amounts[i];
        }
    }
}