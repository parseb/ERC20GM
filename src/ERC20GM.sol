// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20GM} from "./IERC20GM.sol";
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract ERC20GM is ERC20, IERC20GM {
    //// price amount
    uint256 public price;

    //// price -> signal
    mapping(uint256 => uint256) priceSignal;

    //// agent -> sigID : sigStrength
    mapping(address => uint256[2]) agentSignal;

    ////////////////// Events

    event PriceChanged(uint256 price);
    event PriceSignaled(address, uint256 indexed price, uint256 atTimeStamp);

    ////////////////// Errors

    error ValueMismatch();
    error BurnRefundF();
    error InvalidPrice();

    ////////////////// External

    //// @notice constructor function instantiates immutable contract instance
    //// @param name_ wanted name of token
    //// @param symbol_ wanted symbol of token
    //// @param price_ wanted initial price
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 price_,
        address[] memory initMintAddrs_,
        uint256[] memory initMintAmts_
    ) ERC20(name_, symbol_) {
        price = price_ == 0 ? (uint256(uint160(bytes20(address(this))) % 10)) : price_;
        price_ = 0;
        for (price_; price_ < initMintAddrs_.length;) {
            _mint(initMintAddrs_[price_], initMintAmts_[price_]);
            unchecked {
                ++price_;
            }
        }
    }

    //// @inheritdoc IERC20GM
    function mint(uint256 howMany_) external payable {
        if (msg.value != howMuchFor(howMany_)) revert ValueMismatch();
        _mint(msg.sender, howMany_);
    }

    //// @inheritdoc IERC20GM
    function burn(uint256 howMany_) external {
        uint256 amount = refundQtFor(howMany_);
        _burn(msg.sender, howMany_);
        (bool s,) = msg.sender.call{value: amount}("");
        if (!s) revert BurnRefundF();
    }

    //// @inheritdoc IERC20GM
    function signal(uint256 price_) external returns (uint256) {
        if (price > price_) revert InvalidPrice();
        uint256 pre = agentSignal[msg.sender][0];
        if (pre > 0 && priceSignal[pre] > 0) priceSignal[pre] -= agentSignal[msg.sender][1];
        agentSignal[msg.sender][0] = price_;
        agentSignal[msg.sender][1] = balanceOf(msg.sender);
        priceSignal[price_] += balanceOf(msg.sender);

        if (priceSignal[price_] > totalSupply() / 2) {
            price = price_;
            delete priceSignal[price_];
            delete agentSignal[msg.sender][0];

            emit PriceChanged(price);
        }

        emit PriceSignaled(msg.sender, price_, block.timestamp);
        return price;
    }

    ////////////////// VIEW //////////////////

    //// @inheritdoc IERC20GM
    function howMuchFor(uint256 howMany_) public view returns (uint256) {
        return howMany_ * price;
    }

    function refundQtFor(uint256 howMany_) public view returns (uint256) {
        return howMany_ * address(this).balance / totalSupply();
    }

    //// @inheritdoc IERC20GM
    function signalStrength(uint256 p_) public view returns (uint256) {
        return priceSignal[p_];
    }

    ////////////////// OVERRIDE //////////////////

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override {}
}
