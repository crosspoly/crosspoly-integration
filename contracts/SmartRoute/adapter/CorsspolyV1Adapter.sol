/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

import {IERC20} from "../../intf/IERC20.sol";
import {ICrosspolyV1} from "../intf/ICrosspolyV1.sol";
import {SafeERC20} from "../../lib/SafeERC20.sol";
import {ICrosspolySellHelper} from "../helper/CrosspolySellHelper.sol";
import {UniversalERC20} from "../lib/UniversalERC20.sol";
import {SafeMath} from "../../lib/SafeMath.sol";
import {ICrosspolyAdapter} from "../intf/ICrosspolyAdapter.sol";

contract CrosspolyV1Adapter is ICrosspolyAdapter {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    address public immutable _Crosspoly_SELL_HELPER_;

    constructor(address crosspolySellHelper) public {
        _Crosspoly_SELL_HELPER_ = crosspolySellHelper;
    }
    
    function sellBase(address to, address pool, bytes memory) external override {
        address curBase = ICrosspolyV1(pool)._BASE_TOKEN_();
        uint256 curAmountIn = IERC20(curBase).tokenBalanceOf(address(this));
        IERC20(curBase).universalApproveMax(pool, curAmountIn);
        ICrosspolyV1(pool).sellBaseToken(curAmountIn, 0, "");
        if(to != address(this)) {
            address curQuote = ICrosspolyV1(pool)._QUOTE_TOKEN_();
            SafeERC20.safeTransfer(IERC20(curQuote), to, IERC20(curQuote).tokenBalanceOf(address(this)));
        }
    }

    function sellQuote(address to, address pool, bytes memory) external override {
        address curQuote = ICrosspolyV1(pool)._QUOTE_TOKEN_();
        uint256 curAmountIn = IERC20(curQuote).tokenBalanceOf(address(this));
        IERC20(curQuote).universalApproveMax(pool, curAmountIn);
        uint256 canBuyBaseAmount = ICrosspolySellHelper(_Crosspoly_SELL_HELPER_).querySellQuoteToken(
            pool,
            curAmountIn
        );
        ICrosspolyV1(pool).buyBaseToken(canBuyBaseAmount, curAmountIn, "");
        if(to != address(this)) {
            address curBase = ICrosspolyV1(pool)._BASE_TOKEN_();
            SafeERC20.safeTransfer(IERC20(curBase), to, canBuyBaseAmount);
        }
    }
}