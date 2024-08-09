// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract WormholeToken is ERC20, ERC20Permit {
    constructor() ERC20("WormholeToken", "WTK") ERC20Permit("WormholeToken") {}
}
