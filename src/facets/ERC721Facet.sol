// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {LibERC721} from "src/libraries/LibERC721.sol";

contract ERC721Facet {
    function balanceOf(address _owner) external view returns (uint256) {
        return LibERC721.balanceOf(_owner);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return LibERC721.ownerOf(_tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        LibERC721.safeTransferFrom(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
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
}