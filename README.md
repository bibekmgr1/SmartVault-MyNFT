# SmartVault + MyNFT

A Web3 project with two Solidity smart contracts deployed on Sepolia testnet, complete with Foundry tests and frontend interfaces.

## Deployed Contracts (Sepolia)

| Contract | Address |
|----------|---------|
| **SmartVault** | [0x3e8784A26935c66865CCbFa3054bA256673DAe46](https://sepolia.etherscan.io/address/0x3e8784A26935c66865CCbFa3054bA256673DAe46) |
| **MyNFT** | [0x4692eE780607Dd5b327e713a214477a454C49A7E](https://sepolia.etherscan.io/address/0x4692eE780607Dd5b327e713a214477a454C49A7E) |

## Features

### SmartVault (Wallet)
- Deposit ETH into contract
- Withdraw ETH (with lock duration)
- Send ETH to another address
- Pause/Unpause (owner only)
- Custom errors for gas optimization
- CEI pattern for reentrancy protection

### MyNFT (ERC-721)
- Mint NFTs with payment
- Withdraw revenue (owner only)
- Max supply: 10,000
- Gas optimized (custom errors, constants, unchecked blocks)
- Fuzz tested with Foundry

## Tech Stack
- **Solidity** 0.8.19
- **Foundry** (testing & deployment)
- **OpenZeppelin** (ERC-721, Ownable)
- **Ethers.js v6** (frontend)

## Project Structure
SmartVault-MyNFT/
├── src/
│ ├── SmartVault.sol
│ └── MyNFT.sol
├── test/
│ ├── SmartVault.t.sol
│ └── MyNFT.t.sol
├── script/
│ ├── DeploySmartVault.s.sol
│ └── DeployMyNFT.s.sol
├── frontend/
│ ├── vault.html
│ └── nft.html
└── README.md

## Tests

Run all tests:
forge test
Result:

bibek@DESKTOP-5QO8H22 MINGW64 ~/SmartVault (main)
$ forge test 
[⠒] Compiling...
No files changed, compilation skipped

Ran 4 tests for test/SmartVault.t.sol:SmartVaultTest
[PASS] testFuzzDeposit(uint256) (runs: 256, μ: 76474, ~: 76474)
[PASS] testFuzzReceive(uint256) (runs: 256, μ: 76307, ~: 76307)
[PASS] testFuzzSendEth(uint256) (runs: 256, μ: 119961, ~: 119961)
[PASS] testFuzzWithdraw(uint256) (runs: 256, μ: 94691, ~: 94691)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 423.57ms (1.00s CPU time)

Ran 3 tests for test/MyNFT.t.sol:MyNFTTest
[PASS] testFuzzMint(uint256) (runs: 256, μ: 95069, ~: 95069)
[PASS] testFuzzMintRevertsIfInsufficientPayment(uint256) (runs: 256, μ: 20700, ~: 21119)
[PASS] testFuzzWithdraw(uint256) (runs: 256, μ: 106148, ~: 106148)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 427.34ms (537.35ms CPU time)

Ran 2 test suites in 438.89ms (850.91ms CPU time): 7 tests passed, 0 failed, 0 skipped (7 total tests)

Frontend
Two simple HTML frontends:

frontend/vault.html - Connect wallet, deposit, withdraw, send ETH, pause/unpause

frontend/nft.html - Connect wallet, mint NFT, withdraw revenue

Both include event listeners for real-time updates.

# Clone repo
git clone https://github.com/bibekmgr1/SmartVault-MyNFT.git
cd SmartVault-MyNFT

# Install dependencies
forge install

# Run tests
forge test

