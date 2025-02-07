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

contract DeployKOVA is Script {
    DiamondCutFacet diamondCutFacet;
    DiamondLoupeFacet diamondLoupeFacet;
    AgentRoomFacet agentRoomFacet;
    KOVAInit kovaInit;
    KOVA kova;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function run() public broadcast {
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        agentRoomFacet = new AgentRoomFacet();
        kovaInit = new KOVAInit();

        console.log("DiamondCutFacet deployed at: ", address(diamondCutFacet));
        console.log("DiamondLoupeFacet deployed at: ", address(diamondLoupeFacet));
        console.log("AgentRoomFacet deployed at: ", address(agentRoomFacet));
        console.log("KOVAInit deployed at: ", address(kovaInit));

        FacetCut[] memory cut = new FacetCut[](3);

        bytes4[] memory diamondCutSelectors = new bytes4[](1);
        diamondCutSelectors[0] = DiamondCutFacet.diamondCut.selector;

        bytes4[] memory loupeSelectors = new bytes4[](5);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;
        loupeSelectors[4] = IERC165.supportsInterface.selector;

        bytes4[] memory agentRoomSelectors = new bytes4[](8);
        agentRoomSelectors[0] = AgentRoomFacet.createRoom.selector;
        agentRoomSelectors[1] = AgentRoomFacet.joinRoom.selector;
        agentRoomSelectors[2] = AgentRoomFacet.leaveRoom.selector;
        agentRoomSelectors[3] = AgentRoomFacet.getRoomParticipant.selector;
        agentRoomSelectors[4] = AgentRoomFacet.getRoomParticipants.selector;
        agentRoomSelectors[5] = AgentRoomFacet.getAllRoomParticipants.selector;
        agentRoomSelectors[6] = AgentRoomFacet.viewAgentRoomStatus.selector;
        agentRoomSelectors[7] = IERC721Receiver.onERC721Received.selector;

        cut[0] = FacetCut({
            facetAddress: address(diamondCutFacet),
            action: FacetCutAction.Add,
            functionSelectors: diamondCutSelectors
        });

        cut[1] = FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        cut[2] = FacetCut({
            facetAddress: address(agentRoomFacet),
            action: FacetCutAction.Add,
            functionSelectors: agentRoomSelectors
        });

        DiamondInitArgs memory args =
            DiamondInitArgs({init: address(kovaInit), initCalldata: abi.encode(keccak256("init()"))});

        kova = new KOVA(msg.sender, cut, args);
        console.log("KOVA deployed at: ", address(kova));
    }
}
