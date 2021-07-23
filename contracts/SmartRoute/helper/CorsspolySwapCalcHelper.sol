/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

import {ICrosspolyV1} from "../intf/ICrosspolyV1.sol";
import {ICrosspolySellHelper} from "./CrosspolySellHelper.sol";

contract CrosspolySwapCalcHelper {
    address public immutable _Crosspoly_SELL_HELPER_;

    constructor(address crosspolySellHelper) public {
        _Crosspoly_SELL_HELPER_ = crosspolySellHelper;
    }

    function calcReturnAmountV1(
        uint256 fromTokenAmount,
        address[] memory crosspolyPairs,
        uint8[] memory directions
    ) external view returns (uint256 returnAmount,uint256[] memory midPrices,uint256[] memory feeRates) {
        returnAmount = fromTokenAmount;
        midPrices = new uint256[](crosspolyPairs.length);
        feeRates = new uint256[](crosspolyPairs.length);
        for (uint256 i = 0; i < crosspolyPairs.length; i++) {
            address curDodoPair = crosspolyPairs[i];
            if (directions[i] == 0) {
                returnAmount = ICrosspolyV1(curDodoPair).querySellBaseToken(returnAmount);
            } else {
                returnAmount = ICrosspolySellHelper(_Crosspoly_SELL_HELPER_).querySellQuoteToken(
                    curDodoPair,
                    returnAmount
                );
            }
            midPrices[i] = ICrosspolyV1(curDodoPair).getMidPrice();
            feeRates[i] = ICrosspolyV1(curDodoPair)._MT_FEE_RATE_() + ICrosspolyV1(curDodoPair)._LP_FEE_RATE_();
        }        
    }
}