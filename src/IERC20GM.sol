// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IERC20GM is IERC20 {


    //// @notice signals preference and returns current in-force price
    //// @param price_ prefered price amount in gwei
    function signal(uint256 price_) external returns (uint256);


    //// @notice mints specified amount to msg.sender requires corresponding value
    //// @param howMany_ number of tokens wanted
    function mint(uint256 howMany_) payable external returns (bool);

    //// @notice calculates how much specified howMany costs for value sent 
    //// @param howMany_ how many
    //// @return returns total value of how many times price
    function howMuchFor(uint256 howMany_) external view returns (uint256);
    
}