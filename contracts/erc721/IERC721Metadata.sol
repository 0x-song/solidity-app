// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./IERC721.sol";
/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
interface IERC721Metadata is IERC721 {
    
    //返回代币名称
    function name() external view returns (string memory);

    //返回代币代号
    function symbol() external view returns (string memory);

    //通过tokenId查询链接url
    function tokenURI(uint256 tokenId) external view returns (string memory);

}
