// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "./utils/Stage.t.sol";


contract GMinitTest is Test, Stage {

    IERC20GM iGM;

    function setUp() public {
        iGM = IERC20GM(InitDefaultInstance());
    }

    function testSimpleMint() public {
        vm.expectRevert();
        iGM.mint(1);

        vm.prank(address(222));
        vm.expectRevert();
        iGM.mint(1);

        deal(address(222), 200 ether);
        uint256 amt1 = iGM.howMuchFor(5);
        vm.expectRevert();
        iGM.mint{value:amt1}(6);

        iGM.mint{value:amt1}(5);
    }


}