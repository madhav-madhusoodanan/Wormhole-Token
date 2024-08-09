// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SMT.sol";
import "./Nullifier.sol";

contract WormholeToken is Ownable, ERC20, ERC20Permit, SparseMerkleTree, NullifierManager {
    constructor(address _owner) 
        Ownable(_owner)
        ERC20("WormholeToken", "WTK") 
        ERC20Permit("WormholeToken")
        SparseMerkleTree()
    {}

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);   
        _updateAddress(from);
        _updateAddress(to);
    }

    function _updateAddress(address target) private {
        if(target == address(0)) return;

        uint256 newBalance = balanceOf(target);
        super.updateState(target, newBalance);
    }

    function mint(address to, bytes calldata proof) public {
        require(balanceOf(to) == 0, "Not a fresh account!");

        (uint256 balance, uint256 nullifier) = verify(proof);

        recordNullifier(nullifier);
        _mint(to, balance);
        
        
        /*
            1. get amount from proof
            2. record nullifier
            3. mint to the address
            
        */
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
