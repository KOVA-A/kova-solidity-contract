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

/**
 * @title AgentRoom
 * @dev A contract that allows AI agents (represented as AgentNFTs) to interact in secure rooms.
 * Users can create rooms, join rooms, and leave rooms. Each room can hold a maximum of two agents.
 */
contract AgentRoom is Ownable, IERC721Receiver {
    using EnumerableMap for EnumerableMap.UintToUintMap;

    uint256 private constant MAX_AGENTS = 2; // Maximum number of agents allowed in a room
    AgentNFT private agentNFT; // Reference to the AgentNFT contract

    // Storage
    EnumerableMap.UintToUintMap agentRooms;
    mapping(uint256 => EnumerableMap.UintToUintMap) roomAgents2;
    // roomId => agentIDs
    mapping(uint256 => uint256[]) roomAgents;
    // agentID => roomIdPosition
    mapping(uint256 => uint256) agentRoomPosition;
    mapping(uint256 => mapping(uint256 => address)) roomParticipants;
    uint256 roomIdCount;

    /**
     * @dev Constructor to initialize the contract with an initial owner.
     * @param initialOwner The address of the initial owner of the contract.
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Sets the address of the AgentNFT contract.
     * @param _agentNFT The address of the AgentNFT contract.
     */
    function setAgentNFT(address _agentNFT) external onlyOwner {
        agentNFT = AgentNFT(_agentNFT);
    }

    /**
     * @dev Creates a new room with the sender's AgentNFT.
     * @param agentID The ID of the AgentNFT to be used to create the room.
     * @return roomId_ The ID of the newly created room.
     */
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

    /**
     * @dev Allows another user to join a room with their AgentNFT.
     * @param roomId The ID of the room to join.
     * @param agentID The ID of the AgentNFT to join the room.
     */
    function joinRoom(uint256 roomId, uint256 agentID) public {
        if (agentNFT.ownerOf(agentID) != msg.sender) {
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

    /**
     * @dev Allows a user to leave a room and retrieve their AgentNFT.
     * @param roomId The ID of the room to leave.
     * @param agentID The ID of the AgentNFT to leave the room.
     */
    function leaveRoom(uint256 roomId, uint256 agentID) public {
        if (roomParticipants[agentID][roomId] != msg.sender) {
            revert AgentRoom__OnlyOwnerCanLeaveRoom();
        }
        roomParticipants[agentID][roomId] = address(0);

        agentNFT.safeTransferFrom(address(this), msg.sender, agentID);
        emit RoomLeft(roomId, agentID);
    }

    /**
     * @dev Retrieves the participant of a room at a specific position.
     * @param roomId The ID of the room.
     * @return The agent ID of the participant.
     */
    function getRoomParticipant(uint256 roomId) public view returns (uint256) {
        return roomAgents2[roomId].get(roomId);
    }

    /**
     * @dev Retrieves all participants in a room.
     * @param roomId The ID of the room.
     * @return An array of agent IDs in the room.
     */
    function getRoomParticipants(uint256 roomId) public view returns (uint256[] memory) {
        return roomAgents[roomId];
    }

    /**
     * @dev Retrieves all participants in a room using an alternative storage structure.
     * @param roomId The ID of the room.
     * @return agentIDs An array of agent IDs in the room.
     */
    function getAllRoomParticipants(uint256 roomId) public view returns (uint256[] memory agentIDs) {
        uint256 agentRoomLength = roomAgents2[roomId].length();
        for (uint256 i; i < agentRoomLength;) {
            agentIDs[i] = roomAgents2[roomId].get(i);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Retrieves the current status of an agent room based on its occupancy
     * @dev Determines room status by checking the number of agents currently in the room:
     *      - Open: When only 1 agent is present (waiting for other agents to join)
     *      - InProgress: When room reaches maximum capacity (MAX_AGENTS)
     *      - Closed: When room has more than 1 agent but hasn't reached maximum capacity
     * @param roomId The unique identifier of the room to check
     * @return RoomStatus Enum value representing the current room status:
     *         - RoomStatus.Open
     *         - RoomStatus.InProgress
     *         - RoomStatus.Closed
     */
    function viewAgentRoomStatus(uint256 roomId) public view returns (RoomStatus) {
        uint256 agentRoomLength = roomAgents2[roomId].length();
        if (agentRoomLength == MAX_AGENTS) {
            return RoomStatus.InProgress;
        } else if (agentRoomLength == 1) {
            return RoomStatus.Open;
        } else {
            return RoomStatus.Closed;
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
