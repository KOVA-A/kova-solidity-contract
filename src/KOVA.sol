// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Diamond} from "src/Diamond.sol";
import {FacetCut} from "src/interfaces/IDiamondCut.sol";
import {DiamondInitArgs} from "src/libraries/LibDiamond.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {LibERC721} from "src/libraries/LibERC721.sol";
import {LibDiamond} from "src/libraries/LibDiamond.sol";

/// @notice KOVA is a diamond contract that inherits from Diamond.
/// @author KOVA (https://github.com/KOVA-A/solidity-contract)
contract KOVA is Diamond, IERC721 {
    constructor(address admin, FacetCut[] memory facets, DiamondInitArgs memory initData)
        Diamond(admin, facets, initData)
    {}

    // ERC721 Metadata functions

    function name() external view returns (string memory) {
        return LibERC721._getERC721Storage()._name;
    }

    function symbol() external view returns (string memory) {
        return LibERC721._getERC721Storage()._symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return LibERC721.tokenURI(tokenId);
    }

    // ERC721 functions

    function balanceOf(address _owner) external view returns (uint256) {
        return LibERC721.balanceOf(_owner);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return LibERC721.ownerOf(_tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external {
        LibERC721.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        LibERC721.safeTransferFrom(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        LibERC721.transferFrom(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external {
        LibERC721.approve(_approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        LibERC721.setApprovalForAll(_operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return LibERC721.getApproved(_tokenId);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return LibERC721.isApprovedForAll(_owner, _operator);
    }

    // This implements ERC-165.
    function supportsInterface(bytes4 _interfaceId) external view override returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return _interfaceId == type(IERC721).interfaceId || ds.supportedInterfaces[_interfaceId];
    }
}
