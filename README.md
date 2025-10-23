# Foundry Workshop - Monad Testnet

Welcome to the Foundry Workshop! This guide will take you from installation to deploying and verifying smart contracts on Monad testnet.

## Table of Contents
- [Installation](#installation)
- [Project Setup](#project-setup)
- [Smart Contract](#smart-contract)
- [Writing Tests](#writing-tests)
- [Deployment Script](#deployment-script)
- [Deploying to Monad Testnet](#deploying-to-monad-testnet)
- [Verifying Contract](#verifying-contract)

---

## Installation

### 1. Install Foundry

First, install `foundryup`, the official Foundry installer:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

After installation, run:

```bash
foundryup
```

This installs `forge`, `cast`, `anvil`, and `chisel`.

### 2. Verify Installation

```bash
forge --version
cast --version
```

---

## Project Setup

### 1. Create a New Foundry Project

Using the Monad template (recommended):

```bash
forge init --template monad-developers/foundry-monad foundry-workshop
cd foundry-workshop
```

Or create a standard project:

```bash
forge init foundry-workshop
cd foundry-workshop
```

### 2. Configure for Monad Testnet

Update `foundry.toml`:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

# Monad Testnet Configuration
eth-rpc-url = "https://testnet-rpc.monad.xyz"
chain_id = 10143
```

---

## Smart Contract

Create a simple message storage contract at `src/MessageBoard.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MessageBoard {
    string public message;
    address public author;
    uint256 public messageCount;
    
    event MessageUpdated(address indexed author, string message, uint256 timestamp);
    
    constructor(string memory _initialMessage) {
        message = _initialMessage;
        author = msg.sender;
        messageCount = 1;
    }
    
    function updateMessage(string memory _newMessage) public {
        require(bytes(_newMessage).length > 0, "Message cannot be empty");
        message = _newMessage;
        author = msg.sender;
        messageCount++;
        
        emit MessageUpdated(msg.sender, _newMessage, block.timestamp);
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    function getAuthor() public view returns (address) {
        return author;
    }
}
```

### Compile the Contract

```bash
forge build
```

---

## Writing Tests

Create a test file at `test/MessageBoard.t.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MessageBoard.sol";

contract MessageBoardTest is Test {
    MessageBoard public messageBoard;
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    
    function setUp() public {
        messageBoard = new MessageBoard("Hello Monad!");
    }
    
    function test_InitialMessage() public view {
        assertEq(messageBoard.message(), "Hello Monad!");
        assertEq(messageBoard.messageCount(), 1);
    }
    
    function test_UpdateMessage() public {
        vm.prank(user1);
        messageBoard.updateMessage("New message from user1");
        
        assertEq(messageBoard.getMessage(), "New message from user1");
        assertEq(messageBoard.getAuthor(), user1);
        assertEq(messageBoard.messageCount(), 2);
    }
    
    function test_MultipleUpdates() public {
        vm.prank(user1);
        messageBoard.updateMessage("First update");
        
        vm.prank(user2);
        messageBoard.updateMessage("Second update");
        
        assertEq(messageBoard.getMessage(), "Second update");
        assertEq(messageBoard.getAuthor(), user2);
        assertEq(messageBoard.messageCount(), 3);
    }
    
    function test_RevertEmptyMessage() public {
        vm.expectRevert("Message cannot be empty");
        messageBoard.updateMessage("");
    }
    
    function test_EmitEvent() public {
        vm.expectEmit(true, false, false, false);
        emit MessageBoard.MessageUpdated(address(this), "Test event", block.timestamp);
        
        messageBoard.updateMessage("Test event");
    }
}
```

### Run Tests

Run all tests:

```bash
forge test
```

Run tests with verbosity:

```bash
forge test -vv
```

Run specific test:

```bash
forge test --match-test test_UpdateMessage -vvv
```

Get gas report:

```bash
forge test --gas-report
```

---

## Deployment Script

Create a deployment script at `script/DeployMessageBoard.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/MessageBoard.sol";

contract DeployMessageBoard is Script {
    function run() external returns (MessageBoard) {
        string memory initialMessage = "Welcome to Monad!";
        
        vm.startBroadcast();
        
        MessageBoard messageBoard = new MessageBoard(initialMessage);
        
        vm.stopBroadcast();
        
        console.log("MessageBoard deployed to:", address(messageBoard));
        console.log("Initial message:", messageBoard.message());
        
        return messageBoard;
    }
}
```

### Test the Deployment Script Locally

```bash
forge script script/DeployMessageBoard.s.sol
```

---

## Deploying to Monad Testnet

### 1. Get Testnet Funds

Get testnet MON tokens from the faucet:
- Visit: https://faucet.monad.xyz/

### 2. Create a Keystore (Recommended)

Create a secure keystore instead of using private keys:

```bash
cast wallet import monad-deployer --interactive
```

Or create with a new wallet:

```bash
cast wallet import monad-deployer --private-key $(cast wallet new | grep 'Private key:' | awk '{print $3}')
```

Get your keystore address:

```bash
cast wallet address --account monad-deployer
```

### 3. Deploy Using Keystore

Deploy using the deployment script:

```bash
forge script script/DeployMessageBoard.s.sol --account monad-deployer --broadcast
```

Or deploy directly:

```bash
forge create src/MessageBoard.sol:MessageBoard --constructor-args "Hello Monad!" --account monad-deployer --broadcast
```

### 4. Alternative: Deploy Using Private Key (Not Recommended)

⚠️ **Not recommended for production!**

```bash
forge create src/MessageBoard.sol:MessageBoard --constructor-args "Hello Monad!" --private-key YOUR_PRIVATE_KEY --broadcast
```

### 5. Save Your Deployment Address

After deployment, save the contract address from the output:

```
Deployed to: 0x1234567890123456789012345678901234567890
```

---

## Verifying Contract

### Option 1: MonadExplorer (Sourcify)

```bash
forge verify-contract \
    YOUR_CONTRACT_ADDRESS \
    MessageBoard \
    --chain 10143 \
    --verifier sourcify \
    --verifier-url https://sourcify-api-monad.blockvision.org
```

### Option 2: Monadscan

```bash
forge verify-contract \
    YOUR_CONTRACT_ADDRESS \
    MessageBoard \
    --chain 10143 \
    --verifier etherscan \
    --etherscan-api-key YourApiKeyToken \
    --watch
```

### Option 3: Socialscan

```bash
forge verify-contract \
    YOUR_CONTRACT_ADDRESS \
    MessageBoard \
    --chain 10143 \
    --watch \
    --etherscan-api-key test \
    --verifier-url https://api.socialscan.io/monad-testnet/v1/explorer/command_api/contract \
    --verifier etherscan
```

### Verify with Constructor Arguments

If your contract has constructor arguments:

```bash
forge verify-contract \
    YOUR_CONTRACT_ADDRESS \
    MessageBoard \
    --constructor-args $(cast abi-encode "constructor(string)" "Hello Monad!") \
    --chain 10143 \
    --verifier sourcify \
    --verifier-url https://sourcify-api-monad.blockvision.org
```

---

## Useful Commands Cheatsheet

### Compilation
```bash
forge build                    # Compile contracts
forge build --force            # Force recompile
forge clean                    # Clean build artifacts
```

### Testing
```bash
forge test                     # Run all tests
forge test -vv                 # Verbose output
forge test -vvvv               # Very verbose (traces)
forge test --match-test NAME   # Run specific test
forge test --gas-report        # Show gas usage
forge coverage                 # Code coverage
```

### Local Development
```bash
anvil                          # Start local testnet
forge script SCRIPT --fork-url URL  # Fork mainnet
```

### Interaction
```bash
cast call ADDRESS "functionName()" --rpc-url https://testnet-rpc.monad.xyz
cast send ADDRESS "functionName()" --account monad-deployer
```

### Wallet Management
```bash
cast wallet list               # List all keystores
cast wallet address --account NAME  # Get address
cast balance ADDRESS --rpc-url https://testnet-rpc.monad.xyz
```

---

## Additional Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Monad Documentation](https://docs.monad.xyz/)
- [Monad Deploy Guide](https://docs.monad.xyz/guides/deploy-smart-contract/foundry)
- [Monad Verify Guide](https://docs.monad.xyz/guides/verify-smart-contract/foundry)
- [Monad Faucet](https://faucet.monad.xyz/)
- [Monad Explorer](https://testnet.monadexplorer.com/)

---

## Troubleshooting

### Common Issues

1. **"insufficient funds"**: Get testnet tokens from the faucet
2. **Compilation errors**: Run `forge clean && forge build`
3. **RPC errors**: Check your internet connection and RPC URL
4. **Keystore password**: Make sure you remember the password you set

### Get Help

- Monad Developer Discord: [Join Here](https://discord.gg/monad)
- Foundry Support: [GitHub Discussions](https://github.com/foundry-rs/foundry/discussions)

---

Happy Building on Monad! 🚀

