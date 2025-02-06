// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {AgentNFT} from "src/facets/AgentNFT.sol";
import "src/libraries/constants/Events.sol";
import "src/libraries/constants/Errors.sol";
import "src/libraries/constants/Types.sol";

contract AgentRoom is ERC721Holder {
    // Room state variables
    uint256 private constant MAX_AGENTS = 2;
    AgentNFT private constant agentNFTContract =
        AgentNFT(0x222BeC22E51ee73363Fde9eB6f4212FA7f9780bc);

    mapping(uint256 => uint256[]) private roomAgents;

    function createRoom(
        uint8 roomType,
        uint256 agentID
    ) external returns (uint256 roomId) {
        if (agentNFTContract.ownerOf(agentID) != msg.sender)
            revert AgentRoom__OnlyOwnerCanCreateRoom();
            
        AgentType agentType = agentNFTContract.getAgentType(agentID);
        if (agentType == AgentType.Investor)
            revert AgentRoom__OnlyTraderCanCreateRoom();

        bytes32 roomIdHash = keccak256(abi.encode(agentID, roomType));

        roomId = uint256(roomIdHash);
        roomAgents[roomId].push(agentID);
        emit RoomCreated(roomId, roomType, agentID);
    }

    function joinRoom(uint256 roomId, uint8 roomType, uint256 agentID) public {
        if (agentNFTContract.ownerOf(agentID) != msg.sender)
            revert AgentRoom__OnlyOwnerCanCreateRoom();

        AgentType agentType = agentNFTContract.getAgentType(agentID);
        if (agentType == AgentType.Trader)
            revert AgentRoom__OnlyInvestorsCanJoinRoom();

        uint256[] memory agentIDs = roomAgents[roomId];
        if (agentIDs.length > MAX_AGENTS) revert AgentRoom__MaxAgentsExceeded();

        emit RoomFull(roomId, roomType, agentIDs);
    }

    function leaveRoom(
        uint256 roomId,
        uint8 roomType,
        uint256[] memory agentIDs
    ) public {
        emit RoomFull(roomId, roomType, agentIDs);
    }
}
