# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Solidity smart contract security benchmark — a collection of intentionally vulnerable contracts organized as CTF (Capture The Flag) challenges. The project benchmarks security analysis tools (like Paradigm's evmbench) against known vulnerability patterns.

**There is no build system, test framework, or CI/CD configured.** The repository contains only Solidity source files and markdown descriptions.

## Repository Structure

All content lives under `assets/`, organized by vulnerability category:

- **access_control/** — Missing access control (`Voting.sol`: unprotected `setOwner()`)
- **arithmetic_security/** — Calculation errors (`Lending.sol`: incorrect interest rate math)
- **boundary_condition/** — Edge case exploits (`SuperToken.sol`: self-transfer minting)
- **cryptoeconomic_security/** — Economic attacks (`OracleFlashLoan.sol`: flash loan oracle manipulation)
- **data_structure_security/** — Data handling bugs (`Vesting.sol`: assembly calldata parsing error)
- **gas_security/** — Gas-related issues (`Airdrop.sol`: unbounded loop DoS)
- **privacy_crypto_security/** — Cryptographic flaws (`MerkleDrop.sol`: Merkle proof collision)

Each category contains a `.md` file describing the vulnerability and a `.sol` file with the vulnerable contract.

## Solidity Details

- Target version: `^0.8.0` (Vesting uses `^0.8.17`)
- External dependency: OpenZeppelin contracts (ERC20, SafeERC20, Ownable, ERC20Burnable)
- No compiler toolchain is configured (no Hardhat, Foundry, or Truffle)

## Conventions

- Each challenge is self-contained: one contract per vulnerability category
- Vulnerability descriptions in markdown files explain the flaw and attack vector
- Contracts are intentionally vulnerable — do not "fix" bugs unless explicitly asked
