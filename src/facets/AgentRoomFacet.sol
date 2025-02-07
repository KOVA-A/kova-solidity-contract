// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {AgentNFT} from "src/agentNFT/AgentNFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {LibAgentRoom} from "src/libraries/LibAgentRoom.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "src/libraries/constants/Events.sol";
import "src/libraries/constants/Errors.sol";
import "src/libraries/constants/Types.sol";

contract AgentRoomFacet is IERC721Receiver {
    using EnumerableMap for EnumerableMap.UintToUintMap;

    uint256 private constant MAX_AGENTS = 2;

    AgentNFT private constant AGENTNFT =
        AgentNFT(0xEF78E7D23A02a404D348a0f37ac0fF4D10991D1a);

    function createRoom(
        uint8 roomType,
        uint256 agentID
    ) external returns (uint256 roomId) {
        if (AGENTNFT.ownerOf(agentID) != msg.sender) {
            revert AgentRoom__OnlyOwnerCanCreateRoom();
        }

        AgentType agentType;
        (agentType, , , ) = AGENTNFT.getAgentExtraData(agentID);
        if (agentType == AgentType.Investor) {
            revert AgentRoom__OnlyTraderCanCreateRoom();
        }

        bytes32 roomIdHash = keccak256(abi.encode(agentID, roomType));

        roomId = uint256(roomIdHash);
        LibAgentRoom._getAgentRoomStorage().roomAgents[roomId].push(agentID);
        LibAgentRoom._getAgentRoomStorage().roomAgents2[roomId].set(0, agentID);
        emit RoomCreated(roomId, roomType, agentID);
    }

    function joinRoom(uint256 roomId, uint8 roomType, uint256 agentID) public {
        if (AGENTNFT.ownerOf(agentID) != msg.sender) {
            revert AgentRoom__OnlyOwnerCanCreateRoom();
        }

        AgentType agentType;
        (agentType, , , ) = AGENTNFT.getAgentExtraData(agentID);
        if (agentType == AgentType.Trader) {
            revert AgentRoom__OnlyInvestorsCanJoinRoom();
        }

        LibAgentRoom.AgentRoomStorage storage $ = LibAgentRoom._getAgentRoomStorage();
        uint256[] memory agentIDs = $.roomAgents[roomId];
        $.roomAgents[roomId].push(agentID);
        uint256 agentRoomPosition = $.roomAgents2[roomId].length();
        $.roomAgents2[roomId].set(agentRoomPosition, agentID);

        if (agentIDs.length > MAX_AGENTS) {
            emit RoomFull(roomId, roomType, agentIDs);
            revert AgentRoom__MaxAgentsExceeded();
        }
    }

    function leaveRoom(uint256 roomId, uint8 roomType, uint256 agentID) public {
        emit RoomLeft(roomId, roomType, agentID);
    }

    function getRoomParticipant(uint256 roomId) public view returns (uint256) {
        return LibAgentRoom._getAgentRoomStorage().roomAgents2[roomId].get(roomId);
    }

    function getRoomParticipants(
        uint256 roomId
    ) public view returns (uint256[] memory) {
        return LibAgentRoom._getAgentRoomStorage().roomAgents[roomId];
    }

    function getAllRoomParticipants(
        uint256 roomId
    ) public view returns (uint256[] memory agentIDs) {
        uint256 agentRoomLength = LibAgentRoom._getAgentRoomStorage()
            .roomAgents2[roomId]
            .length();
        for (uint256 i; i < agentRoomLength; ) {
            agentIDs[i] = LibAgentRoom._getAgentRoomStorage().roomAgents2[roomId].get(i);
            unchecked {
                ++i;
            }
        }
    }

    function viewAgentRoomStatus(
        uint256 roomId
    ) public view returns (string memory) {
        uint256 agentRoomLength = LibAgentRoom._getAgentRoomStorage()
            .roomAgents2[roomId]
            .length();
        if (agentRoomLength == MAX_AGENTS) {
            return "In progress";
        } else if (agentRoomLength == 1) {
            return "Open";
        } else {
            return "Closed";
        }
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
