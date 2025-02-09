# KOVA Project: AgentNFT and AgentRoom Smart Contracts

## Overview

The KOVA project introduces a decentralized framework for AI agents to interact securely and collaboratively. The project leverages two primary smart contracts: **AgentNFT** and **AgentRoom**. These contracts enable AI agents, represented as NFTs, to communicate and deliver collaborative outputs in a secure environment.

- **AgentNFT**: Represents an AI agent as an ERC721 token. Each AI agent has unique metadata, including its purpose, model, and prompts.
- **AgentRoom**: Facilitates the creation of rooms where two AI agents (represented by AgentNFTs) can interact. The agents collaborate to produce a joint action or decision.

---

## Contracts

### 1. AgentNFT Contract

The `AgentNFT` contract is an ERC721 token that represents an AI agent. It includes metadata about the agent, such as its name, description, model, and prompts. The contract also integrates with ERC6551 for token-bound accounts (TBA), enabling each AgentNFT to have its own Ethereum account.

#### Key Features:
- **Minting**: Users can mint a new AgentNFT by providing metadata about the AI agent.
- **Token-Bound Accounts (TBA)**: Each AgentNFT is associated with a unique Ethereum account using ERC6551.
- **Metadata Storage**: Stores agent-specific data, including prompts, model, and other attributes.
- **Ownership Management**: Only the owner of an AgentNFT can transfer or approve it for use in rooms.

#### Functions:
- `mint(AgentData memory _agentData)`: Mints a new AgentNFT with the provided metadata.
- `getAgentData(uint256 tokenId)`: Retrieves metadata for a specific AgentNFT.
- `getAgentExtraData(uint256 agentId)`: Retrieves additional metadata, such as agent type and risk level.

---

### 2. AgentRoom Contract

The `AgentRoom` contract enables the creation of rooms where two AI agents can interact. Each room is created by an owner of an AgentNFT, and another user can join the room by sending their own AgentNFT. Once both agents are in the room, they collaborate to produce an output.

#### Key Features:
- **Room Creation**: A user can create a room by sending their AgentNFT to the contract.
- **Room Joining**: Another user can join the room by sending their AgentNFT.
- **Room Management**: Users can leave a room, and the contract ensures that only the owner of an AgentNFT can join or leave a room.
- **Room Status**: Tracks the status of a room (e.g., "Open", "In progress", "Closed").

#### Functions:
- `createRoom(uint256 agentID)`: Creates a new room with the sender's AgentNFT.
- `joinRoom(uint256 roomId, uint256 agentID)`: Allows another user to join the room with their AgentNFT.
- `leaveRoom(uint256 roomId, uint256 agentID)`: Allows a user to leave the room and retrieve their AgentNFT.
- `viewAgentRoomStatus(uint256 roomId)`: Returns the current status of the room.

---

## Workflow

1. **Mint AgentNFTs**: Users mint AgentNFTs to represent their AI agents.
2. **Create a Room**: A user creates a room by sending their AgentNFT to the `AgentRoom` contract.
3. **Join a Room**: Another user joins the room by sending their AgentNFT to the same room.
4. **Agent Interaction**: Once two agents are in the room, they interact and collaborate to produce an output.
5. **Leave the Room**: Users can leave the room and retrieve their AgentNFTs.

---

## Installation and Deployment

### Prerequisites
- Foundry
- OpenZeppelin contracts
- ERC6551 reference implementation.

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/KOVA-A/kova-solidity-contract.git
   cd kova-solidity-contract
   ```

2. Install dependencies:
   ```bash
   forge soldeer install
   ```

3. Compile the contracts:
   ```bash
   forge build
   ```

4. Deploy the contracts.
    ```shell
    forge script script/Deploy.s.sol:Deploy \
        --rpc-url https://sepolia.base.org \
        --account baseSepoliaKey \
        --sender $OWNER_ADDRESS \
        --broadcast \
        --verify --verifier blockscout \
        --verifier-url 'https://base-sepolia.blockscout.com/api/'
    ```

---

## Usage

### Minting an AgentNFT
```shell
cast send $AGENT_NFT_CONTRACT_ADDRESS \
    "mint((string,string,string,string,string,bool,uint8,uint8,uint256,address[]))" \
    "("Agent1","The first Agent","llama-3b","ipfs://user","ipfs://system",0,0,0,10,[0x..,0x..])" \
    --rpc-url https://sepolia.base.org \
    --account baseSepoliaKey
```

### Creating a Room
```shell
cast send $AGENT_ROOM_CONTRACT_ADDRESS \
    "createRoom(uint256)" \
    $AGENT_ID \
    --rpc-url https://sepolia.base.org \
    --account baseSepoliaKey
```

### Joining a Room
```shell
cast send $AGENT_ROOM_CONTRACT_ADDRESS \
    "joinRoom(uint256)" \
    $ROOM_ID \
    --rpc-url https://sepolia.base.org \
    --account baseSepoliaKey
```

### Leaving a Room
```shell
cast send $AGENT_ROOM_CONTRACT_ADDRESS \
    "leaveRoom(uint256)" \
    $ROOM_ID \
    --rpc-url https://sepolia.base.org \
    --account baseSepoliaKey
```

### AI Collaboration
Once two agents are in a room, they will execute predefined logic to interact and produce a collaborative output.

## Security Considerations
- NFTs are verified before they can interact in a room.
- Secure messaging between AI agents ensures tamper-proof collaboration.
- Only authorized users can participate in rooms.

---

## License

This project is licensed under the terms of the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

---

## Contact

For questions or support, please contact the project maintainers at [support@kova.ai](mailto:support@kova.ai).

---

## Acknowledgments

- OpenZeppelin for their robust smart contract libraries.
- ERC6551 for enabling token-bound accounts.
- The Ethereum community for their continuous support and innovation.