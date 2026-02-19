# evmbench-ctfbench-benchmark

Benchmarking Paradigm's [evmbench](https://paradigm.xyz/evmbench) against the [CTFBench](https://ctfbench.com) dataset — a collection of intentionally vulnerable Solidity smart contracts designed for security tool evaluation.

The test contracts are sourced from: [auditdbio/ctfbench/benchmark_data/contracts/with_errors](https://github.com/auditdbio/ctfbench/tree/main/benchmark_data/contracts/with_errors)

## Results

**Score: 4 / 7**

The 7 core tests were run in the standard way — each model received only the raw `.sol` file, with no surrounding project, no tests, and no hints.

| # | Category | Contract | Result | Write-up |
|---|----------|----------|--------|----------|
| 1 | Access Control | `Voting.sol` | ✅ Found | [View](assets/access_control/) |
| 2 | Arithmetic Security | `Lending.sol` | ❌ Not found | [View](assets/arithmetic_security/) |
| 3 | Boundary Condition | `SuperToken.sol` | ❌ Not found | [View](assets/boundary_condition/) |
| 4 | Cryptoeconomic Security | `OracleFlashLoan.sol` | ✅ Found | [View](assets/cryptoeconomic_security/) |
| 5 | Data Structure Security | `Vesting.sol` | ✅ Found | [View](assets/data_structure_security/) |
| 6 | Gas Security | `Airdrop.sol` | ✅ Found | [View](assets/gas_security/) |
| 7 | Privacy & Crypto Security | `MerkleDrop.sol` | ❌ Not found | [View](assets/privacy_crypto_security/) |

### Optimized case for gpt-5.2-codex

We also prepared a special variant of the Boundary Condition case — a complete Foundry project with a README, working tests, and an explicit hint that the contract contains a vulnerability. This was tailored for gpt-5.2-codex, whose strong suit is writing and executing code. The agent could have easily covered the contract with fuzz tests or property-based tests to find the bug. Despite all of this, the vulnerability was not found.

| # | Category | Contract | Result | Write-up |
|---|----------|----------|--------|----------|
| 8 | Boundary Condition (Optimized) | `SuperToken.sol` | ❌ Not found | [View](assets/boundary_condition_optimized/) |

## How to Reproduce

To reproduce our exact results, go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench) and upload the corresponding file from this repo as-is, without modifications:

1. Go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench)
2. Upload the `.sol` file from the matching folder (e.g. `assets/access_control/Voting/Voting.sol`)
3. For the optimized case (#8), unpack `supertoken_evmbench_optimized.zip` and upload the extracted folder

Each case README also has a **Reproduce** link at the top.
