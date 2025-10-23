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
- [Interacting with Deployed Contracts](#interacting-with-deployed-contracts)
- [Useful Commands Cheatsheet](#useful-commands-cheatsheet)
- [Additional Resources](#additional-resources)
- [Best Practices & Tips](#best-practices--tips)
- [Troubleshooting](#troubleshooting)
- [Next Steps After the Workshop](#next-steps-after-the-workshop)

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

**📚 Learn More:**
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Foundry Project Structure](https://book.getfoundry.sh/projects/project-layout)

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

### Understanding the Test

**Key Testing Features Used:**
- `vm.prank(address)` - Sets `msg.sender` for the next call
- `assertEq()` - Checks if two values are equal
- `vm.expectRevert()` - Expects the next call to revert
- `vm.expectEmit()` - Expects an event to be emitted

**📚 Learn More:**
- [Foundry Testing Guide](https://book.getfoundry.sh/forge/tests)
- [Forge Standard Library (forge-std)](https://book.getfoundry.sh/reference/forge-std/)
- [Cheatcodes Reference](https://book.getfoundry.sh/cheatcodes/)
- [Assertions Reference](https://book.getfoundry.sh/reference/forge-std/std-assertions)
- [Test Coverage](https://book.getfoundry.sh/forge/coverage)

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

**📚 Learn More:**
- [Solidity Scripting Guide](https://book.getfoundry.sh/tutorials/solidity-scripting)
- [Deploying Contracts](https://book.getfoundry.sh/forge/deploying)
- [forge script Reference](https://book.getfoundry.sh/reference/forge/forge-script)
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

**📚 Learn More:**
- [Wallet Management with Cast](https://book.getfoundry.sh/reference/cast/cast-wallet)
- [Using Keystores](https://book.getfoundry.sh/reference/cast/cast-wallet-import)

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

### Advanced Commands
```bash
forge snapshot                 # Create gas snapshot
forge snapshot --diff          # Compare with previous snapshot
forge fmt                      # Format Solidity code
forge inspect CONTRACT abi     # Get contract ABI
forge selectors list           # List all function selectors
cast calldata "func(uint256)" 123  # Encode calldata
cast 4byte 0x12345678          # Decode function selector
cast receipt TX_HASH --rpc-url URL  # Get transaction receipt
```

**📚 Learn More:**
- [Gas Optimization Guide](https://book.getfoundry.sh/forge/gas-snapshots)
- [Formatting Solidity](https://book.getfoundry.sh/reference/forge/forge-fmt)
- [Contract Inspection](https://book.getfoundry.sh/reference/forge/forge-inspect)

---

## Interacting with Deployed Contracts

After deploying your contract, you can interact with it using `cast`:

### Read Functions (view/pure)

Get the current message:
```bash
cast call YOUR_CONTRACT_ADDRESS "getMessage()" --rpc-url https://testnet-rpc.monad.xyz
```

Get message count:
```bash
cast call YOUR_CONTRACT_ADDRESS "messageCount()" --rpc-url https://testnet-rpc.monad.xyz
```

Get the author:
```bash
cast call YOUR_CONTRACT_ADDRESS "author()" --rpc-url https://testnet-rpc.monad.xyz
```

### Write Functions (requires gas)

Update the message:
```bash
cast send YOUR_CONTRACT_ADDRESS "updateMessage(string)" "Hello from Cast!" --account monad-deployer --rpc-url https://testnet-rpc.monad.xyz
```

### Decode Output

If you get hex output, decode it:
```bash
cast --to-utf8 0x...
```

**📚 Learn More:**
- [Cast Reference](https://book.getfoundry.sh/reference/cast/)
- [cast call Documentation](https://book.getfoundry.sh/reference/cast/cast-call)
- [cast send Documentation](https://book.getfoundry.sh/reference/cast/cast-send)
- [ABI Encoding/Decoding](https://book.getfoundry.sh/reference/cast/cast-abi-encode)

---

## Additional Resources

### Foundry Documentation
- [Foundry Book](https://book.getfoundry.sh/) - Complete Foundry documentation
- [Forge Commands Reference](https://book.getfoundry.sh/reference/forge/) - All forge commands
- [Cast Commands Reference](https://book.getfoundry.sh/reference/cast/) - All cast commands
- [Anvil Local Testnet](https://book.getfoundry.sh/anvil/) - Local Ethereum node
- [Chisel REPL](https://book.getfoundry.sh/chisel/) - Solidity REPL
- [Foundry GitHub](https://github.com/foundry-rs/foundry) - Source code and issues

### Testing & Development
- [Writing Tests](https://book.getfoundry.sh/forge/writing-tests)
- [Fuzz Testing](https://book.getfoundry.sh/forge/fuzz-testing)
- [Invariant Testing](https://book.getfoundry.sh/forge/invariant-testing)
- [Debugging Tests](https://book.getfoundry.sh/forge/debugger)
- [Gas Snapshots](https://book.getfoundry.sh/forge/gas-snapshots)
- [Forking Mainnet](https://book.getfoundry.sh/forge/fork-testing)

### Advanced Topics
- [Scripts and Automation](https://book.getfoundry.sh/tutorials/solidity-scripting)
- [Signature Verification](https://book.getfoundry.sh/reference/cast/cast-sig)
- [Working with ABIs](https://book.getfoundry.sh/reference/cast/cast-abi-decode)
- [Foundry Configuration](https://book.getfoundry.sh/reference/config/)

### Monad Testnet
- [Monad Documentation](https://docs.monad.xyz/)
- [Monad Deploy Guide](https://docs.monad.xyz/guides/deploy-smart-contract/foundry)
- [Monad Verify Guide](https://docs.monad.xyz/guides/verify-smart-contract/foundry)
- [Monad Faucet](https://faucet.monad.xyz/)
- [Monad Explorer](https://testnet.monadexplorer.com/)
- [Monad Developer Discord](https://discord.gg/monad)

### Solidity Resources
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Solidity by Example](https://solidity-by-example.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Consensys Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)

### Video Tutorials & Community
- [Foundry Full Course (YouTube)](https://www.youtube.com/watch?v=umepbfKp5rI) - Patrick Collins
- [Foundry Tutorials (Cyfrin)](https://www.cyfrin.io/blog)
- [Smart Contract Programmer](https://www.youtube.com/@smartcontractprogrammer) - Solidity & Foundry videos
- [Foundry Twitter](https://twitter.com/getfoundry) - Latest updates
- [Foundry Telegram](https://t.me/foundry_rs) - Community chat

### Example Projects
- [Foundry Template](https://github.com/PaulRBerg/foundry-template) - Production-ready template
- [Solmate](https://github.com/transmissions11/solmate) - Gas-optimized contracts
- [Foundry Examples](https://github.com/crisgarner/awesome-foundry) - Curated list

---

## Best Practices & Tips

### Development Workflow
1. **Always test locally first**: Use `forge test` before deploying
2. **Use gas reports**: Run `forge test --gas-report` to optimize gas usage
3. **Version control**: Commit your code frequently
4. **Use keystores**: Never expose private keys in commands or code
5. **Write descriptive tests**: Name tests clearly (e.g., `test_RevertEmptyMessage`)

### Testing Tips
- Use `setUp()` function to initialize common state
- Test edge cases and failure scenarios
- Use fuzz testing for comprehensive coverage: `function testFuzz_updateMessage(string memory input) public`
- Mock external calls with cheatcodes
- Use `vm.expectRevert()` to test error conditions

### Gas Optimization
- View gas costs: `forge test --gas-report`
- Create gas snapshots: `forge snapshot`
- Compare optimizations: `forge snapshot --diff`
- Use events for data that doesn't need on-chain storage
- Pack storage variables efficiently

### Security Considerations
- Always validate inputs in your contracts
- Use OpenZeppelin libraries for standard implementations
- Test with different user addresses using `vm.prank()`
- Consider reentrancy and other common vulnerabilities
- Get audits for production contracts

### Foundry Pro Tips
- Use `forge fmt` to auto-format your code
- Run `forge clean` if you encounter compilation issues
- Use `cast calldata` to debug function calls
- Leverage `console.log()` in tests (import from `forge-std/console.sol`)
- Use `--watch` flag to continuously verify contracts

**📚 Learn More:**
- [Smart Contract Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)
- [Gas Optimization Techniques](https://book.getfoundry.sh/forge/gas-snapshots)
- [Foundry Best Practices](https://book.getfoundry.sh/tutorials/best-practices)

---

## Troubleshooting

### Common Issues

1. **"insufficient funds"**: Get testnet tokens from the faucet
2. **Compilation errors**: Run `forge clean && forge build`
3. **RPC errors**: Check your internet connection and RPC URL
4. **Keystore password**: Make sure you remember the password you set
5. **Test failures**: Run with `-vvvv` flag for detailed traces: `forge test -vvvv`
6. **Verification fails**: Ensure you're using the correct contract name and address
7. **Module not found**: Run `forge install` to install dependencies
8. **Permission denied**: Check file permissions or run with appropriate rights

### Debug Commands

```bash
# Very verbose test output
forge test -vvvv

# Test specific function with traces
forge test --match-test test_UpdateMessage -vvvv

# Check Foundry version
forge --version

# Update Foundry
foundryup

# Clean and rebuild
forge clean && forge build

# Validate config
forge config
```

### Get Help

- Monad Developer Discord: [Join Here](https://discord.gg/monad)
- Foundry Support: [GitHub Discussions](https://github.com/foundry-rs/foundry/discussions)
- Foundry GitHub Issues: [Report Bugs](https://github.com/foundry-rs/foundry/issues)
- Ethereum Stack Exchange: [Ask Questions](https://ethereum.stackexchange.com/)

Happy Building on Monad! 🚀

---

**Workshop created with ❤️ for the Foundry & Monad communities**

