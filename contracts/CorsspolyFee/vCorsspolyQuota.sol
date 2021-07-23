/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

import {InitializableOwnable} from "../lib/InitializableOwnable.sol";
import {IERC20} from "../intf/IERC20.sol";
import {SafeMath} from "../lib/SafeMath.sol";


contract vCrosspolyQuota is InitializableOwnable {
    using SafeMath for uint256;
    address public immutable _VCrosspoly_TOKEN_;
    uint256 public _QUOTA_RATIO_;
    uint256 public _BASE_QUOTA_;

    constructor(address vcrosspolyToken) public {
        _VCrosspoly_TOKEN_ = vcrosspolyToken;
    }

    function setParams(uint256 quotaRatio, uint256 baseQuota) external onlyOwner {
        _QUOTA_RATIO_ = quotaRatio;
        _BASE_QUOTA_ = baseQuota;
    }

    function getUserQuota(address user) external view returns (int) {
        uint256 vCrosspolyAmount = IERC20(_VCrosspoly_TOKEN_).balanceOf(user);
        return int(vCrosspolyAmount.div(_QUOTA_RATIO_).add(_BASE_QUOTA_));
    }
}
