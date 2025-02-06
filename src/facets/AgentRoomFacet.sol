// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {LibERC721} from "src/libraries/LibERC721.sol";
import {LibAgentRoom} from "src/libraries/LibAgentRoom.sol";
import {LibAgentNFT} from "src/libraries/LibAgentNFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "src/libraries/constants/Events.sol";
import "src/libraries/constants/Errors.sol";
import "src/libraries/constants/Types.sol";

contract AgentRoomFacet is IERC721Receiver {
    function createRoom(
        uint8 roomType,
        uint256 agentID
    ) external returns (uint256 roomId) {
        return LibAgentRoom.createRoom(roomType, agentID);
    }

    function joinRoom(uint256 roomId, uint8 roomType, uint256 agentID) public {
        LibAgentRoom.joinRoom(roomId, roomType, agentID);
    }

    function leaveRoom(
        uint256 roomId,
        uint8 roomType,
        uint256 agentID
    ) public {
        LibAgentRoom.leaveRoom(roomId, roomType, agentID);
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
