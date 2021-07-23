
/*
    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.6.9;

import {ICrosspolyApproveProxy} from "../CrosspolyApproveProxy.sol";
import {IERC20} from "../../intf/IERC20.sol";
import {SafeMath} from "../../lib/SafeMath.sol";
import {SafeERC20} from "../../lib/SafeERC20.sol";
import {ReentrancyGuard} from "../../lib/ReentrancyGuard.sol";

interface ICrosspolyDrops {
    function _BUY_TOKEN_() external view returns (address);
    function _FEE_MODEL_() external view returns (address);
    function getSellingInfo() external view returns (uint256, uint256, uint256);
    function buyTickets(address assetTo, uint256 ticketAmount) external;
}

interface IDropsFeeModel {
    function getPayAmount(address mysteryBox, address user, uint256 originalPrice, uint256 ticketAmount) external view returns (uint256, uint256);
}

/**
 * @title Crosspoly DropsProxy
 * @author Crosspoly Breeder
 *
 * @notice Entrance of Drops in Crosspoly platform
 */
contract CrosspolyDropsProxy is ReentrancyGuard {
    using SafeMath for uint256;

    // ============ Storage ============

    address constant _BASE_COIN_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _Crosspoly_APPROVE_PROXY_;

    // ============ Events ============
    event BuyTicket(address indexed account, address indexed mysteryBox, uint256 ticketAmount);

    fallback() external payable {}

    receive() external payable {}

    constructor(address crosspolyApproveProxy) public {
        _Crosspoly_APPROVE_PROXY_ = crosspolyApproveProxy;
    }

    function buyTickets(address payable crosspolyDrops, uint256 ticketAmount) external payable preventReentrant {
        (uint256 curPrice, uint256 sellAmount,) = ICrosspolyDrops(crosspolyDrops).getSellingInfo();
        require(curPrice > 0 && sellAmount > 0, "CAN_NOT_BUY");
        require(ticketAmount <= sellAmount, "TICKETS_NOT_ENOUGH");

        address feeModel = ICrosspolyDrops(crosspolyDrops)._FEE_MODEL_();
        (uint256 payAmount,) = IDropsFeeModel(feeModel).getPayAmount(crosspolyDrops, msg.sender, curPrice, ticketAmount);
        require(payAmount > 0, "UnQualified");
        address buyToken = ICrosspolyDrops(crosspolyDrops)._BUY_TOKEN_();

        if(buyToken == _BASE_COIN_) {
            require(msg.value == payAmount, "PAYAMOUNT_NOT_ENOUGH");
            crosspolyDrops.transfer(payAmount);
        }else {
            ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).claimTokens(buyToken, msg.sender, crosspolyDrops, payAmount);
        }

        ICrosspolyDrops(crosspolyDrops).buyTickets(msg.sender, ticketAmount);

        emit BuyTicket(msg.sender, crosspolyDrops, ticketAmount);
    } 
}