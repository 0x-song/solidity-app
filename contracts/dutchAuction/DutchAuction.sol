// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "../erc721/ERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DutchAuction is Ownable, ERC721Metadata("Dutch Auction", "R2W3 Auction") {
    constructor(){
        
    }

    //定义一个方法，发行ERC721代币，需要继承当前合约，并且实现该方法
    function _baseURI() internal view override returns (string memory){
        return "";
    }
}