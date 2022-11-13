// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC165.sol";
contract TypeDemo {
    
    function max() external pure returns (uint){
        return type(uint).max;
    }

    function mim() external pure returns (uint){
        return type(uint).min;
    }

    function typeId() external pure returns (bytes4 a, bytes4 b, bytes4 c){
        a = type(IERC165).interfaceId;
        b = bytes4(keccak256('supportsInterface(bytes4)'));
        c = IERC165.supportsInterface.selector;
    }
}