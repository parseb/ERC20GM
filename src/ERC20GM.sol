// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20GM} from './IERC20GM.sol';
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract ERC20GM is ERC20, IERC20GM {
    
    uint256 public price;

    //// price -> signal 
    mapping(uint256 => uint256) priceSignal;

    //// agent -> sigID : sigStrength
    mapping(address => uint256[2]) agentSignal;



    ////////////////// Events

    event PriceChanged(uint256 price);

    event PriceSignaled(address, uint256 indexed price, uint256 atTimeStamp);



    ////////////////// External


    //// @notice constructor function instantiates immutable contract instance
    //// @param name_ wanted name of token
    //// @param symbol_ wanted symbol of token
    //// @param price_ wanted initial price
    constructor(string memory name_, string memory symbol_, uint256 price_) ERC20(name_, symbol_) {
        price = price_ == 0 ? uint256(uint160(bytes20(address(this))) % 1 gwei) : price_;
    }

    //// @inheritdoc IERC20GM
    function mint(uint256 howMany_) payable external returns (bool) {}

    //// @inheritdoc IERC20GM
    function signal(uint256 price_) external returns (uint256) {
        uint256 pre = agentSignal[msg.sender][0];
        if (pre > 0) priceSignal[pre] -= agentSignal[msg.sender][1];
        agentSignal[msg.sender][0] = price_;
        agentSignal[msg.sender][1] = balanceOf(msg.sender);
        priceSignal[pre] += balanceOf(msg.sender);

        if ( priceSignal[pre] > totalSupply() / 2 ) {
             price = price_;
             delete priceSignal[pre];
             delete agentSignal[msg.sender][0];

             emit PriceChanged(price);
        }

        emit PriceSignaled(msg.sender, price_, block.timestamp);
        return price;
    }


    ////////////////// VIEW //////////////////

    //// @inheritdoc IERC20GM
    function howMuchFor(uint256 howMany_) external view returns (uint256)  { 
        return ( howMany_ * price); 
        }
}
