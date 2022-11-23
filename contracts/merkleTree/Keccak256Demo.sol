// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
contract Keccak256Demo {
    
    function singleHash() external view  returns (bytes32){
        address callerAddress = msg.sender;
        return keccak256(_toBytes(callerAddress));
    }

    function combineHash(bytes32 _b1, bytes32 _b2) external pure returns (bytes32){
       return _b1 < _b2 ? keccak256(abi.encodePacked(_b1, _b2)) : keccak256(abi.encodePacked(_b2, _b1));
    }

    function _toBytes(address a) internal pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, a)
            )
            mstore(0x40, add(m, 52))
            b := m
        }
    }

}