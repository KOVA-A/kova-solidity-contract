// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {AgentNFT} from "src/agentNFT/AgentNFT.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "src/libraries/constants/Events.sol";
import "src/libraries/constants/Errors.sol";
import "src/libraries/constants/Types.sol";

contract AgentRoom is Ownable, IERC721Receiver {
    using EnumerableMap for EnumerableMap.UintToUintMap;

    uint256 private constant MAX_AGENTS = 2;
    AgentNFT private agentNFT;

    // Storage
    EnumerableMap.UintToUintMap agentRooms;
    mapping(uint256 => EnumerableMap.UintToUintMap) roomAgents2;
    // roomId => agentIDs
    mapping(uint256 => uint256[]) roomAgents;
    // agentID => roomIdPosition
    mapping(uint256 => uint256) agentRoomPosition;
    mapping(uint256 => mapping(uint256 => address)) roomParticipants;
    uint256 roomIdCount;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setAgentNFT(address _agentNFT) external onlyOwner {
        agentNFT = AgentNFT(_agentNFT);
    }

    function createRoom(uint256 agentID) external returns (uint256 roomId_) {
        if (agentNFT.ownerOf(agentID) != msg.sender) {
            revert AgentRoom__OnlyOwnerCanCreateRoom();
        }

        AgentType agentType;
        (agentType,,,) = agentNFT.getAgentExtraData(agentID);
        if (agentType == AgentType.Investor) {
            revert AgentRoom__OnlyTraderCanCreateRoom();
        }

        // bytes32 roomIdHash = keccak256(abi.encode(agentID, roomType));

        roomId_ = roomIdCount + 1;
        roomIdCount = roomId_;

        roomParticipants[agentID][roomId_] = msg.sender;

        agentNFT.safeTransferFrom(msg.sender, address(this), agentID);

        roomAgents[roomId_].push(agentID);
        roomAgents2[roomId_].set(0, agentID);
        emit RoomCreated(roomId_, agentID);
    }

    function joinRoom(uint256 roomId, uint256 agentID) public {
        if (AGENTNFT.ownerOf(agentID) != msg.sender) {
            revert AgentRoom__OnlyOwnerCanCreateRoom();
        }

        AgentType agentType;
        (agentType,,,) = agentNFT.getAgentExtraData(agentID);
        if (agentType == AgentType.Trader) {
            revert AgentRoom__OnlyInvestorsCanJoinRoom();
        }

        roomParticipants[agentID][roomId] = msg.sender;

        agentNFT.safeTransferFrom(msg.sender, address(this), agentID);

        uint256[] memory agentIDs = roomAgents[roomId];
        if (agentIDs.length > MAX_AGENTS) revert AgentRoom__MaxAgentsExceeded();
        roomAgents[roomId].push(agentID);
        // uint256 agentRoomPosition = roomAgents2[roomId].length();
        // roomAgents2[roomId].set(agentRoomPosition, agentID);

        emit RoomJoined(roomId, agentID);
    }

    function leaveRoom(uint256 roomId, uint256 agentID) public {
        if (roomParticipants[agentID][roomId] != msg.sender) revert AgentRoom__OnlyOwnerCanLeaveRoom();
        roomParticipants[agentID][roomId] = address(0);

        AGENTNFT.safeTransferFrom(address(this), msg.sender, agentID);
        emit RoomLeft(roomId, agentID);
    }

    function getRoomParticipant(uint256 roomId) public view returns (uint256) {
        return roomAgents2[roomId].get(roomId);
    }

    function getRoomParticipants(uint256 roomId) public view returns (uint256[] memory) {
        return roomAgents[roomId];
    }

    function getAllRoomParticipants(uint256 roomId) public view returns (uint256[] memory agentIDs) {
        uint256 agentRoomLength = roomAgents2[roomId].length();
        for (uint256 i; i < agentRoomLength;) {
            agentIDs[i] = roomAgents2[roomId].get(i);
            unchecked {
                ++i;
            }
        }
    }

    function viewAgentRoomStatus(uint256 roomId) public view returns (string memory) {
        uint256 agentRoomLength = roomAgents2[roomId].length();
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
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
