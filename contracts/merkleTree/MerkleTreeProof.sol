// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
library MerkleTreeProof {
    
    /**
     * 利用leaf节点和给定的proof，推算出一个root值，如果和给定的root值相等，则说明leaf在Merkle Tree中
     */
    function verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf) public pure returns(bool){
        return _proofProcedure(proof, leaf) == root;
    }

    function _proofProcedure(bytes32[] calldata _proof, bytes32 _leaf) internal pure returns(bytes32){
        bytes32 computedHash = _leaf;
        for (uint i = 0; i < _proof.length; i++) {
            computedHash = _combineHash(computedHash, _proof[i]);
        }
        return computedHash;
    }

    /**
     * 排序之后进行hash运算，保障无论顺序如何得到的hash值永远是相同的
     */
    function _combineHash(bytes32 _b1, bytes32 _b2) internal pure returns(bytes32){
        return _b1 < _b2 ? keccak256(abi.encodePacked(_b1, _b2)) : keccak256(abi.encodePacked(_b2, _b1));
    }
}