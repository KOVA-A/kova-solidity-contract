// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

enum FacetCutAction {
    Add,
    Replace,
    Remove
}
// Add=0, Replace=1, Remove=2

struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
}

struct FacetAddressAndPosition {
    address facetAddress;
    uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
}

struct FacetFunctionSelectors {
    bytes4[] functionSelectors;
    uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
}

// This is used in diamond constructor
// more arguments are added to this struct
// this avoids stack too deep errors
struct DiamondInitArgs {
    address init;
    bytes initCalldata;
}

struct AgentData {
    string name;
    string description;
    string model;
    string userPromptURI;
    string systemPromptURI;
    bool promptsEncrypted;
}
