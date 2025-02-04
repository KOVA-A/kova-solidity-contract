// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDiamondCut, FacetCut} from "src/interfaces/IDiamondCut.sol";
import {LibDiamond} from "src/libraries/LibDiamond.sol";
import {LibAccessControl, DEFAULT_ADMIN_ROLE} from "src/libraries/LibAccessControl.sol";

/// @notice Add/replace/remove any number of functions and optionally execute
/// @author KOVA (https://github.com/KOVA-A/solidity-contract)
/// @author Modified from Nick Mudge (https://github.com/mudgen/diamond-3)
contract DiamondCutFacet {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external {
        LibAccessControl._checkRole(DEFAULT_ADMIN_ROLE);
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
