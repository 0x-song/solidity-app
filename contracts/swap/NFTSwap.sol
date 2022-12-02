// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
import "../erc721/IERC721Receiver.sol";
contract NFTSwap is IERC721Receiver{

    fallback() external payable{}
    //需要接收eth主币
    receive() external payable{}

    //NFTSwap需要中转接收用户挂单发送过来的NFT，所以需要实现IERC721Receiver，否则无法接收
    function onERC721Received(address operator, address from,uint tokenId,bytes calldata data) external override returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    constructor() {
        
    }
}