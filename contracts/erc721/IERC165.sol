// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
interface IERC165 {
    
    /**
     * EIP-165:Standard Interface Detection.检验某个合约有没有实现该接口。如何校验呢？
     * The interface identifier for this interface is 0x01ffc9a7. You can calculate this by running bytes4(keccak256('supportsInterface(bytes4)'));
     * or using the Selector contract above.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}