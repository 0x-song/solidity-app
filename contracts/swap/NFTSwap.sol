// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
import "../erc721/IERC721Receiver.sol";
import "../erc721/IERC721.sol";
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

    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);

    event Buy(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);

    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);

    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice);

    struct Order{
        address owner;
        uint price;
    }

    //NFT合约地址以及对应的tokenId和订单的映射关系
    mapping (address => mapping (uint256 => Order)) nftList;

    /**
     * 卖家挂单上架nft,将指定的NFT发送到当前合约中来
     */
    function list(address _nftAddr, uint256 _tokenId, uint256  _price) public{
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.getApproved(_tokenId) == address(this), "approve contract first");
        require(_price > 0);
        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    /**
     * 撤销挂单
     */
    function revoke(address _nftAddr, uint256 _tokenId) public{
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(msg.sender == _order.owner, "You are not the owner.You do not have permission");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "wrong arguments");
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public{
        require(_newPrice > 0, "invalid price");
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "you do not have permission");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) ==  address(this), "wrong parameter");
        _order.price = _newPrice;
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    function buy(address _nftAddr, uint256  _tokenId) public payable{
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0, "invalid price");
        require(msg.value >= _order.price, "insufficient price");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "wrong parameter");
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        payable(msg.sender).transfer(msg.value - _order.price);
        payable(_order.owner).transfer(_order.price);
        delete nftList[_nftAddr][_tokenId];
        emit Buy(msg.sender, _nftAddr, _tokenId, _order.price);
    }
}