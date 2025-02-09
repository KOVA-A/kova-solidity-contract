// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {IERC6551Registry} from "erc6551-reference/interfaces/IERC6551Registry.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC7662} from "src/interfaces/IERC7662.sol";
import "src/libraries/constants/Types.sol";

/**
 * @title AgentNFT
 * @dev ERC721 token representing AI agents with extended functionality including:
 * - ERC721Enumerable for enumeration
 * - ERC721URIStorage for token metadata
 * - IERC7662 compliance for standardized agent data access
 * - ERC6551 token-bound accounts (TBA) integration
 * - Ownable access control
 * Each token represents an AI agent with associated metadata and a dedicated TBA
 */
contract AgentNFT is Ownable, ERC721, ERC721Enumerable, ERC721URIStorage, IERC7662 {
    /// @notice Address of the AgentRoom contract allowed to manage tokens
    address private agentRoom;

    /// @notice ERC6551 registry address for creating token-bound accounts
    address private constant ERC6551RegistryAddress = 0x000000006551c19487814612e58FE06813775758;

    /// @notice ERC6551 account proxy implementation address
    address private constant ERC6551AccountProxyAddress = 0x55266d75D1a14E4572138116aF39863Ed6596E7F;

    /// @notice Mapping of token ID to agent metadata
    mapping(uint256 => AgentData) public agentData;

    /**
     * @dev Initializes the contract
     * @param initialOwner Address of the initial contract owner
     */
    constructor(address initialOwner) ERC721("AgentNFT", "KOVA") Ownable(initialOwner) {}

    /**
     * @notice Sets the AgentRoom contract address
     * @dev Only callable by contract owner
     * @param _agentRoom Address of the AgentRoom contract
     */
    function setAgentRoom(address _agentRoom) external onlyOwner {
        agentRoom = _agentRoom;
    }

    /**
     * @notice Mints a new AgentNFT and creates associated token-bound account
     * @dev Stores agent metadata, sets token URI, approves AgentRoom, and creates TBA
     * @param _agentData Agent metadata structure containing configuration details
     * @return tbaAddress Address of the created token-bound account (TBA)
     */
    function mint(AgentData memory _agentData) external returns (address tbaAddress) {
        uint256 currentTokenId = totalSupply() + 1;
        _mint(msg.sender, currentTokenId);
        agentData[currentTokenId] = _agentData;
        _setTokenURI(currentTokenId, _agentData.systemPromptURI);
        approve(agentRoom, currentTokenId);
        tbaAddress = IERC6551Registry(ERC6551RegistryAddress).createAccount(
            ERC6551AccountProxyAddress, bytes32(currentTokenId), block.chainid, address(this), currentTokenId
        );
    }

    /**
     * @dev Internal function to update token ownership
     * @inheritdoc ERC721Enumerable
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        address previousOwner = ERC721Enumerable._update(to, tokenId, auth);
        return previousOwner;
    }

    /**
     * @dev Internal function to handle balance updates
     * @inheritdoc ERC721Enumerable
     */
    function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._increaseBalance(account, amount);
    }

    /**
     * @notice Checks interface support
     * @dev Combines support for ERC721, ERC721Enumerable, ERC721URIStorage, IERC7662 and IERC165
     * @inheritdoc ERC721URIStorage
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable, ERC721URIStorage, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC7662).interfaceId || interfaceId == type(IERC165).interfaceId
            || ERC721.supportsInterface(interfaceId) || ERC721Enumerable.supportsInterface(interfaceId)
            || ERC721URIStorage.supportsInterface(interfaceId) || super.supportsInterface(interfaceId);
    }

    /**
     * @notice Gets the token URI containing agent configuration
     * @dev Returns the systemPromptURI stored in agent data
     * @inheritdoc ERC721URIStorage
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    /**
     * @notice Returns core agent metadata
     * @dev Implements IERC7662 interface requirements
     * @inheritdoc IERC7662
     */
    function getAgentData(uint256 tokenId)
        external
        view
        override
        returns (
            string memory name,
            string memory description,
            string memory model,
            string memory userPromptURI,
            string memory systemPromptURI,
            bool promptsEncrypted
        )
    {
        AgentData memory agentData_ = agentData[tokenId];
        return (
            agentData_.name,
            agentData_.description,
            agentData_.model,
            agentData_.userPromptURI,
            agentData_.systemPromptURI,
            agentData_.promptsEncrypted
        );
    }

    /**
     * @notice Returns additional agent configuration details
     * @dev Provides supplementary agent data not covered by IERC7662 standard
     * @param agentId Token ID of the agent
     * @return agentType Classification type of the agent
     * @return riskLevel Risk profile of the agent
     * @return investmentAmount Capital allocation for the agent
     * @return preferredAssets Array of preferred asset addresses
     */
    function getAgentExtraData(uint256 agentId)
        external
        view
        returns (AgentType agentType, RiskLevel riskLevel, uint256 investmentAmount, address[] memory preferredAssets)
    {
        agentType = agentData[agentId].agentType;
        riskLevel = agentData[agentId].riskLevel;
        investmentAmount = agentData[agentId].investmentAmount;
        preferredAssets = agentData[agentId].preferredAssets;
    }
}
