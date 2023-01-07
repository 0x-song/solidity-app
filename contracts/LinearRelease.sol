// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

/**
 * 线性释放，比如参加ICO，代币半年线性释放
 */
contract LinearRelease {

    event TokenRelease(address indexed account, uint amount);

     /**
     * 增加受益人
     */
    event AddBeneficiary(address indexed beneficiary, uint shares);

    /**
     * 受益人取款
     */
    event WithdrawShares(address indexed beneficiary, uint amount);

    /**
     * 合约收款
     */
    event ReceiveShares(address indexed from, uint indexed amount);

    /**
     * 总份额
     */
    uint256 private totalShares;

    /**
     * 已支付的份额
     */
    uint256 private totalWithdraw;

    /**
     * 每个受益人的份额
     */
    mapping (address => uint) private personShares;

    /**
     * 每个受益人取出的金额
     */
    mapping (address => uint) private withdrawed;

    //受益人列表
    address[] private beneficiarys;

    /**
     * 维护了不同地址的线性释放：地址指向一个映射；内部映射为开始时间和归属期映射
     * 可以计算出每个地址在某一时刻可以取出来的代币数量
     */
    mapping (address => uint) accountStartMapping;

    mapping (address => uint) accountDurationMapping;

    /**
     * 收到ETH主币时会回调该函数
     */
    receive() external payable{
        emit ReceiveShares(msg.sender, msg.value);
    }

    /**
     * 初始化四个数组；一个是受益人数组：有哪些受益人；一个是受益人分别占有多少份额；顺序保持一致
     * 一个是释放开始时间，用uint表示，记录timestamp；一个是持续时间，用uint表示，如果表示时间，单位是秒
     */
    constructor(address[] memory _beneficiarys, uint256[] memory _personShares, uint256[] memory _startTime, uint256[] memory _durationTime) payable{
        require(_beneficiarys.length > 0);
        require(_beneficiarys.length == _personShares.length, "beneficiary and share dismatch");
        require(_beneficiarys.length == _startTime.length, "argument mismatch");
        require(_beneficiarys.length == _durationTime.length, "argument mismatch");
        for (uint i = 0; i < _beneficiarys.length; i++) {
            _allocate(_beneficiarys[i], _personShares[i]);
            //分配线性释放时间
            accountStartMapping[_beneficiarys[i]] = _startTime[i];
            accountDurationMapping[_beneficiarys[i]] = _durationTime[i];
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

    /**
     * 账户取回释放的代币
     */
    function withdrawShare(address payable _account) public{
        require(personShares[_account] > 0, "account has no share");
        uint256 payment = _withdrawable(_account);
        require(payment > 0, "account have no share");
        uint256 releasableShare = _releasable(_account, payment);
        totalWithdraw += releasableShare;
        withdrawed[_account] += releasableShare;
        _account.transfer(releasableShare);
        emit WithdrawShares(_account, releasableShare);
    }

    /**
     * 账户的总额度
     */
    function paymentShare(address _account) public view returns (uint256){
        uint256 payment = _withdrawable(_account);
        return payment;
    }

    /**
     * 账户的总额度里面释放了多少额度
     */
    function releaseableShare(address _account) public view returns (uint256){
        uint256 payment = _withdrawable(_account);
        require(payment > 0, "account have no share");
        uint256 releasableShare = _releasable(_account, payment);
        return releasableShare;
    }

    function _releasable(address _account, uint256 _payment) private view returns (uint256){
        uint256 accountStart = accountStartMapping[_account];
        if(block.timestamp < accountStart){
            return 0;
        }
        uint256 accountDuration = accountDurationMapping[_account];
        if(block.timestamp >= accountStart + accountDuration){
            return _payment;
        }
        return _payment * (block.timestamp - accountStart) / accountDuration;
    }

    /**
     * 每个账户可以领取的ETH主币
     */
    function _withdrawable(address _account) private view returns (uint256){
        uint256 totalReceived = address(this).balance + totalWithdraw;
        uint256 payment = totalReceived * personShares[_account] / totalShares - withdrawed[_account];
        return payment;
    }
    
}