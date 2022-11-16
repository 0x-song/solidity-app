// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./ERC165.sol";
import "./ERC721.sol";
import "./IERC721Metadata.sol";
import "./Strings.sol";

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata{

    string internal tokenName;

    string internal tokenSymbol;

    using Strings for uint256;

  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */
    bytes4 private constant ERC721Metadata_InterfaceId = 0x5b5e139f;

    constructor(string memory _name, string memory _symbol) {
        tokenName = _name;
        tokenSymbol = _symbol;
        registerInterface(ERC721Metadata_InterfaceId);
    }

    function name() external override view returns (string memory){
        return tokenName;
    }

    function symbol() external override view returns (string memory){
        return tokenSymbol;
    }

    function tokenURI(uint256 tokenId) external override view returns (string memory){
        require(_exists(tokenId));
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    //定义一个方法，发行ERC721代币，需要继承当前合约，并且实现该方法
    function _baseURI() internal view virtual returns (string memory){
        return "";
    }
}