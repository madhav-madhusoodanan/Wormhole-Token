// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./libraries/Poseidon.sol";
import "./verifier/MerkleTreeVerifier.sol";
import "forge-std/Test.sol";

contract SparseMerkleTree {
    uint256 private immutable EMPTY_NODE;
    uint256 private constant TREE_DEPTH = 160;

    MerkleTreeVerifier public immutable VERIFIER;
    
    mapping(bytes32 => uint256) private nodes;

    constructor() {
        // Initialize by filling the merkle root of an empty tree
        EMPTY_NODE = getHash(0, 0);
        VERIFIER = new MerkleTreeVerifier();
    }

    function updateState(address user, uint256 newBalance) public {
        uint256 index = uint256(bytes32(abi.encode(user)));
        uint256 leaf = getHash(newBalance, newBalance);
        uint256 current = leaf;
        uint256 sibling;
        console.logString("=================");
        console.logUint(current);
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
            console.logUint(sibling);
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

    function verify(bytes memory proof) internal returns (uint256, uint256) {
        (uint256[2] memory _pA, uint256[2][2] memory _pB, uint256[2] memory _pC, uint256[3] memory _pubSignals) = abi.decode(proof, (uint256[2], uint256[2][2], uint256[2], uint256[3]));

        require(
            VERIFIER.verifyProof(_pA, _pB, _pC, _pubSignals),
            "Proof not valid!"
        );

        require(getRoot() == _pubSignals[0], "Not matching merkle root!");

        return (_pubSignals[1], _pubSignals[2]);
    }
}
