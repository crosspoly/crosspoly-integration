/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity ^0.6.9;

import {SafeERC20} from "../lib/SafeERC20.sol";
import {IERC20} from "../intf/IERC20.sol";
import {InitializableOwnable} from "../lib/InitializableOwnable.sol";
import {ICrosspolyApproveProxy} from "../SmartRoute/CrosspolyApproveProxy.sol";


contract CrosspolyRecharge is InitializableOwnable {
    using SafeERC20 for IERC20;

    address public immutable _Crosspoly_TOKEN_;
    address public immutable _Crosspoly_APPROVE_PROXY_;

    event DeductCrosspoly(address user,uint256 _amount);
    
    constructor(address crosspolyAddress, address crosspolyApproveProxy) public {
        _Crosspoly_TOKEN_ = crosspolyAddress;
        _Crosspoly_APPROVE_PROXY_ = crosspolyApproveProxy;
    }

    function deductionCrosspoly(uint256 amount) external {
        ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).claimTokens(_Crosspoly_TOKEN_, msg.sender, address(this), amount);
        emit DeductCrosspoly(msg.sender, amount);
    }

    // ============ Owner Functions ============
    function claimToken(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance>0,"no enough token can claim");
        IERC20(token).safeTransfer(_OWNER_, balance);
    }
}