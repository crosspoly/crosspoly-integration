/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {ICrosspolyV1} from "../intf/ICrosspolyV1.sol";

contract CrosspolyV1PmmHelper {
    
    struct PairDetail {
        uint256 i;
        uint256 K;
        uint256 B;
        uint256 Q;
        uint256 B0;
        uint256 Q0;
        uint256 R;
        uint256 lpFeeRate;
        uint256 mtFeeRate;
        address baseToken;
        address quoteToken;
        address curPair;
        uint256 pairVersion;
    }

    function getPairDetail(address pool) external view returns (PairDetail[] memory res) {
        res = new PairDetail[](1);
        PairDetail memory curRes = PairDetail(0,0,0,0,0,0,0,0,0,address(0),address(0),pool,1);
        curRes.i = ICrosspolyV1(pool).getOraclePrice();
        curRes.K = ICrosspolyV1(pool)._K_();
        curRes.B = ICrosspolyV1(pool)._BASE_BALANCE_();
        curRes.Q = ICrosspolyV1(pool)._QUOTE_BALANCE_();
        (curRes.B0,curRes.Q0) = ICrosspolyV1(pool).getExpectedTarget();
        curRes.R = ICrosspolyV1(pool)._R_STATUS_();
        curRes.lpFeeRate = ICrosspolyV1(pool)._LP_FEE_RATE_();
        curRes.mtFeeRate = ICrosspolyV1(pool)._MT_FEE_RATE_();
        curRes.baseToken = ICrosspolyV1(pool)._BASE_TOKEN_();
        curRes.quoteToken =  ICrosspolyV1(pool)._QUOTE_TOKEN_();
        res[0] = curRes;
    }
}