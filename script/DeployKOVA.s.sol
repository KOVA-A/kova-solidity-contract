// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

import {DiamondCutFacet} from "src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "src/facets/DiamondLoupeFacet.sol";
import {AgentRoomFacet} from "src/facets/AgentRoomFacet.sol";
import {AgentNFTFacet} from "src/facets/AgentNFTFacet.sol";

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
    AgentNFTFacet agentNFTFacet;
    KOVAInit kovaInit;
    KOVA kova;

    modifier broadcast {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function run() public broadcast {
        diamondCutFacet = new DiamondCutFacet();
        console.log("DiamondCutFacet deployed at: ", address(diamondCutFacet));
        diamondLoupeFacet = new DiamondLoupeFacet();
        console.log("DiamondLoupeFacet deployed at: ", address(diamondLoupeFacet));
        agentRoomFacet = new AgentRoomFacet();
        console.log("AgentRoomFacet deployed at: ", address(agentRoomFacet));
        agentNFTFacet = new AgentNFTFacet();
        console.log("AgentNFTFacet deployed at: ", address(agentNFTFacet));
        kovaInit = new KOVAInit();
        console.log("KOVAInit deployed at: ", address(kovaInit));

        FacetCut[] memory cut = new FacetCut[](4);

        bytes4[] memory diamondCutSelectors = new bytes4[](1);
        diamondCutSelectors[0] = DiamondCutFacet.diamondCut.selector;

        bytes4[] memory loupeSelectors = new bytes4[](5);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;
        loupeSelectors[4] = IERC165.supportsInterface.selector;

        bytes4[] memory agentRoomSelectors = new bytes4[](4);
        agentRoomSelectors[0] = AgentRoomFacet.createRoom.selector;
        agentRoomSelectors[1] = AgentRoomFacet.joinRoom.selector;
        agentRoomSelectors[2] = AgentRoomFacet.leaveRoom.selector;
        agentRoomSelectors[3] = IERC721Receiver.onERC721Received.selector;

        bytes4[] memory agentNFTSelectors = new bytes4[](14);
        agentNFTSelectors[0] = AgentNFTFacet.name.selector;
        agentNFTSelectors[1] = AgentNFTFacet.symbol.selector;
        agentNFTSelectors[2] = AgentNFTFacet.tokenURI.selector;
        agentNFTSelectors[3] = AgentNFTFacet.createAgent.selector;
        agentNFTSelectors[4] = AgentNFTFacet.getAgentType.selector;
        agentNFTSelectors[5] = AgentNFTFacet.getAgentData.selector;
        agentNFTSelectors[6] = AgentNFTFacet.balanceOf.selector;
        agentNFTSelectors[7] = AgentNFTFacet.ownerOf.selector;
        agentNFTSelectors[8] = AgentNFTFacet.safeTransferFrom.selector;
        agentNFTSelectors[9] = AgentNFTFacet.transferFrom.selector;
        agentNFTSelectors[10] = AgentNFTFacet.approve.selector;
        agentNFTSelectors[11] = AgentNFTFacet.setApprovalForAll.selector;
        agentNFTSelectors[12] = AgentNFTFacet.getApproved.selector;
        agentNFTSelectors[13] = AgentNFTFacet.isApprovedForAll.selector;

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

        cut[3] = FacetCut({
            facetAddress: address(agentNFTFacet),
            action: FacetCutAction.Add,
            functionSelectors: agentNFTSelectors
        });

        DiamondInitArgs memory args =
            DiamondInitArgs({init: address(kovaInit), initCalldata: abi.encode(keccak256("init()"))});

        kova = new KOVA(msg.sender, cut, args);
        console.log("KOVA deployed at: ", address(kova));
    }

}
