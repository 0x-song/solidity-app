# solidity-app
application of solidity

## ERC20

学习完`ERC20`代币标准，便可以发行代币了。

`ERC20`是一项以太坊代币标准，是从EIP-20提案经过以太坊社区不断讨论验证后通过而来的，是由Vitalik Buterin于2015年提出，是以太坊的第20号代币标准。详细标准参考如下地址：

https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

代币规范，也就是接口。后续需要根据接口实现具体功能。接口的方法修改为external修饰符。

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IERC20 {
    
    /**
     * Returns the total token supply.
     * 返回总的代币数量
     */
    function totalSupply() external view returns (uint256);

    /**
     * Returns the account balance of another account with address _owner.
     * 返回某个账户的当前代币余额
     */
    function balanceOf(address _owner) external view returns (uint256 balance);

    /**
     * Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. 
     * The function SHOULD throw if the message caller's account balance does not have enough tokens to spend.
     * 转账函数
     */
    function transfer(address _to, uint256 _value) external returns (bool success);

    /**
     * Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
     * The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. 
     * This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies. 
     * The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     * 授权转账
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * Allows _spender to withdraw from your account multiple times, up to the _value amount. 
     * If this function is called again it overwrites the current allowance with _value.
     * 授权
     */
    function approve(address _spender, uint256 _value) external returns (bool success);

    /**
     * Returns the amount which _spender is still allowed to withdraw from _owner.
     * 返回_owner授权给_spender的额度
     */
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    /**
     * MUST trigger when tokens are transferred, including zero value transfers.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * MUST trigger on any successful call to approve(address _spender, uint256 _value).
     */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
```

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
import "./IERC20.sol";
pragma solidity ^0.8.0;
contract ERC20 is IERC20 {

    //public类型的状态变量，会自动生成相对应的get方法；添加override表示生成的方法会重写继承自父合约与变量同名的函数,也可以自己自助生成相应的方法
    mapping (address => uint256) private balance;

    mapping (address => mapping (address => uint256)) private allow;

    //代币总量
    uint256 private total;
    //代币的名称
    string public name;
    //代币的代号
    string public symbol;

    uint8 public decimals = 18;

    address owner;

    function totalSupply() external override view returns (uint256){
        return total;
    }

    function balanceOf(address _owner) external override view returns (uint256){
        return balance[_owner];
    }

    function allowance(address _owner, address _spender) external override view returns (uint256){
        return allow[_owner][_spender];
    }



    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) external override returns (bool){
        balance[msg.sender] -= _value;
        balance[_to]  += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external override returns (bool success){
        allow[msg.sender][_spender]  = _value;
        emit Approval(msg.sender, _spender,  _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool){
        allow[_from][msg.sender] -= _value;
        balance[_from] -= _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(uint amount) public{
        require(msg.sender == owner, "no permission");
        balance[msg.sender] += amount;
        total += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) public{
        balance[msg.sender] -= amount;
        total -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
```

![image-20221112111451365](README.assets/image-20221112111451365.png)

## Faucet

实现了一个简易的代币水龙头。用户每隔24h可以获取一次代币。

我们的业务逻辑如下：首先编写代币合约，发布代币。接下来在Faucet水龙头合约中，我们mint一定数量的代币。向外提供一个`acquireFaucet`的方法。EOA账号可以通过该方法每隔24h获取一次代币。

```solidity
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
```

![image-20221112213159364](README.assets/image-20221112213159364.png)

![image-20221112213303430](README.assets/image-20221112213303430.png)

![image-20221112213419601](README.assets/image-20221112213419601.png)

![image-20221112213525087](README.assets/image-20221112213525087.png)

![image-20221112213613549](README.assets/image-20221112213613549.png)

![image-20221112213700196](README.assets/image-20221112213700196.png)

![image-20221112213759012](README.assets/image-20221112213759012.png)

## Airdrop

空投。说白了就是白嫖。也是项目方用来进行营销的一种手段。项目方通过智能合约给EOA账号发放指定数量的代币。依然需要用到前面我们编写的ERC20和IERC20这两个合约。

```solidity
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
        //require(token.allowance(msg.sender, address(this)) >= amounts, "Approve ERC20 Token");
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
```

![image-20221113200936792](README.assets/image-20221113200936792.png)

![image-20221113201113845](README.assets/image-20221113201113845.png)

## ERC721

`BTC`以及`ETH`这类代币可以称之为同质化代币。因为挖出来的每一枚代币和其他代币没有什么不同，是同质化的。但是在实际生活中，很多物品却不是同质化的，比如艺术品等。因此以太坊社区提出了`ERC721`标准，用来抽象非同质化物品。

<a href='https://eips.ethereum.org/all'>EIP</a> 

`EIP`全称 `Ethereum Imporvement Proposals`(以太坊改进建议), 是以太坊开发者社区提出的改进建议。

`ERC`全称 Ethereum Request For Comment (以太坊意见征求稿), 用以记录以太坊上应用级的各种开发标准和协议。如`ERC20(Token Standard)`以及`ERC721(Non-Fungible Token Standard)`。

`EIP`包含`ERC`。

在介绍ERC之前，我们先梳理一下`type`的用法。

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC165.sol";
contract TypeDemo {
    
    //type(整形).max/min可以返回最大/最小值
    function max() external pure returns (uint){
        return type(uint).max;
    }

    function mim() external pure returns (uint){
        return type(uint).min;
    }

    //type(Contract):name(合约名称)、creationCode(创建字节码)、runtimeCode(运行字节码)
    //type(Interface).interfaceId(获取一个接口的interfaceId 如果接口只有一个方法 则为方法的selector，否者为所有方法的selector的异或后结果)
    //下面使用了三种方式来获取interfaceId，结果均是一致的
    function typeId() external pure returns (bytes4 a, bytes4 b, bytes4 c){
        a = type(IERC165).interfaceId;
        b = bytes4(keccak256('supportsInterface(bytes4)'));
        c = IERC165.supportsInterface.selector;
    }
}
```

![image-20221113215821399](README.assets/image-20221113215821399.png)

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
interface IERC165 {
    
    /**
     * EIP-165:Standard Interface Detection.检验某个合约有没有实现该接口。如何校验呢？
     * The interface identifier for this interface is 0x01ffc9a7. You can calculate this by running bytes4(keccak256('supportsInterface(bytes4)'));
     * or using the Selector contract above.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
```

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC165.sol";
/**
 * @title ERC-721 Non-Fungible Token Standard
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
interface IERC721 is IERC165 {
    
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    /// 转账事件，转出地址from，转入地址to，以及tokenId
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    ///  授权事件，记录授权地址owner，被授权地址approved和tokenid
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    ///  批量授权事件，记录批量授权的发出地址owner，被授权地址operator和授权与否的approved
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    /// 返回某个地址所拥有的所有的NFT数量
    function balanceOf(address owner) external view returns (uint256 balance);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    /// 返回某个tokenId所属的主人地址
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    /// 安全转账（如果接收方是合约地址，会要求实现ERC721Receiver接口）。参数为转出地址from，接收地址to和tokenId
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    /// 授权另一个地址使用你的NFT。参数为被授权地址approve和tokenId
    function approve(address to, uint256 tokenId) external;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    /// 将自己持有的该系列NFT批量授权给某个地址operator
    function setApprovalForAll(address operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    /// 查询tokenId被批准给了哪个地址
    function getApproved(uint256 tokenId) external view returns (address operator);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    /// 查询某地址的NFT是否批量授权给了另一个operator地址
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
```

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 * 如果进行NFT转账时，接收方是一个合约地址，那么必须要实现IERC721Receiver接口，具有onERC721Received方法，否则NFT直接被打入黑洞
 */
interface IERC721Receiver {
    
  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safeTransfer`. This function MUST return the function selector,
   * otherwise the caller will revert the transaction. The selector to be
   * returned can be obtained as `this.onERC721Received.selector`. This
   * function MAY throw to revert and reject the transfer.
   * Note: the ERC721 contract address is always the message sender.
   * @param operator The address which called `safeTransferFrom` function
   * @param from The address which previously owned the token
   * @param tokenId The NFT identifier which is being transferred
   * @param data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
```

