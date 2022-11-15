// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./ERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract ERC721 is ERC165, IERC721 {

    using Address for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

/*
   * 0x80ac58cd ===
   *   bytes4(keccak256('balanceOf(address)')) ^
   *   bytes4(keccak256('ownerOf(uint256)')) ^
   *   bytes4(keccak256('approve(address,uint256)')) ^
   *   bytes4(keccak256('getApproved(uint256)')) ^
   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
   */
  bytes4 private constant ERC721_InterfaceId = 0x80ac58cd;

    constructor(){
        registerInterface(ERC721_InterfaceId);
    }
    //地址和该地址的NFT数量的映射关系
    mapping (address => uint) balances;
    //tokenId和所属地址之间的映射关系
    mapping (uint => address) owners;

    //某tokenId和授权地址的映射关系(每个token在同一时间只可以授权给一个地址)
    mapping (uint => address) tokenApprovals;
    //将owner地址授权给operator的映射关系
    mapping (address => mapping (address => bool)) operatorApprovals;

    //返回某个地址拥有的NFT的数量
    function balanceOf(address _owner) external view override returns (uint256 balance){
        require(_owner != address(0), "black hole address");
        balance = _balances[_owner];
    }

    //返回某个tokenId所属的地址
    function ownerOf(uint256 _tokenId) external view override returns (address owner){
        owner = owners[_tokenId];
        require(owner != address(0), "token is in the black hole");
    }
  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   * 安全的转账，为了保证接收地址如果是合约，如果没有实现onERC721Received会出错
   */
    function safeTransferFrom(address _from,address _to,uint256 _tokenId,bytes calldata _data) external override{
        transferFrom(_from, _to, _tokenId);
        require(_checkERC721Received(_from, _to, _tokenId, _data));
    }

    //如果是合约，则必须实现该接口，否则NFT发送到该合约便消失了
    function _checkERC721Received(address _from,address _to,uint256 _tokenId,bytes calldata _data)internal returns (bool){
        if(!_to.isContract()){
            return true;
        }
        bytes4 code = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return code == ERC721_RECEIVED;
    }

 
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external override{
        safeTransferFrom(_from, _to, _tokenId, "");
    }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
    function transferFrom(address _from, address _to, uint256 _tokenId) external override{
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));
        //清除授权
        _clearApproval(_from, _tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    function _addTokenTo(address _to, uint _tokenId)internal {
        require(owners[_tokenId] = address(0));
        balances[_to] += 1;
        owners[_tokenId] = _to;
    }

    function _removeTokenFrom(address _from, uint _tokenId)internal {
        require(ownerOf(_tokenId) == _from);
        balances[_from] -= 1;
        owners[_tokenId] = address(0);
    }

    //清除授权信息
    function _clearApproval(address _owner, uint _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        tokenApprovals[_tokenId] = address(0);
    }

    //是否是授权地址或者是拥有者
    function _isApprovedOrOwner(address _caller, uint _tokenId) internal view returns (bool){
        address owner = ownerOf(_tokenId);
        //三种情况：1.拥有者 2.当前tokenId授权给了该地址 3.将当前地址下的所有NFT全部授权给了该地址
        return (_caller == owner || getApproved(_tokenId) == _caller || isApprovedForAll(owner, _caller));
    }



    /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   * 将tokenId授权给to地址；
   */
    function approve(address _to, uint256 _tokenId) external override{
        //获取当前tokenId的拥有者
        address owner = ownerOf(_tokenId);
        //不要自己给自己发送
        require(owner != _to);
        //仅当前tokenId拥有者或者授权的合约地址可以调用该方法;isApprovedForAll查询owner地址的NFT是否批量授权给msg.sender调用者
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
        //将_tokenId授权给_to地址
        tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _operator operator address to set the approval
   * @param _approved representing the status of the approval to be set
   * 将全部代币授权给operator地址或者撤销授权
   */
    function setApprovalForAll(address _operator, bool _approved) external override{
        require(_operator != msg.sender);
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * Reverts if the token ID does not exist.
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return operator currently approved for the given token ID
   * 查询当前tokenId的授权地址
   */
    function getApproved(uint256 _tokenId) external override view returns (address operator){
        require(_exists(_tokenId));
        operator = tokenApprovals[_tokenId];
    }

    /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function _exists(uint256 _tokenId) internal view returns (bool) {
    address owner = owners[tokenId];
    return owner != address(0);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
    function isApprovedForAll(address _owner, address _operator) external override view returns (bool){
        return operatorApprovals[_owner][_operator];
    }

    /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param _to The address that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    _addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(uint256 _tokenId) internal {
    address owner = ownerOf(_tokenId);
    require(msg.sender == owner, "you can not burn someone else's token")
    _clearApproval(owner, tokenId);
    _removeTokenFrom(owner, tokenId);
    emit Transfer(owner, address(0), tokenId);
  }
}