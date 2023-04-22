// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "./utils/Stage.t.sol";


contract GMinitTest is Test, Stage {

    IERC20GM iGM;

    function setUp() public {
        iGM = IERC20GM(InitDefaultInstance());
    }

    function testSimpleMint() public returns (uint256)  {
        vm.expectRevert();
        iGM.mint(1);

        vm.prank(address(222));
        vm.expectRevert();
        iGM.mint(1);

        deal(address(222), 200 ether);
        uint256 amt1 = iGM.howMuchFor(5);
        vm.expectRevert();
        iGM.mint{value:amt1}(6);

        vm.prank(address(222));
        iGM.mint{value:amt1}(5);
        return amt1;
    }

    function testSimpleBurn() public {
        uint expectedAmount = testSimpleMint();
        console.log("balance after mint - ", address(222).balance, " -- epxectedA -- ", expectedAmount);
        uint balanceA = address(222).balance; 
        vm.prank(address(222));
        iGM.burn(5);
        uint balanceB = address(222).balance; 
        console.log("balance after burn - ", address(222).balance);
        console.log("A-B-expectedA", balanceA , balanceB , expectedAmount);
        assertTrue(balanceB > balanceA, "B !> A");
        assertTrue(balanceB == balanceA + expectedAmount, "some value lost");
    }


}