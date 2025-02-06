// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {LibERC721} from "src/libraries/LibERC721.sol";
import "src/libraries/constants/Types.sol";

library LibAgentNFT {
    struct AgentNFTStorage {
        mapping(uint256 => AgentData) agentDatas;
    }

    // keccak256(abi.encode(uint256(keccak256("agentnft.storage.diamond.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AGENTNFT_STORAGE_LOCATION =
        0x9e5bda809b0828c294a743c88c0dcc87e6fd26e0925fe8039b4aa3850bc35700;

    function _getAgentNFTStorage()
        internal
        pure
        returns (AgentNFTStorage storage $)
    {
        assembly {
            $.slot := AGENTNFT_STORAGE_LOCATION
        }
    }

    function mint(
        AgentData memory _agentData,
        string memory _agentDetailsURI
    ) external {
        uint256 currentTokenId = LibERC721.totalSupply() + 1;
        LibERC721._mint(msg.sender, currentTokenId);
        _getAgentNFTStorage().agentDatas[
            currentTokenId
        ] = _agentData;
        LibERC721._setTokenURI(currentTokenId, _agentDetailsURI);
    }

    function getAgentType(
        uint256 agentId
    ) external view returns (AgentType agentType) {
        agentType = _getAgentNFTStorage().agentDatas[agentId].agentType;
    }

    function getAgentData(
        uint256 tokenId
    ) external view returns (AgentData memory agentData_) {
        agentData_ = _getAgentNFTStorage().agentDatas[tokenId];
    }
}
