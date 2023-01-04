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


    uint256 public totalShares;

    uint256 public totalWithdraw;

    /**
     * 每个受益人的份额
     */
    mapping (address => uint) public personShares;

    /**
     * 每个受益人取出的金额
     */
    mapping (address => uint) public withdrawed;

    //受益人列表
    address[] public beneficiarys;

    /**
     * 收到ETH主币时会回调该函数
     */
    receive() external payable{
        emit ReceiveShares(msg.sender, msg.value);
    }

    /**
     * 初始化两个数组；一个是受益人数组：有哪些受益人；一个是受益人分别占有多少份额；顺序保持一致
     */
    constructor(address[] memory _beneficiarys, uint256[] memory _personShares) payable{
        require(_beneficiarys.length > 0);
        require(_beneficiarys.length == _personShares.length, "beneficiary and share dismatch");
        for (uint i = 0; i < _beneficiarys.length; i++) {
            _allocate(_beneficiarys[i], _personShares[i]);
        }
    }

    function _allocate(address _account, uint _accountShare) private{
        require(_account != address(0), "address can not be zero address");
        require(_accountShare > 0, "share can not be 0");
        require(personShares[_account] == 0, "account already exists");
        beneficiarys.push(_account);
        personShares[_account] = _accountShare;
        totalShares += _accountShare;
        emit AddBeneficiary(_account, _accountShare);
    }

}