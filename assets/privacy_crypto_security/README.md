# Privacy & Crypto Security — Merkle Tree Second-Preimage Attack

| evmbench | ❌ **NOT FOUND** |
|---|---|

**Contract:** [`MerkleDrop/MerkleDrop.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/privacy_crypto_security/MerkleDrop/MerkleDrop.sol)

> **Reproduce:** go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench) and upload [`MerkleDrop/MerkleDrop.sol`](MerkleDrop/MerkleDrop.sol) from this folder. Note: your result may differ from ours.

## Description

The `MerkleAirdrop` contract distributes tokens using a Merkle proof. Eligible users submit a proof that their `(nonce, receiver, amount)` leaf is part of the committed Merkle tree. However, the leaf encoding has the exact same byte length as an internal tree node, and there is no domain separation between the two. This allows an attacker to present an internal node as a valid leaf, claiming tokens with forged parameters.

## Root Cause

[`MerkleDrop.sol#L37`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/privacy_crypto_security/MerkleDrop/MerkleDrop.sol#L37) — leaf encoding produces a 64-byte preimage, identical in structure to internal nodes:

```diff
-        bytes32 leaf = keccak256(abi.encodePacked(nonce, receiver, amount));
```

`abi.encodePacked(uint96, address, uint256)` outputs exactly **64 bytes** (12 + 20 + 32). Meanwhile, each internal node in the Merkle tree is also computed as `keccak256(abi.encodePacked(bytes32, bytes32))` — also **64 bytes** ([`MerkleDrop.sol#L59-L62`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/privacy_crypto_security/MerkleDrop/MerkleDrop.sol#L59-L62)):

```diff
             if (computedHash <= proofElement) {
-                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
             } else {
-                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
             }
```

Without domain separation (e.g., prepending `0x00` for leaves and `0x01` for nodes), an attacker can decompose any known internal node hash into a `(nonce || receiver || amount)` tuple and submit it as a valid leaf — with a shorter proof that starts one level higher in the tree.

## Impact

An attacker who knows the tree structure can forge claims for arbitrary amounts up to the full contract balance, draining all deposited tokens.

