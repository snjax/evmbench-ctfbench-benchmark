# Boundary Condition (Optimized) — Self-Transfer Balance Inflation

| evmbench | ❌ **NOT FOUND** |
|---|---|

**Contract:** [`supertoken_evmbench_optimized_example/src/SuperToken.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/boundary_condition_optimized/supertoken_evmbench_optimized_example/src/SuperToken.sol)

> **Reproduce:** go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench), unpack [`supertoken_evmbench_optimized.zip`](supertoken_evmbench_optimized.zip) and upload the extracted folder. The folder `supertoken_evmbench_optimized_example/` is provided for reference only — to reproduce correctly, use the contents of the zip archive. Note: your result may differ from ours.

## What makes this case special

This is the same `SuperToken.sol` vulnerability as in [`boundary_condition/`](../boundary_condition/), but packaged as a complete Foundry project with significant hints for the AI agent (gpt-5.2-codex):

1. **The README explicitly states this is an educational auditing project** — the model knows a bug is present and needs to be found
2. **The code compiles and runs out of the box** — `forge test` passes, so the agent can freely write fuzz tests, property tests, or any other dynamic analysis
3. **A test file is included** ([`test/SuperToken.t.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/boundary_condition_optimized/supertoken_evmbench_optimized_example/test/SuperToken.t.sol)) — the agent has a working example to build upon

Despite all of this, the AI agent failed to find the vulnerability.

## Root Cause

Same as [`boundary_condition`](../boundary_condition/) — see that write-up for the full analysis.

[`SuperToken.sol#L43-L46`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/boundary_condition_optimized/supertoken_evmbench_optimized_example/src/SuperToken.sol#L43-L46) — cached reads followed by independent writes to potentially the same storage slot:

```diff
-        uint256 balance_from = balanceOf[_from];
-        uint256 balance_to = balanceOf[_to];
-        balanceOf[_from] = balance_from - _value;
-        balanceOf[_to] = balance_to + _value;
```

When `_from == _to`, the second write overwrites the first, resulting in a net balance increase instead of a no-op.

## Impact

Any token holder can mint unlimited tokens by calling `transfer(self, amount)`.
