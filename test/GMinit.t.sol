// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "./utils/Stage.t.sol";

contract GMinitTest is Test, Stage {

    IERC20GM iGM;

    function setUp() public {
        iGM = IERC20GM(InitDefaultInstance());
    }

    function testIsInit() public {
        assertTrue(address(iGM).code.length > 0, "codesize is 0" );
    }

}
