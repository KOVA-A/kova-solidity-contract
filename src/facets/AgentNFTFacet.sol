// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {LibAgentNFT} from "src/libraries/LibAgentNFT.sol";
import {LibERC721} from "src/libraries/LibERC721.sol";
import "src/libraries/constants/Types.sol";

contract AgentNFTFacet {
    function name() external view returns (string memory) {
        return LibERC721._getERC721Storage()._name;
    }

    function symbol() external view returns (string memory) {
        return LibERC721._getERC721Storage()._symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return LibERC721.tokenURI(tokenId);
    }

    function mint(
        AgentData memory _agentData,
        string memory _agentDetailsURI
    ) external {
        LibAgentNFT.mint(_agentData, _agentDetailsURI);
    }

    function getAgentType(
        uint256 agentId
    ) external view returns (AgentType agentType) {
        agentType = LibAgentNFT.getAgentType(agentId);
    }

    function getAgentData(
        uint256 tokenId
    )
        external
        view
        returns (
            string memory name_,
            string memory description,
            string memory model,
            string memory userPromptURI,
            string memory systemPromptURI,
            bool promptsEncrypted
        )
    {
        AgentData memory agentData_ = LibAgentNFT.getAgentData(tokenId);
        return (
            agentData_.name,
            agentData_.description,
            agentData_.model,
            agentData_.userPromptURI,
            agentData_.systemPromptURI,
            agentData_.promptsEncrypted
        );
    }

    // ERC721 functions

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

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool) {
        return LibERC721.isApprovedForAll(_owner, _operator);
    }
}
