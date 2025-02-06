// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

// AgentRoom
event RoomCreated(uint256 roomId, uint8 roomType, uint256 agentID);
event RoomFull(uint256 roomId, uint8 roomType, uint256[] agentIDs);