// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {AgentNFT} from "src/agentNFT/AgentNFT.sol";
import {ERC6551Registry} from "erc6551-reference/ERC6551Registry.sol";
import {IERC6551Registry} from "erc6551-reference/interfaces/IERC6551Registry.sol";
import {ERC6551Account} from "erc6551-reference/examples/simple/ERC6551Account.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IERC7662} from "src/interfaces/IERC7662.sol";
import "src/libraries/constants/Types.sol";

contract AgentNFTTest is Test {
    AgentNFT public agentNFT;
    address public owner = address(1);
    address public agentRoom = address(2);
    address public user = address(3);

    // ERC6551 constants
    address constant ERC6551_REGISTRY_ADDRESS = 0x000000006551c19487814612e58FE06813775758;
    address constant ERC6551_ACCOUNT_PROXY_ADDRESS = 0x55266d75D1a14E4572138116aF39863Ed6596E7F;

    function setUp() public {
        // Setup ERC6551 Registry
        ERC6551Registry tempRegistry = new ERC6551Registry();
        bytes memory registryCode = address(tempRegistry).code;
        vm.etch(ERC6551_REGISTRY_ADDRESS, registryCode);

        // Setup ERC6551 Account implementation and proxy
        ERC6551Account implementation = new ERC6551Account();
        bytes memory proxyCode = abi.encodePacked(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73", implementation, hex"5af43d82803e903d91602b57fd5bf3"
        );
        vm.etch(ERC6551_ACCOUNT_PROXY_ADDRESS, proxyCode);

        // Deploy AgentNFT
        vm.prank(owner);
        agentNFT = new AgentNFT(owner);

        // Set AgentRoom
        vm.prank(owner);
        agentNFT.setAgentRoom(agentRoom);
    }

    function test_Deployment() public {
        assertEq(agentNFT.owner(), owner, "Owner should be set correctly");
        assertEq(agentNFT.name(), "AgentNFT", "Token name should be AgentNFT");
        assertEq(agentNFT.symbol(), "KOVA", "Token symbol should be KOVA");
    }

    function test_Mint() public {
        AgentData memory data = AgentData({
            name: "TestAgent",
            description: "A test agent",
            model: "GPT-4",
            userPromptURI: "ipfs://user",
            systemPromptURI: "ipfs://system",
            promptsEncrypted: false,
            agentType: AgentType.Trader,
            riskLevel: RiskLevel.MEDIUM,
            investmentAmount: 1 ether,
            preferredAssets: new address[](0)
        });

        vm.prank(user);
        address tbaAddress = agentNFT.mint(data);

        // Check token ownership and supply
        assertEq(agentNFT.ownerOf(1), user, "Token owner should be user");
        assertEq(agentNFT.totalSupply(), 1, "Total supply should be 1");

        // Check stored agent data
        (
            string memory name,
            string memory description,
            string memory model,
            string memory userPromptURI,
            string memory systemPromptURI,
            bool promptsEncrypted
        ) = agentNFT.getAgentData(1);
        assertEq(name, data.name, "Name mismatch");
        assertEq(description, data.description, "Description mismatch");
        assertEq(model, data.model, "Model mismatch");
        assertEq(userPromptURI, data.userPromptURI, "UserPromptURI mismatch");
        assertEq(systemPromptURI, data.systemPromptURI, "SystemPromptURI mismatch");
        assertEq(promptsEncrypted, data.promptsEncrypted, "PromptsEncrypted mismatch");

        // Check token URI and approval
        assertEq(agentNFT.tokenURI(1), data.systemPromptURI, "Token URI mismatch");
        assertEq(agentNFT.getApproved(1), agentRoom, "AgentRoom should be approved");

        // Verify TBA address
        assertTrue(tbaAddress != address(0), "TBA address should not be zero");
        bytes32 salt = bytes32(uint256(1));
        // bytes32 _salt = keccak256(abi.encode(salt, block.chainid, address(agentNFT), 1));
        address expectedTBA = IERC6551Registry(ERC6551_REGISTRY_ADDRESS).account(
            ERC6551_ACCOUNT_PROXY_ADDRESS, salt, block.chainid, address(agentNFT), 1
        );
        assertEq(tbaAddress, expectedTBA, "TBA address mismatch");
    }

    function test_SetAgentRoom_OnlyOwner() public {
        address newAgentRoom = address(4);

        // Non-owner cannot set
        vm.prank(user);
        vm.expectRevert();
        agentNFT.setAgentRoom(newAgentRoom);

        // Owner can set
        vm.prank(owner);
        agentNFT.setAgentRoom(newAgentRoom);

        // Verify by minting and checking approval
        AgentData memory data = AgentData({
            name: "TestAgent",
            description: "Test",
            model: "Model",
            userPromptURI: "ipfs://...",
            systemPromptURI: "ipfs://...",
            promptsEncrypted: false,
            agentType: AgentType.Trader,
            riskLevel: RiskLevel.MEDIUM,
            investmentAmount: 0,
            preferredAssets: new address[](0)
        });

        vm.prank(user);
        agentNFT.mint(data);
    }

    function test_GetAgentExtraData() public {
        address[] memory preferredAssets = new address[](2);
        preferredAssets[0] = address(0x123);
        preferredAssets[1] = address(0x456);

        AgentData memory data = AgentData({
            name: "Test",
            description: "Test",
            model: "Test",
            userPromptURI: "ipfs://...",
            systemPromptURI: "ipfs://...",
            promptsEncrypted: false,
            agentType: AgentType.Trader,
            riskLevel: RiskLevel.HIGH,
            investmentAmount: 5 ether,
            preferredAssets: preferredAssets
        });

        vm.prank(user);
        agentNFT.mint(data);

        (AgentType agentType, RiskLevel riskLevel, uint256 investmentAmount, address[] memory assets) =
            agentNFT.getAgentExtraData(1);

        assertEq(uint8(agentType), uint8(data.agentType), "AgentType mismatch");
        assertEq(uint8(riskLevel), uint8(data.riskLevel), "RiskLevel mismatch");
        assertEq(investmentAmount, data.investmentAmount, "InvestmentAmount mismatch");
        assertEq(assets.length, data.preferredAssets.length, "PreferredAssets length mismatch");
        assertEq(assets[0], data.preferredAssets[0], "PreferredAssets[0] mismatch");
        assertEq(assets[1], data.preferredAssets[1], "PreferredAssets[1] mismatch");
    }

    function test_SupportsInterface() public {
        // ERC721
        assertTrue(agentNFT.supportsInterface(0x80ac58cd), "ERC721 not supported");
        // ERC721Enumerable
        assertTrue(agentNFT.supportsInterface(0x780e9d63), "ERC721Enumerable not supported");
        // ERC721URIStorage (IERC721Metadata)
        assertTrue(agentNFT.supportsInterface(0x5b5e139f), "ERC721URIStorage not supported");
        // IERC7662
        assertTrue(agentNFT.supportsInterface(type(IERC7662).interfaceId), "IERC7662 not supported");
        // IERC165
        assertTrue(agentNFT.supportsInterface(0x01ffc9a7), "IERC165 not supported");
    }

    function test_MintMultipleTokens() public {
        AgentData memory data1 = AgentData({
            name: "First",
            description: "First",
            model: "Model",
            userPromptURI: "ipfs://...",
            systemPromptURI: "ipfs://...",
            promptsEncrypted: false,
            agentType: AgentType.Trader,
            riskLevel: RiskLevel.LOW,
            investmentAmount: 1 ether,
            preferredAssets: new address[](0)
        });

        AgentData memory data2 = AgentData({
            name: "Second",
            description: "Second",
            model: "Model",
            userPromptURI: "ipfs://...",
            systemPromptURI: "ipfs://...",
            promptsEncrypted: false,
            agentType: AgentType.Investor,
            riskLevel: RiskLevel.HIGH,
            investmentAmount: 2 ether,
            preferredAssets: new address[](0)
        });

        vm.prank(user);
        address tba1 = agentNFT.mint(data1);

        vm.prank(user);
        address tba2 = agentNFT.mint(data2);

        assertEq(agentNFT.totalSupply(), 2, "Total supply should be 2");
        assertTrue(tba1 != tba2, "TBA addresses should be different");
    }
}
