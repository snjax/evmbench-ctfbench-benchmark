# Gas Security — Unbounded Loop Denial of Service

| evmbench | ✅ **FOUND** |
|---|---|

**Contract:** [`Airdrop/Airdrop.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/gas_security/Airdrop/Airdrop.sol)

> **Reproduce:** go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench) and upload [`Airdrop/Airdrop.sol`](Airdrop/Airdrop.sol) from this folder. Note: your result may differ from ours.

## Description

The `Airdrop` contract allows eligible users to register for a token distribution. After the registration deadline, anyone can call `distribute()` to send an equal share of the contract's token balance to every participant. The distribution iterates over the entire `participants` array in a single transaction, with no upper bound on the array size.

## Root Cause

[`Airdrop.sol#L47-L49`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/gas_security/Airdrop/Airdrop.sol#L47-L49) — unbounded loop over all participants:

```diff
-        for (uint256 i = 0; i < totalParticipants; i++) {
-            require(token.transfer(participants[i], amountPerParticipant), "Transfer failed");
-        }
```

Each iteration performs an ERC-20 `transfer` (which involves at minimum two `SSTORE` operations for balance updates). As the number of registered participants grows, the cumulative gas cost will eventually exceed the block gas limit, making `distribute()` impossible to execute.

Since `distributed` is only set to `true` before the loop ([L45](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/gas_security/Airdrop/Airdrop.sol#L45)) and there is no mechanism to distribute in batches or allow individual claims, the tokens become permanently locked in the contract.

## Impact

An attacker can register a large number of addresses (via Sybil accounts that pass the `IEligible` check), pushing the `participants` array past the point where a single transaction can iterate over it. This permanently blocks token distribution — a denial-of-service attack that locks all deposited funds.

