// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
contract ECDSASignature {
    
    /**
     * 在实际交互过程中，第二个参数地址可以直接获取，但是为了我们此处测试方便，直接进行赋值
     */
    function packedMessageHash(string memory _message, address _account) public pure returns (bytes32) {
        bytes memory data = abi.encodePacked(_message, _account);
        return keccak256(data);
    }

    /**
     * https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign
     * https://eips.ethereum.org/EIPS/eip-191
     */
    function ethSignedHashMessage(bytes32 _hash) public pure returns (bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }
}