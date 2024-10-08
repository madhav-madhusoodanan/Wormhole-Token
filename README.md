# The Wormhole Token Project

An EIP-7503 compliant ERC20 token. 

## Description

This token utilizes ZK-SNARKs to allow token holders to "teleport" funds to a different address untraceably. For more details, visit [this EIP](https://eips.ethereum.org/EIPS/eip-7503) and [this tweet](https://x.com/ethereumintern_/status/1816164288278450306) for more context and explanation.

## Features
<ol>
    <li> ~39k non-linear constraints generated by the zk-circuit. This means that token teleportation can be done in-browser :)
</ol>

## Shenanigans
<ol>
    <li> The brutal gas fee consumed by the Transfer Function. This is due to the insane gas usage of the updateState function in SparseMerkleTree contract. Efforts are on to optimize gas usage in this function.
</ol>


## Foundry Gas report
```bash
Ran 2 tests for test/SMT.t.sol:SparseMerkleTreeTest
[PASS] testHash() (gas: 39186)
[PASS] testUpdates() (gas: 9174427)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 33.94ms (33.54ms CPU time)

Ran 2 tests for test/Wormhole.t.sol:WormholeTokenTest
[PASS] testFullFlow() (gas: 31395943)
[PASS] testHash() (gas: 39294)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 133.49ms (132.82ms CPU time)

| src/SMT.sol:SparseMerkleTree contract |                 |         |         |         |         |
|---------------------------------------|-----------------|---------|---------|---------|---------|
| Deployment Cost                       | Deployment Size |         |         |         |         |
| 785455                                | 3443            |         |         |         |         |
| Function Name                         | min             | avg     | median  | max     | # calls |
| getHash                               | 33955           | 33955   | 33955   | 33955   | 2       |
| updateState                           | 9134747         | 9134747 | 9134747 | 9134747 | 1       |


| src/Wormhole.sol:WormholeToken contract |                 |          |          |          |         |
|-----------------------------------------|-----------------|----------|----------|----------|---------|
| Deployment Cost                         | Deployment Size |          |          |          |         |
| 2046028                                 | 10081           |          |          |          |         |
| Function Name                           | min             | avg      | median   | max      | # calls |
| balanceOf                               | 667             | 1667     | 1667     | 2667     | 2       |
| getHash                                 | 34063           | 34063    | 34063    | 34063    | 1       |
| mint(address,bytes)                     | 6669914         | 6669914  | 6669914  | 6669914  | 1       |
| mint(address,uint256)                   | 9187550         | 9187550  | 9187550  | 9187550  | 1       |
| transfer                                | 15513213        | 15513213 | 15513213 | 15513213 | 1       |


| src/libraries/Poseidon.sol:PoseidonT3 contract |                 |       |        |       |         |
|------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                | Deployment Size |       |        |       |         |
| 3296882                                        | 16518           |       |        |       |         |
| Function Name                                  | min             | avg   | median | max   | # calls |
| hash                                           | 30485           | 30485 | 30485  | 30485 | 812     |


| src/verifier/MerkleTreeVerifier.sol:MerkleTreeVerifier contract |                 |        |        |        |         |
|-----------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                                                 | Deployment Size |        |        |        |         |
| 0                                                               | 0               |        |        |        |         |
| Function Name                                                   | min             | avg    | median | max    | # calls |
| verifyProof                                                     | 202279          | 202279 | 202279 | 202279 | 1       |


Ran 2 test suites in 137.30ms (167.43ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
```
