// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../erc721/IERC165.sol";
import "../erc721/Address.sol";

contract ERC1155 is IERC165, IERC1155, IERC1155MetadataURI{

    using Address for address;

    //代币种类id到账户account以及余额之间的映射关系
    mapping (uint256 => mapping (address => uint)) balances;

    //address到授权地址的授权映射关系
    mapping (address => mapping (address => bool)) operatorApprovals;


    function supportsInterface(bytes4 interfaceId) external pure override returns (bool){
        return interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    //实现Metadata接口
    function uri(uint256 id) external view override returns (string memory){

    }

    /**
     * 查询持仓量。但是和ERC721不同的是不仅需要输入查询的账号，还需要币种编号
     */
    function balanceOf(address _account, uint256 _id) public view override returns (uint256){
        require(_account != address(0), "ERC1155:address zero is not a valid address");
        return balances[_id][_account];
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     * 批量查询持仓量
     */
    function balanceOfBatch(address[] memory _accounts, uint256[] memory _ids)public view override returns (uint256[] memory){
        require(_accounts.length == _ids.length, "ERC1155: accounts and ids length mismatch");
        uint256[] memory batchBalances = new uint256[](_accounts.length);
        for (uint i = 0; i < _accounts.length; i++) {
            batchBalances[i] = balanceOf(_accounts[i], _ids[i]);
        }
        return batchBalances;
    }

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     * 批量授权，触发ApprovalForAll事件
     */
    function setApprovalForAll(address _operator, bool _approved) override public{
        address owner = msg.sender;
        require(owner != _operator, "ERC1155: setting approval status for self");
        operatorApprovals[owner][_operator] = _approved;
        emit ApprovalForAll(owner, _operator, _approved);
    }

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     * 查询批量授权信息
     */
    function isApprovedForAll(address _account, address _operator) public view override returns (bool){
        return operatorApprovals[_account][_operator];
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     * 单币种安全转账，触发TransferSingle事件。
     * 注意事项：
     * 1.to不可以是0地址
     * 2._from要么是转出方、要么是转出方授权的地址
     * 3._from必须币种编号_id有至少有_amount代币
     * 4._to如果是一个合约地址，则必须实现IERC1155Receiver-onERC1155Received
     */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) override public{
        //必须是当前转账方调用或者授权给某个合约来进行转账
        address operator = msg.sender;
        require(_from == operator || isApprovedForAll(_from, operator), "ERC1155: caller is not token owner or approved");
        require(_to != address(0), "ERC1155: can not transfer to the zero address");
        uint256 fromBalance = balances[_id][_from];
        require(fromBalance >= _amount, "ERC1155: insufficient balance for transfer");
        //安全检查
        _safeTransferCheck(operator, _from, _to, _id, _amount, _data);
        balances[_id][_from] = fromBalance - _amount;
        balances[_id][_to] += _amount;
        emit TransferSingle(operator, _from, _to, _id, _amount);
    }

    function _safeTransferCheck(address _operator, address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) private{
        if(_to.isContract()){
            try IERC1155Receiver(_to).onERC1155Received(_operator, _from, _id, _amount, _data) returns (bytes4 result) {
                if(result != IERC1155Receiver.onERC1155Received.selector){
                    revert("ERC1155:ERC1155Receiver rejected");
                }
            } catch  {
                revert("ERC1155:receiver do not implement ERC1155Receiver");
            }
        }
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     * 多币种批量安全转账。触发TransferBatch事件。
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) override external{}
}