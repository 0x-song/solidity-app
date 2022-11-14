// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC165.sol";
contract ERC165 is IERC165{

  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */
    bytes4 private constant ERC165_InterfaceId = 0x01ffc9a7;

    mapping (bytes4 => bool) supportedInterfaces;

    constructor() {
        registerInterface(ERC165_InterfaceId);
    }

    function registerInterface(bytes4 _interfaceId) internal{
        require(_interfaceId != 0xffffffff);
        supportedInterfaces[_interfaceId] = true;
    }

    //特别注意：定长数组属于值类型，不属于引用类型，所以参数位置不需要添加memory
    function supportsInterface(bytes4 _interfaceId) external override view returns (bool){
        return supportedInterfaces[_interfaceId];
    }

}