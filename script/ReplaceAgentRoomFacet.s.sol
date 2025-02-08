// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

import {DiamondCutFacet} from "src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "src/facets/DiamondLoupeFacet.sol";
import {AgentRoomFacet} from "src/facets/AgentRoomFacet.sol";

import {IDiamondCut, FacetCut, FacetCutAction} from "src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "src/interfaces/IDiamondLoupe.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {LibDiamond, DiamondInitArgs} from "src/libraries/LibDiamond.sol";
import {KOVAInit} from "src/initializers/KOVAInit.sol";

import {KOVA} from "src/KOVA.sol";

contract ReplaceAgentRoomFacet is Script {
    AgentRoomFacet agentRoomFacet;
    KOVA kova = KOVA(payable(address(0xF70Dc4d3D1c808d99af3eaca707db15A45E5D629)));

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function run() public broadcast {
        agentRoomFacet = new AgentRoomFacet();

        console.log("AgentRoomFacet deployed at: ", address(agentRoomFacet));

        FacetCut[] memory cut = new FacetCut[](2);

        bytes4[] memory agentRoomSelectorsOld = new bytes4[](8);
        agentRoomSelectorsOld[0] = AgentRoomFacet.createRoom.selector;
        agentRoomSelectorsOld[1] = AgentRoomFacet.joinRoom.selector;
        agentRoomSelectorsOld[2] = AgentRoomFacet.leaveRoom.selector;
        agentRoomSelectorsOld[3] = AgentRoomFacet.getRoomParticipant.selector;
        agentRoomSelectorsOld[4] = AgentRoomFacet.getRoomParticipants.selector;
        agentRoomSelectorsOld[5] = AgentRoomFacet.getAllRoomParticipants.selector;
        agentRoomSelectorsOld[6] = AgentRoomFacet.viewAgentRoomStatus.selector;
        agentRoomSelectorsOld[7] = IERC721Receiver.onERC721Received.selector;

        bytes4[] memory agentRoomSelectorsNew = new bytes4[](8);
        agentRoomSelectorsNew[0] = AgentRoomFacet.createRoom.selector;
        agentRoomSelectorsNew[1] = AgentRoomFacet.joinRoom.selector;
        agentRoomSelectorsNew[2] = AgentRoomFacet.leaveRoom.selector;
        agentRoomSelectorsNew[3] = AgentRoomFacet.getRoomParticipant.selector;
        agentRoomSelectorsNew[4] = AgentRoomFacet.getRoomParticipants.selector;
        agentRoomSelectorsNew[5] = AgentRoomFacet.getAllRoomParticipants.selector;
        agentRoomSelectorsNew[6] = AgentRoomFacet.viewAgentRoomStatus.selector;
        agentRoomSelectorsNew[7] = IERC721Receiver.onERC721Received.selector;

        cut[0] = FacetCut({
            facetAddress: address(0),
            action: FacetCutAction.Remove,
            functionSelectors: agentRoomSelectorsOld
        });

        cut[1] = FacetCut({
            facetAddress: address(agentRoomFacet),
            action: FacetCutAction.Add,
            functionSelectors: agentRoomSelectorsOld
        });

        DiamondInitArgs memory args = DiamondInitArgs({init: address(0), initCalldata: ""});

        kova = new KOVA(msg.sender, cut, args);

        IDiamondCut(address(kova)).diamondCut(cut, address(0), "");

        console.log("KOVA deployed at: ", address(kova));
    }
}
