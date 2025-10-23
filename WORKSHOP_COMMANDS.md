# Workshop Commands - Quick Reference

Copy and paste these commands during the workshop.

## 1. Installation

```bash
curl -L https://foundry.paradigm.xyz | bash
```

```bash
foundryup
```

```bash
forge --version
```

---

## 2. Project Setup

```bash
forge init --template monad-developers/foundry-monad foundry-workshop
cd foundry-workshop
```

---

## 3. Compile

```bash
forge build
```

---

## 4. Run Tests

```bash
forge test
```

```bash
forge test -vv
```

```bash
forge test --gas-report
```

---

## 5. Test Deployment Script

```bash
forge script script/DeployMessageBoard.s.sol
```

---

## 6. Create Keystore

```bash
cast wallet import monad-deployer --interactive
```

Get keystore address:

```bash
cast wallet address --account monad-deployer
```

---

## 7. Get Testnet Funds

Visit: https://faucet.monad.xyz/

Check balance:

```bash
cast balance YOUR_ADDRESS --rpc-url https://testnet-rpc.monad.xyz
```

---

## 8. Deploy to Monad Testnet

Using deployment script:

```bash
forge script script/DeployMessageBoard.s.sol --account monad-deployer --broadcast
```

Or direct deployment:

```bash
forge create src/MessageBoard.sol:MessageBoard --constructor-args "Hello Monad!" --account monad-deployer --broadcast
```

---

## 9. Verify Contract

MonadExplorer (easiest):

```bash
forge verify-contract \
    YOUR_CONTRACT_ADDRESS \
    MessageBoard \
    --chain 10143 \
    --verifier sourcify \
    --verifier-url https://sourcify-api-monad.blockvision.org
```

With constructor args:

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

## 10. Interact with Contract

Read message:

```bash
cast call YOUR_CONTRACT_ADDRESS "getMessage()" --rpc-url https://testnet-rpc.monad.xyz
```

Update message:

```bash
cast send YOUR_CONTRACT_ADDRESS "updateMessage(string)" "My new message" --account monad-deployer --rpc-url https://testnet-rpc.monad.xyz
```

Get message count:

```bash
cast call YOUR_CONTRACT_ADDRESS "messageCount()" --rpc-url https://testnet-rpc.monad.xyz
```

---

## Useful Links

- Monad Faucet: https://faucet.monad.xyz/
- Monad Explorer: https://testnet.monadexplorer.com/
- Monad Docs: https://docs.monad.xyz/
- Foundry Book: https://book.getfoundry.sh/

