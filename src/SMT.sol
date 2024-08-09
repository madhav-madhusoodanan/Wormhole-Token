// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Poseidon.sol";
import "forge-std/Test.sol";

contract SparseMerkleTree {
    uint256 private immutable EMPTY_NODE;
    uint256 private constant TREE_DEPTH = 160;
    
    mapping(bytes32 => uint256) private nodes;

    constructor() {
        // Initialize by filling the merkle root of an empty tree
        EMPTY_NODE = getHash(0, 0);
    }

    function update(address user, uint256 newBalance) public {
        uint256 index = uint256(bytes32(abi.encode(user)));
        uint256 leaf = getHash(newBalance, newBalance);
        uint256 current = leaf;
        uint256 sibling;

        // console.logUint(current);
        for (uint256 i = 0; i < TREE_DEPTH; i++) {
            if (index % 2 == 0) {
                uint256 potentialSibling = nodes[getNodeKey(index + 1, i)];
                sibling = potentialSibling != 0 ? potentialSibling : EMPTY_NODE;
                current = getHash(current, sibling);
            } else {
                uint256 potentialSibling = nodes[getNodeKey(index - 1, i)];
                sibling = potentialSibling != 0 ? potentialSibling : EMPTY_NODE;
                current = getHash(sibling, current);
            }

            nodes[getNodeKey(index, i)] = current;
            console.logUint(current);
            index /= 2;
        }

        nodes[bytes32(0)] = current;
    }


    function getRoot() public view returns (uint256) {
        return nodes[bytes32(0)];
    }


    function getNodeKey(uint256 index, uint256 depth) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(index, depth));
    }

    function getHash(uint256 input1, uint256 input2) public pure returns(uint256) {
        uint256[2] memory inputs = [input1, input2];
        return PoseidonT3.hash(inputs);
    }
}
