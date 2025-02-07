// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {LibERC721} from "src/libraries/LibERC721.sol";
import {LibAgentNFT} from "src/libraries/LibAgentNFT.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "src/libraries/constants/Types.sol";
import "src/libraries/constants/Errors.sol";
import "src/libraries/constants/Events.sol";

library LibAgentRoom {
    using EnumerableMap for EnumerableMap.UintToUintMap;

    struct AgentRoomStorage {
        EnumerableMap.UintToUintMap agentRooms;
        mapping(uint256 => EnumerableMap.UintToUintMap) roomAgents2;
        // roomId => agentIDs
        mapping(uint256 => uint256[]) roomAgents;
        // agentID => roomIdPosition
        mapping(uint256 => uint256) agentRoomPosition;
    }

    // keccak256(abi.encode(uint256(keccak256("agentroom.storage.diamond.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AGENTROOM_STORAGE_LOCATION =
        0x0684d24082dd6910851205f7b7dcea9a01cec5d71b932f67cc926c6c18323c00;

    function _getAgentRoomStorage() internal pure returns (AgentRoomStorage storage $) {
        assembly {
            $.slot := AGENTROOM_STORAGE_LOCATION
        }
    }

    uint256 private constant MAX_AGENTS = 2;

    function createRoom(uint8 roomType, uint256 agentID) external returns (uint256 roomId) {
        if (LibERC721.ownerOf(agentID) != msg.sender) {
            revert AgentRoom__OnlyOwnerCanCreateRoom();
        }

        AgentType agentType;
        (agentType,,) = LibAgentNFT.getAgentExtraData(agentID);
        if (agentType == AgentType.Investor) {
            revert AgentRoom__OnlyTraderCanCreateRoom();
        }

        bytes32 roomIdHash = keccak256(abi.encode(agentID, roomType));

        roomId = uint256(roomIdHash);
        _getAgentRoomStorage().roomAgents[roomId].push(agentID);
        _getAgentRoomStorage().roomAgents2[roomId].set(0, agentID);
        emit RoomCreated(roomId, roomType, agentID);
    }

    function joinRoom(uint256 roomId, uint8 roomType, uint256 agentID) public {
        if (LibERC721.ownerOf(agentID) != msg.sender) {
            revert AgentRoom__OnlyOwnerCanCreateRoom();
        }

        AgentType agentType;
        (agentType,,) = LibAgentNFT.getAgentExtraData(agentID);
        if (agentType == AgentType.Trader) {
            revert AgentRoom__OnlyInvestorsCanJoinRoom();
        }

        AgentRoomStorage storage $ = _getAgentRoomStorage();
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
        return _getAgentRoomStorage().roomAgents2[roomId].get(roomId);
    }

    function getRoomParticipants(uint256 roomId) public view returns (uint256[] memory) {
        return _getAgentRoomStorage().roomAgents[roomId];
    }

    function getAllRoomParticipants(uint256 roomId) public view returns (uint256[] memory agentIDs) {
        uint256 agentRoomLength = _getAgentRoomStorage().roomAgents2[roomId].length();
        for (uint256 i; i < agentRoomLength;) {
            agentIDs[i] = _getAgentRoomStorage().roomAgents2[roomId].get(i);
            unchecked {
                ++i;
            }
        }
    }

    function viewAgentRoomStatus(uint256 roomId) public view returns (string memory) {
        uint256 agentRoomLength = _getAgentRoomStorage().roomAgents2[roomId].length();
        if (agentRoomLength == MAX_AGENTS) {
            return "In progress";
        } else if (agentRoomLength == 1) {
            return "Open";
        } else {
            return "Closed";
        }
    }
}
