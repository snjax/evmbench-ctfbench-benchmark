// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SimpleToken} from "../src/SuperToken.sol";

contract SuperTokenTest is Test {
    SimpleToken public token;
    address public alice;
    address public bob;

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        vm.prank(alice);
        token = new SimpleToken("SuperToken", "STK", 18, 1000 ether);
    }

    function test_transfer() public {
        uint256 amount = 100 ether;

        vm.prank(alice);
        token.transfer(bob, amount);

        assertEq(token.balanceOf(alice), 900 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }
}
