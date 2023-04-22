// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/ERC20GM.sol";

contract Stage is Test {
    function InitDefaultInstance() public returns (address) {
        address[] memory beneficiaries = new address[](3);
        uint256[] memory amounts = new uint256[](3);

        beneficiaries[0] = address(111);
        beneficiaries[1] = address(222);
        beneficiaries[2] = address(333);

        amounts[0] = 1000 ether;
        amounts[1] = 1 ether;
        amounts[2] = 2 ether;

        return address(new ERC20GM("Fungible Governable Token", "FGT", 123456789, beneficiaries, amounts));
    }

    function InitDefaultRandPrice() public returns (address) {
        address[] memory beneficiaries = new address[](3);
        uint256[] memory amounts = new uint256[](3);

        beneficiaries[0] = address(111);
        beneficiaries[1] = address(222);
        beneficiaries[2] = address(333);

        amounts[0] = 100 ether;
        amounts[1] = 1 ether;
        amounts[2] = 2 ether;

        return address(new ERC20GM("Fungible Governable Token", "FGT", 0, beneficiaries, amounts));
    }
}
