// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "../erc721/ERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DutchAuction is Ownable, ERC721Metadata("Dutch Auction", "R2W3 Auction") {
    //NFT总数量
    uint256 public constant COLLECTION_SIZE = 1000;
    //竞拍开始价格
    uint256 public constant AUCTION_START_PRICE = 1 ether;
    //竞拍地板价格
    uint256 public constant AUCTION_FLOOR_PRICE = 0.1 ether;
    //竞拍持续时间
    uint256 public constant AUCTION_DURATION_TIME = 10 minutes;
    //无人竞拍时，多久衰减一次价格
    uint256 public constant AUCTION_DECLINE_INTERVAL = 1 minutes;
    //价格衰减率
    uint256 public constant AUCTION_DECLINE_RATE = (AUCTION_START_PRICE - AUCTION_FLOOR_PRICE) / (AUCTION_DURATION_TIME / AUCTION_DECLINE_INTERVAL);

    uint256 public auctionStartTime;

    uint256 private baseTokenURI;

    uint256[] private allTokens;

    constructor(){
        auctionStartTime = block.timestamp;
    }

    //项目方开始拍卖前需要调用该方法
    function setAuctionStartTime(uint256 _timestamp) external onlyOwner {
        auctionStartTime = _timestamp;
    }

    /**
     * block.timestamp < auctionTime,还未开始拍卖-----开始价格
     * block.timestamp - auctionTime > duration_time, 拍卖已经结束-----地板价
     */
    function getAuctionPrice() public view returns (uint){
        if(block.timestamp < auctionStartTime){
            return AUCTION_START_PRICE;
        }else if((block.timestamp - auctionStartTime) >= AUCTION_DURATION_TIME){
            return AUCTION_FLOOR_PRICE;
        }else {
            //衰减了多少次
            uint numberOfDecline = (block.timestamp - auctionStartTime) / AUCTION_DECLINE_INTERVAL;
            return AUCTION_START_PRICE - (AUCTION_DECLINE_RATE * numberOfDecline);
        }
    }
    //目前已经mint出来的token数量
    function totalSupply() public view returns (uint){
        return allTokens.length;
    }

    function _addTokenIndex(uint tokenId) private{
        allTokens.push(tokenId);
    }

    function auctionAndMint(uint number)external payable{
        //建立局部变量，减少gas费
        uint _startTime = auctionStartTime;
        require(_startTime != 0 && block.timestamp >= _startTime, "Sale have not been started");
        require(totalSupply() + number <= COLLECTION_SIZE, "All items have benn minted");
        uint totalCost = getAuctionPrice() * number;
        require(msg.value >= totalCost, "Not enough ETH to mint");
        payable(msg.sender).transfer(msg.value - totalCost);
        for (uint i = 0; i < number; i++) {
            uint mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenIndex(mintIndex);
        }

    }

    //提取所有的eth主币
    function withdraw() external onlyOwner{
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "withdraw failed");
    }

    fallback() external payable{}

    receive() external payable{}

    //定义一个方法，发行ERC721代币，需要继承当前合约，并且实现该方法
    function _baseURI() internal pure override returns (string memory){
        return "";
    }
}