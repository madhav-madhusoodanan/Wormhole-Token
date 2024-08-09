
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Wormhole.sol";

contract WormholeTokenTest is Test {
    WormholeToken token;
    address user;
    address anotherUser;
    address tokenOwner;
    address hashedAddress;

    function setUp() public {
        tokenOwner = address(0x1);
        user = address(0x2);
        anotherUser = address(0x3);

        hashedAddress = address(1140004079580689099069266807557515350148577565412);

        token = new WormholeToken(tokenOwner);
    }

    function testHash() public view {
        assert(token.getHash(0, 0) == uint256(14744269619966411208579211824598458697587494354926760081771325075741142829156));
    }

    function testFullFlow() public {
        vm.prank(tokenOwner);
        token.mint(user, 1e8);

        vm.prank(user);
        
        token.transfer(hashedAddress, 1e3);

        uint256[2] memory _pA = [18517549688330435573786602978448975045822095210684399358706038529045891573998, 16976161227220819608000418324540293835704948541100661463766380135201326355144];
        uint256[2][2] memory _pB = [[14948062240954314104341874617450546769879499723185351984095605490073695215475, 1966024474367685361151004880101933964891913837899820700439273363472468109745], [9268740940517948192259680689721122156405616667299729048173359338474081106178, 13108364510808249188445048118504526018727949171161801731558460360073875890627]];
        uint256[2] memory _pC = [10957143253774940796496026518076589878443490988892057925520239818301681880842, 12803558460712137579826007203757836646428272969843736673611402711415208360753];
        uint256[3] memory _pubSignals = [uint256(120126390676987359528797311036419813127251651617537236923408892634354327183), 1000, 1234];

        bytes memory callData = abi.encode(_pA, _pB, _pC, _pubSignals);

        assert(token.balanceOf(anotherUser) == 0);

        vm.prank(anotherUser);
        token.mint(anotherUser, callData);

        assert(token.balanceOf(anotherUser) == 1e3);
    }

}
