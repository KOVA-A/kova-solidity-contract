// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "src/libraries/LibDiamond.sol";
import {IDiamondLoupe} from "src/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "src/interfaces/IDiamondCut.sol";
import {IERC7662} from "src/interfaces/IERC7662.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/// @notice Initialize.
/// @author KOVA (https://github.com/KOVA-A/solidity-contract)
/// @author Modified from Nick Mudge (https://github.com/mudgen/diamond-3)
contract ERC165Init {
    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IAccessControl).interfaceId] = true;
        ds.supportedInterfaces[type(IERC7662).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721Enumerable).interfaceId] = true;

        // EIP-2535 specifies that the `diamondCut` function takes two optional
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface
    }
}
