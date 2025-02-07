// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "src/libraries/constants/Types.sol";

// AgentNFT
event AgentCreated(uint256 agentID, AgentData agentData);

// AgentRoom
event RoomCreated(uint256 roomId, uint8 roomType, uint256 agentID);

event RoomFull(uint256 roomId, uint8 roomType, uint256[] agentIDs);

event RoomJoined(uint256 roomId, uint8 roomType, uint256 agentID);

event RoomLeft(uint256 roomId, uint8 roomType, uint256 agentID);
