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
        address[] memory beneficiaries = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        beneficiaries[0] = address(111);
        amounts[0] = 1000 ether;

        iGM = IERC20GM(InitDefaultWithPrice(p_, beneficiaries, amounts));
        return address(iGM);
    }

    function testInitSetupWithPrice(uint256 p_) public {
        vm.assume(p_ > 1);
        iGM = IERC20GM(_initOneOneOne000(p_));
    }
}
