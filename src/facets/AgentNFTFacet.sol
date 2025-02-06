// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {LibAgentNFT} from "src/libraries/LibAgentNFT.sol";
import {LibERC721} from "src/libraries/LibERC721.sol";
import "src/libraries/constants/Types.sol";

contract AgentNFTFacet {
    function initialize() external {
        LibERC721.ERC721Storage storage $ = LibERC721._getERC721Storage();
        $._name = "AgentNFT";
        $._symbol = "KOVA";
    }

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
        uint256 currentTokenId = LibERC721.totalSupply() + 1;
        LibERC721._mint(msg.sender, currentTokenId);
        LibAgentNFT._getAgentNFTStorage().agentDatas[
            currentTokenId
        ] = _agentData;
        LibERC721._setTokenURI(currentTokenId, _agentDetailsURI);
    }

    function getAgentType(
        uint256 agentId
    ) external view returns (AgentType agentType) {
        agentType = LibAgentNFT
            ._getAgentNFTStorage()
            .agentDatas[agentId]
            .agentType;
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
        AgentData memory agentData_ = LibAgentNFT
            ._getAgentNFTStorage()
            .agentDatas[tokenId];
        return (
            agentData_.name,
            agentData_.description,
            agentData_.model,
            agentData_.userPromptURI,
            agentData_.systemPromptURI,
            agentData_.promptsEncrypted
        );
    }
}
