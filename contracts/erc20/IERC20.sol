// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IERC20 {
    
    /**
     * Returns the total token supply.
     * 返回总的代币数量
     */
    function totalSupply() public view returns (uint256);

    /**
     * Returns the account balance of another account with address _owner.
     * 返回某个账户的当前代币余额
     */
    function balanceOf(address _owner) public view returns (uint256 balance);

    /**
     * Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. 
     * The function SHOULD throw if the message caller's account balance does not have enough tokens to spend.
     * 转账函数
     */
    function transfer(address _to, uint256 _value) public returns (bool success);

    /**
     * Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
     * The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. 
     * This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies. 
     * The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     * 授权转账
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /**
     * Allows _spender to withdraw from your account multiple times, up to the _value amount. 
     * If this function is called again it overwrites the current allowance with _value.
     * 授权
     */
    function approve(address _spender, uint256 _value) public returns (bool success);

    /**
     * Returns the amount which _spender is still allowed to withdraw from _owner.
     * 返回_owner授权给_spender的额度
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    /**
     * MUST trigger when tokens are transferred, including zero value transfers.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * MUST trigger on any successful call to approve(address _spender, uint256 _value).
     */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}