// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract NullifierManager {
    mapping(uint256 => bool) _nullifiers;

    function checkNullifier(uint256 nullifier) public view {
        require(!_nullifiers[nullifier], "nullified!");
    }

    function recordNullifier(uint256 nullifier) internal {
        checkNullifier(nullifier);
        _nullifiers[nullifier] = true;
    }
}
