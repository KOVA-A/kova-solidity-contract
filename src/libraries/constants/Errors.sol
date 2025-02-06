// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

error Diamond__FunctionNotFound(bytes4 _functionSelector);
error Diamond__InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);

error LibDiamondCut__IncorrectFacetCutAction();
error LibDiamondCut__NoSelectorsInFacetToCut();
error LibDiamondCut__AddFacetCannotBeAddressZero();
error LibDiamondCut__CannotAddFunctionThatAlreadyExists();
error LibDiamondCut__ReplaceFacetCannotBeAddressZero();
error LibDiamondCut__CannotReplaceFunctionWithSameFunction();
error LibDiamondCut__RemoveFacetMustBeAddressZero();
error LibDiamondCut__NewFacetHasNoCode();
error LibDiamondCut__CannotRemoveFunctionThatDoesNotExist();
error LibDiamondCut__CannotRemoveImmutableFunction();
error LibDiamondCut__InitAddressHasNoCode();

error AgentRoom__MaxAgentsExceeded();
error AgentRoom__OnlyOwnerCanCreateRoom();
error AgentRoom__OnlyTraderCanCreateRoom();
error AgentRoom__OnlyInvestorsCanJoinRoom();
