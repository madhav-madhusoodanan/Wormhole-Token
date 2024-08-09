// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SMT.sol";

contract SparseMerkleTreeTest is Test {
    SparseMerkleTree private smt;
    bytes32 testvalue;

    function setUp() public {
        smt = new SparseMerkleTree();
    }

    function testMultipleUpdates() public {
        uint256 hashedAddress = smt.getHash(1234, 1234);
        // console.log(hashedAddress);

        smt.update(address(uint160(hashedAddress)), 1000);
        // console.logUint(smt.getRoot());
    }

    function testHash() public view {
        assert(smt.getHash(0, 0) == uint256(14744269619966411208579211824598458697587494354926760081771325075741142829156));
    }

}
