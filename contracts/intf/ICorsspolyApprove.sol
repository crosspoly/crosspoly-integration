/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

interface ICrosspolyApprove {
    function claimTokens(address token,address who,address dest,uint256 amount) external;
    function getCrosspolyProxy() external view returns (address);
}
