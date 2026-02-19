# Boundary Condition — Self-Transfer Balance Inflation

| evmbench | ❌ **NOT FOUND** |
|---|---|

**Contract:** [`SuperToken/SuperToken.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/boundary_condition/SuperToken/SuperToken.sol)

> **Reproduce:** go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench) and upload [`SuperToken/SuperToken.sol`](SuperToken/SuperToken.sol) from this folder. Note: your result may differ from ours.

## Description

The `SimpleToken` contract implements a basic ERC-20 token. Its internal `_transfer` function snapshots both the sender's and receiver's balances into local variables before writing the updated values back. When `_from == _to` (a self-transfer), both variables read the same storage slot, but the second write (`balanceOf[_to] = balance_to + _value`) overwrites the first (`balanceOf[_from] = balance_from - _value`), resulting in a net balance increase.

## Root Cause

[`SuperToken.sol#L43-L46`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/boundary_condition/SuperToken/SuperToken.sol#L43-L46) — cached reads followed by independent writes to potentially the same storage slot:

```diff
-        uint256 balance_from = balanceOf[_from];
-        uint256 balance_to = balanceOf[_to];
-        balanceOf[_from] = balance_from - _value;
-        balanceOf[_to] = balance_to + _value;
```

When `_from == _to`, the execution proceeds as:
1. `balance_from = balanceOf[A]` → e.g. `100`
2. `balance_to = balanceOf[A]` → `100` (same slot)
3. `balanceOf[A] = 100 - 50` → `50`
4. `balanceOf[A] = 100 + 50` → `150` (overwrites step 3)

The user started with 100 tokens and now has 150.

## Impact

Any token holder can mint unlimited tokens by repeatedly calling `transfer(self, amount)`. This completely breaks the token's supply invariant.

