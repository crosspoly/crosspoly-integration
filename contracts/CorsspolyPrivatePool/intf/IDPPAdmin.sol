/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

interface IDPPAdmin {
    function init(address owner, address dpp,address operator, address crosspolySmartApprove) external;
}