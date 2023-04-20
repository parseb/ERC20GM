// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20GM} from './IERC20GM.sol';
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract ERC20GM is ERC20, IERC20GM {
    
    /// Override
    string private _name;
    string private _symbol;

    uint64 price;

    constructor(string memory name_, string memory symbol_, uint64 price_) ERC20(name_, symbol_) {
        price = price_ == 0 ? uint64(uint160(bytes20(address(this))) % 1 gwei) : price_;
    }
}
