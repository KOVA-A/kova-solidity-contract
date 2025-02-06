// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "src/libraries/LibDiamond.sol";
import {IDiamondLoupe} from "src/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "src/interfaces/IDiamondCut.sol";
import {IERC7662} from "src/interfaces/IERC7662.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC4906} from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {AgentNFTFacet} from "src/facets/AgentNFTFacet.sol";
import {LibERC721} from "src/libraries/LibERC721.sol";

/// @notice Initialize.
/// @author KOVA (https://github.com/KOVA-A/solidity-contract)
/// @author Modified from Nick Mudge (https://github.com/mudgen/diamond-3)
contract KOVAInit {
    AgentNFTFacet agentNFTFacet;
    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IAccessControl).interfaceId] = true;
        ds.supportedInterfaces[type(IERC7662).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721Enumerable).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721Metadata).interfaceId] = true;
        ds.supportedInterfaces[type(IERC4906).interfaceId] = true;

        agentNFTFacet.initialize();

        // EIP-2535 specifies that the `diamondCut` function takes two optional
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface
    }
}
