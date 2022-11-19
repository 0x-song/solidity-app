// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "../erc721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//采用英式拍卖拍卖NFT中的第1号藏品
//设定拍卖时间为12h，由最高竞拍者获得
contract EnglishAuction is Ownable{
    
    IERC721 public nftAddress;

    //要拍卖的是NFT中的哪个藏品
    uint public tokenId;

    uint public auctionStartTime;

    uint256 public constant AUCTION_DURATION_TIME = 5 minutes;

    constructor(address _nftAddress, uint _tokenId){
        nftAddress = IERC721(_nftAddress);
        tokenId = _tokenId;
    }

    function setAuctionStartTime(uint _timestamp) external onlyOwner{
        auctionStartTime = _timestamp;
    }


}