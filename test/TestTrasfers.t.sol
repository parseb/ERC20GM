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
        vm.assume(p_ > 10 && p_ < 100 ether);
        p_ = p_ * 1 gwei;
        iGM = IERC20GM(_initOneOneOne000(p_));

        address agent1 = address(11000);
        address agent2 = address(22000);

        uint256 ethDeal = 10000000000000 ether;
        deal(agent1, ethDeal);

        vm.prank(agent1);
        uint256 paid = iGM.howMuchFor(10);
        vm.prank(agent1);
        iGM.mint{value: paid}(10);

        assertTrue(address(agent1).balance + paid == ethDeal);

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

        assertEq(iGM.signalStrength(p_), 0, "no default signal");
        vm.prank(agent1);
        iGM.signal(p_ * 2);
        assertEq(iGM.price(), p_ * 2, "expected price change");
        assertEq(iGM.signalStrength(p_ * 2), 0, "state cleared");
        assertEq(iGM.signalStrength(p_), 0, "has signal");
        assertEq(iGM.signalOf(agent1)[0], 0, "has signal");
        assertTrue(iGM.signalOf(agent1)[1] != 0, "no previous signal");

        vm.revertTo(snap1);

        uint256 half1 = iGM.balanceOf(agent1) / 2;
        vm.prank(agent1);
        iGM.transfer(agent2, half1);
        vm.prank(agent1);
        uint256 sigResult1 = iGM.signal(p_ * 2);

        assertTrue(iGM.signalStrength(p_ * 2) == iGM.balanceOf(agent1), "state cleared");
        assertTrue(iGM.price() != iGM.balanceOf(agent1), "unchanged price");
        assertTrue(iGM.signalOf(agent1)[0] == p_ * 2, "has signal");
        assertTrue(iGM.signalOf(agent1)[1] == iGM.balanceOf(agent2), "12");

        uint256 str0 = iGM.signalStrength(p_ * 2); // A
        vm.prank(agent1);
        iGM.transfer(address(123), str0 / 2);

        assertTrue(str0 > iGM.signalStrength(p_ * 2), "transfer unreduce"); // B
        str0 = iGM.signalStrength(p_ * 2);

        vm.prank(agent1);
        iGM.transfer(address(3333), half1 / 2);
        assertTrue(str0 > iGM.signalStrength(p_ * 2), "transfer unreduce"); // C

        vm.prank(agent2);
        iGM.signal(p_ * 2);

        vm.prank(address(3333));
        uint256 sigResult2 = iGM.signal(p_ * 3);
        assertTrue(sigResult1 == sigResult2);

        vm.prank(address(agent1));
        uint256 sig3 = iGM.signal(p_ * 3);
        assertTrue(sig3 == p_ * 2);

        vm.prank(address(agent2));
        sig3 = iGM.signal(p_ * 3);
        assertTrue(sig3 != p_ * 2);
    }
}
