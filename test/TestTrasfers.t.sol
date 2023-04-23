// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "./utils/Stage.t.sol";

contract TransferSignalT is Test, Stage {
    IERC20GM iGM;

    function setUp() public {
        address[] memory beneficiaries = new address[](3);
        uint256[] memory amounts = new uint256[](3);

        beneficiaries[0] = address(111);
        beneficiaries[1] = address(222);
        beneficiaries[2] = address(333);

        amounts[0] = 1000 ether;
        amounts[1] = 1 ether;
        amounts[2] = 2 ether;

        iGM = IERC20GM(InitDefaultWithPrice(32432, beneficiaries, amounts));

        vm.startPrank(address(111));
        iGM.transfer(address(30), 3 ether);
        iGM.transfer(address(20), 2 ether);
        iGM.transfer(address(10), 1 ether);
        iGM.transfer(address(40), 4 ether);

        iGM.transfer(address(100), 100 ether);
        vm.stopPrank();
    }

    function _initOneOneOne000(uint256 p_) private returns (address) {
        address[] memory beneficiaries;
        uint256[] memory amounts;
        // beneficiaries[0] = address(111);
        // amounts[0] = 1000 ether;

        iGM = IERC20GM(InitDefaultWithPrice(p_, beneficiaries, amounts));
        return address(iGM);
    }

    function testMBtransfer(uint256 p_) public {
        vm.assume(p_ > 10 && p_ < 1000000000000);
        p_ = p_ * 1 gwei;
        iGM = IERC20GM(_initOneOneOne000(p_));

        address agent1 = address(11000);
        address agent2 = address(22000);

        deal(agent1, 1000000000 ether);

        vm.prank(agent1);
        uint256 paid = iGM.howMuchFor(10);
        vm.prank(agent1);
        iGM.mint{value: paid}(10);
        assertTrue(address(agent1).balance + paid == 1000000000 ether);

        uint256 snap1 = vm.snapshot();

        /// /// ///

        vm.prank(agent1);
        iGM.transfer(agent2, 2);

        assertEq(address(agent2).balance, 0, "has balance");
        assertTrue(iGM.howMuchFor(100) == iGM.refundQtFor(100), "val diff");
        uint256 expectedEth = iGM.balanceOf(agent2) * iGM.refundQtFor(1);
        uint256 howMuchBurn = iGM.balanceOf(agent2);
        vm.prank(agent2);
        iGM.burn(howMuchBurn);
        assertEq(agent2.balance, expectedEth);
        assertEq(expectedEth / howMuchBurn, iGM.price());

        vm.revertTo(snap1);
    }
}
