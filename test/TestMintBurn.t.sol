// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "./utils/Stage.t.sol";

contract GMinitTest is Test, Stage {
    IERC20GM iGM;

    function setUp() public {
        iGM = IERC20GM(InitDefaultInstance());
    }

    function testSimpleMint(uint256 amttm) public returns (uint256) {
        vm.assume(amttm < 100 && amttm > 1);
        vm.expectRevert();
        iGM.mint(amttm);

        vm.prank(address(222));
        vm.expectRevert();
        iGM.mint(amttm);

        deal(address(222), 200 ether);
        uint256 amt1 = iGM.howMuchFor(amttm);
        vm.expectRevert();
        vm.prank(address(423534534534534));
        iGM.mint{value: amt1}(amttm);

        vm.prank(address(222));
        iGM.mint{value: amt1}(amttm);
        return amt1;
    }

    function testSimpleBurn(uint256 amttb) public {
        vm.assume(amttb < 100 && amttb > 1);
        uint256 expectedAmount = testSimpleMint(amttb);
        console.log("balance after mint - ", address(222).balance, " -- epxectedA -- ", expectedAmount);
        uint256 balanceA = address(222).balance;
        vm.prank(address(222));
        iGM.burn(amttb);
        uint256 balanceB = address(222).balance;
        console.log("balance after burn - ", address(222).balance);
        console.log("A-B-expectedA", balanceA, balanceB, expectedAmount);
        assertTrue(balanceB > balanceA, "B !> A");
        assertEq(balanceB, balanceA + expectedAmount, "some value lost");
    }
}
