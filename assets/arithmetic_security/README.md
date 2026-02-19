# Arithmetic Security — Incorrect Interest Rate Calculation

| evmbench | ❌ **NOT FOUND** |
|---|---|

**Contract:** [`Lending/Lending.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/arithmetic_security/Lending/Lending.sol)

> **Reproduce:** go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench) and upload [`Lending/Lending.sol`](Lending/Lending.sol) from this folder. Note: your result may differ from ours.

## Description

The `MinimalLending` contract implements a collateralized lending protocol with continuous interest accrual. The interest rate is approximated using a Taylor series expansion of `e^x`. However, the intermediate variable `x` (which represents the total accrued rate) is computed incorrectly, causing the debt calculation to be drastically wrong.

## Root Cause

[`Lending.sol#L64-L67`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/arithmetic_security/Lending/Lending.sol#L64-L67) — spurious division by `scale` when computing `x`:

```diff
         uint256 timeElapsed = block.timestamp - loan.startTime;
         uint256 scale = 1e18;

-        uint256 x = INTEREST_RATE_PER_SECOND * timeElapsed / scale;
```

`INTEREST_RATE_PER_SECOND` is already a fixed-point value in `1e18` scale (defined as `3170979198` on L19). Multiplying it by `timeElapsed` (a plain integer, seconds) yields a result already in `1e18` scale. Dividing by `scale` again reduces `x` to near zero, because `INTEREST_RATE_PER_SECOND * timeElapsed` is much smaller than `1e18` for any reasonable time period.

The correct computation should be:

```solidity
uint256 x = INTEREST_RATE_PER_SECOND * timeElapsed;
```

## Impact

The Taylor expansion at [`Lending.sol#L69-L72`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/arithmetic_security/Lending/Lending.sol#L69-L72) receives a near-zero `x`, producing `expApprox ≈ scale`. This means `getCurrentDebt` returns approximately the original principal with virtually no interest, regardless of how much time has passed. Borrowers can take loans and repay them almost interest-free, draining the protocol's liquidity.

