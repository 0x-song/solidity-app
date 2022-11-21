// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "../erc721/Road2Web3.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//采用英式拍卖拍卖NFT中的第1号藏品
//设定拍卖时间为12h，由最高竞拍者获得
//竞拍时需要将主币转移到合约中，如果目前出价最高，则拍下不允许撤销拍卖
//如果有其他人出更高价格，那么当前竞拍者可以提取出代币，再次进行竞拍；或者直接放弃等等......
contract EnglishAuction is Ownable{
    
    //要拍卖的是哪个NFT
    Road2Web3 public nftAddress;
    //NFT中的几号藏品
    uint public tokenId;

    //出售方，可以是个人，也可以是项目方，也就是拥有上述tokenId的账户
    address public seller;

    uint public auctionStartTime;

    uint public constant AUCTION_DURATION_TIME = 5 minutes;

    //最高报价
    uint public highestBid;

    //最高报价的出价人
    address public highestBidder;

    //不是最高竞价的竞拍者和竞拍价格的映射
    mapping (address => uint) public withdraw;

    constructor(uint _tokenId, address _nftAddress){
        tokenId = _tokenId;
        nftAddress = Road2Web3(_nftAddress);
    }

    //卖家授权挂牌拍卖
    function listToSell() external{
        require(nftAddress.ownerOf(tokenId) == msg.sender, "you don't the item");
        seller = msg.sender;
        //(bool result, ) = address(nftAddress).delegatecall(abi.encodeWithSignature("approve(address,uint256)", address(this), tokenId));
        //nftAddress.approve(address(this), tokenId);
        //require(result, "approve failed");
    }

    function setAuctionStartTime(uint _timestamp) external onlyOwner{
        auctionStartTime = _timestamp;
    }

    function bid() external payable{
        require(block.timestamp >= auctionStartTime, "auction has not started");
        require((auctionStartTime + AUCTION_DURATION_TIME) > block.timestamp, "auction has ended");
        require(msg.value > highestBid, "you must bid higger");
        if(highestBid != 0){
            //如果有新的竞拍者出了更高的价格，那么之前的竞拍者就不是最高出价了，它可以选择退出拍卖，拿回现金；或者继续追加
            withdraw[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
    }
    //竞拍失败的竞拍者可以随时取出竞拍金
    function withdrawMoney() external {
        uint balance = withdraw[msg.sender];
        require(balance != 0, "you can not withdraw");
        withdraw[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }
    //竞拍成功的竞拍者可以mint No.1 NFT
    function claim() external{
        require(msg.sender == highestBidder, "only highest bidder can mint");
        nftAddress.safeTransferFrom(seller, highestBidder, tokenId);
    }
}