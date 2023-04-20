// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IERC20GM is IERC20 {


    //// @note signals preference and returns in-force pricing
    function signal(uint64 price_) external returns (uint64);
    
}