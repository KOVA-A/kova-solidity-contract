// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {AgentNFT} from "src/agentNFT/AgentNFT.sol";
import {AgentRoom} from "src/agentRoom/AgentRoom.sol";

contract Deploy is Script {
    AgentNFT agentNFT;
    AgentRoom agentRoom;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function run() public broadcast {
        agentNFT = new AgentNFT(msg.sender);
        agentRoom = new AgentRoom(msg.sender);

        agentNFT.setAgentRoom(address(agentRoom));
        agentRoom.setAgentNFT(address(agentNFT));

        console.log("AgentNFT deployed at: ", address(agentNFT));
        console.log("AgentRoom deployed at: ", address(agentRoom));
    }
}
