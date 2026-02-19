# Access Control — Missing Owner Check

| evmbench | ✅ **FOUND** |
|---|---|

**Contract:** [`Voting/Voting.sol`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/access_control/Voting/Voting.sol)

> **Reproduce:** go to [paradigm.xyz/evmbench](https://paradigm.xyz/evmbench) and upload [`Voting/Voting.sol`](Voting/Voting.sol) from this folder. Note: your result may differ from ours.

## Description

The `CTFVoting` contract uses an `onlyOwner` modifier to protect privileged functions like `addProposal` and `extendVoting`. However, the `setOwner` function — which transfers ownership of the entire contract — has no access control at all. Any external account can call `setOwner` to become the owner, and then use the privileged functions to manipulate the voting process (add proposals, extend deadlines, etc.).

## Root Cause

[`Voting.sol#L45-L47`](https://github.com/snjax/evmbench-ctfbench-benchmark/blob/master/assets/access_control/Voting/Voting.sol#L45-L47) — `setOwner` is declared `public` without the `onlyOwner` modifier:

```diff
-    function setOwner(address newOwner) public {
         owner = newOwner;
     }
```

Compare with the other privileged functions that correctly use the modifier:

```solidity
    function addProposal(string memory description) public onlyOwner {  // L36
    function extendVoting(uint256 extraTime) public onlyOwner {         // L41
```

## Impact

Any user can take over the contract, gaining the ability to:
- Add arbitrary proposals (`addProposal`)
- Extend the voting deadline indefinitely (`extendVoting`)
- Transfer ownership further

