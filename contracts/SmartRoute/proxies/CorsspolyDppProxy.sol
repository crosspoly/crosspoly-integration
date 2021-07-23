/*
    Copyright 2021 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.6.9;

import {ICrosspolyApproveProxy} from "../CrosspolyApproveProxy.sol";
import {ICrosspolyV2} from "./../intf/ICrosspolyV2.sol";
import {IERC20} from "../../intf/IERC20.sol";
import {SafeERC20} from "../../lib/SafeERC20.sol";
import {IWETH} from "../../intf/IWETH.sol";
import {SafeMath} from "../../lib/SafeMath.sol";
import {SafeERC20} from "../../lib/SafeERC20.sol";
import {ReentrancyGuard} from "../../lib/ReentrancyGuard.sol";

interface IDPPOracle {
    function reset(
        address assetTo,
        uint256 newLpFeeRate,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);
}


/**
 * @title CrosspolyDppProxy
 * @author Crosspoly Breeder
 *
 * @notice Crosspoly Private Pool Proxy
 */
contract CrosspolyDppProxy is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage ============

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _WETH_;
    address public immutable _Crosspoly_APPROVE_PROXY_;

    // ============ Modifiers ============

    modifier judgeExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "CrosspolyCpProxy: EXPIRED");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    constructor(
        address payable weth,
        address crosspolyApproveProxy
    ) public {
        _WETH_ = weth;
        _Crosspoly_APPROVE_PROXY_ = crosspolyApproveProxy;
    }

    // DPPOracle
    function resetCrosspolyPrivatePool(
        address dppAddress,
        uint256[] memory paramList,  //0 - newLpFeeRate, 1 - newK
        uint256[] memory amountList, //0 - baseInAmount, 1 - quoteInAmount, 2 - baseOutAmount, 3- quoteOutAmount
        uint8 flag, //0 - ERC20, 1 - baseInETH, 2 - quoteInETH, 3 - baseOutETH, 4 - quoteOutETH
        uint256 minBaseReserve,
        uint256 minQuoteReserve,
        uint256 deadLine
    ) external payable preventReentrant judgeExpired(deadLine) {
        _deposit(
            msg.sender,
            dppAddress,
            ICrosspolyV2(dppAddress)._BASE_TOKEN_(),
            amountList[0],
            flag == 1
        );
        _deposit(
            msg.sender,
            dppAddress,
            ICrosspolyV2(dppAddress)._QUOTE_TOKEN_(),
            amountList[1],
            flag == 2
        );

        require(IDPPOracle(ICrosspolyV2(dppAddress)._OWNER_()).reset(
            msg.sender,
            paramList[0],
            paramList[1],
            amountList[2],
            amountList[3],
            minBaseReserve,
            minQuoteReserve
        ), "Reset Failed");

        _withdraw(msg.sender, ICrosspolyV2(dppAddress)._BASE_TOKEN_(), amountList[2], flag == 3);
        _withdraw(msg.sender, ICrosspolyV2(dppAddress)._QUOTE_TOKEN_(), amountList[3], flag == 4);
    }


    //====================== internal =======================

    function _deposit(
        address from,
        address to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {
        if (isETH) {
            if (amount > 0) {
                IWETH(_WETH_).deposit{value: amount}();
                if (to != address(this)) SafeERC20.safeTransfer(IERC20(_WETH_), to, amount);
            }
        } else {
            ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).claimTokens(token, from, to, amount);
        }
    }

    function _withdraw(
        address payable to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {
        if (isETH) {
            if (amount > 0) {
                IWETH(_WETH_).withdraw(amount);
                to.transfer(amount);
            }
        } else {
            if (amount > 0) {
                SafeERC20.safeTransfer(IERC20(token), to, amount);
            }
        }
    }
}