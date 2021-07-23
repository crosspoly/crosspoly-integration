/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

import {ICrosspolyV2} from "../intf/ICrosspolyV2.sol";
import {ICrosspolyAdapter} from "../intf/ICrosspolyAdapter.sol";

contract CrosspolyV2Adapter is ICrosspolyAdapter {
    function sellBase(address to, address pool, bytes memory) external override {
        ICrosspolyV2(pool).sellBase(to);
    }

    function sellQuote(address to, address pool, bytes memory) external override {
        ICrosspolyV2(pool).sellQuote(to);
    }
}