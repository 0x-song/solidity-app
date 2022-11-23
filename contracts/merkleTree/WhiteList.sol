// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "../erc721/Road2Web3.sol";
import "./MerkleTreeProof.sol";
/**
 * 利用白名单来mint，如果用户很多，怎么验证某个用户是否在白名单中。挨个遍历太浪费gas。可以使用Merkle Proof
 */
contract WhiteList is Road2Web3("Road2Web3Dao", "r2w3"){
    //记录Merkle Tree Root
    bytes32 immutable public merkleRoot;
    //是否已经mint过的地址
    mapping (address => bool) public mintedAddress;

    uint public tokenId;

    constructor(bytes32 _merkleRoot){
        merkleRoot = _merkleRoot;
    }

    function mint(bytes32[] calldata  _proof) external{
        require(mintedAddress[msg.sender] == false, "current address already minted");
        require(_verify(_leafHash(msg.sender), _proof), "invalid merkle proof");
        tokenId ++;
        mint(tokenId);
    }

    //这种方法也可以将address类型转换成了bytes类型
    function _leafHash(address _account) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] calldata _proof) internal view returns (bool){
        return MerkleTreeProof.verify(_proof, merkleRoot, _leaf);
    }
    
}