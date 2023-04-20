// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/ERC20GM.sol";

contract GMinitTest is Test {

    IERC20GM iGM;

    function setUp() public {
        iGM = IERC20GM( address(new ERC20GM()));
    }

    function testIsInit() public {
        assertTrue(address(iGM).code.length > 0, "codesize is 0" );
    }

}
