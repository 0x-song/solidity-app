// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
contract PaymentSplit {
    
    /**
     * 增加受益人
     */
    event AddBeneficiary(address indexed beneficiary, uint indexed shares);

    /**
     * 受益人取款
     */
    event WithdrawShares(address indexed beneficiary, uint indexed amount);

    /**
     * 合约收款
     */
    event ReceiveShares(address indexed from, uint indexed amount);

}