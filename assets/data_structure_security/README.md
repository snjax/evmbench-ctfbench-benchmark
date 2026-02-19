# Data Structure Security — Incorrect Calldata Parsing in Assembly

| evmbench | ✅ **FOUND** |
|---|---|

**Contract:** [`Vesting/Vesting.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/data_structure_security/Vesting/Vesting.sol)

> **Reproduce:** go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench) and upload [`Vesting/Vesting.sol`](Vesting/Vesting.sol) from this folder. Note: your result may differ from ours.

## Description

The `Vesting` contract locks deposited ETH for one week, then allows the depositor to release funds to a specified recipient. The `processRelease` function uses inline assembly to extract the `address` parameter from calldata, but the bitwise operation is wrong — it reads the padding bytes instead of the actual address, producing an incorrect `_recipient`.

## Root Cause

[`Vesting.sol#L27-L31`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/data_structure_security/Vesting/Vesting.sol#L27-L31) — incorrect assembly extraction of the second parameter:

```diff
     function processRelease(uint256 _amount, address) public {
         address _recipient;
         assembly {
-            _recipient := shr(96, calldataload(36))
         }
```

ABI encoding for `(uint256, address)` places the address **right-aligned** (low bytes) in the 32-byte word at calldata offset 36:

```
Offset 36:  0x000000000000000000000000AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            ├── 12 bytes padding ──────┤├── 20 bytes address ─────────────────┤
```

`shr(96, calldataload(36))` shifts the entire 256-bit word right by 96 bits (12 bytes). This discards the low 12 bytes of the address and returns only the top 8 bytes of the address value — a truncated, incorrect result.

Additionally, when called via `processReleaseForMyself(uint256 _amount)` ([L23-L25](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/data_structure_security/Vesting/Vesting.sol#L23-L25)), the original calldata has only 36 bytes (4-byte selector + 32-byte `_amount`), so `calldataload(36)` reads past the end of the calldata and returns zero — causing the `require(_recipient != address(0))` check to revert.

## Impact

- Direct calls to `processRelease` send funds to a wrong (truncated) address, effectively burning the user's ETH.
- Calls through `processReleaseForMyself` always revert, making the convenience wrapper unusable.
- An attacker who controls the truncated address can steal funds.

