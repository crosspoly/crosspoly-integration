/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

interface ICrosspolyAdapter {
    
    function sellBase(address to, address pool, bytes memory data) external;

    function sellQuote(address to, address pool, bytes memory data) external;
}
