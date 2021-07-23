/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {IDPP} from "../intf/IDPP.sol";
import {ICrosspolyApproveProxy} from "../../SmartRoute/CrosspolyApproveProxy.sol";
import {InitializableOwnable} from "../../lib/InitializableOwnable.sol";

/**
 * @title DPPAdmin
 * @author Crosspoly Breeder
 *
 * @notice Admin of CrosspolyPrivatePool
 */
contract DPPAdmin is InitializableOwnable {
    address public _DPP_;
    address public _OPERATOR_;
    address public _Crosspoly_APPROVE_PROXY_;
    uint256 public _FREEZE_TIMESTAMP_;


    modifier notFreezed() {
        require(block.timestamp >= _FREEZE_TIMESTAMP_, "ADMIN_FREEZED");
        _;
    }

    function init(
        address owner,
        address dpp,
        address operator,
        address crosspolyApproveProxy
    ) external {
        initOwner(owner);
        _DPP_ = dpp;
        _OPERATOR_ = operator;
        _Crosspoly_APPROVE_PROXY_ = crosspolyApproveProxy;
    }

    function sync() external notFreezed onlyOwner {
        IDPP(_DPP_).ratioSync();
    }

    function setFreezeTimestamp(uint256 timestamp) external notFreezed onlyOwner {
        _FREEZE_TIMESTAMP_ = timestamp;
    }

    function setOperator(address newOperator) external notFreezed onlyOwner {
        _OPERATOR_ = newOperator;
    }

    function retrieve(
        address payable to,
        address token,
        uint256 amount
    ) external notFreezed onlyOwner {
        IDPP(_DPP_).retrieve(to, token, amount);
    }

    function reset(
        address operator,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external notFreezed returns (bool) {
        require(
            msg.sender == _OWNER_ ||
                (ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).isAllowedProxy(msg.sender) &&
                    operator == _OPERATOR_),
            "RESET FORBIDDEN！"
        );
        return
            IDPP(_DPP_).reset(
                msg.sender,
                newLpFeeRate,
                newI,
                newK,
                baseOutAmount,
                quoteOutAmount,
                minBaseReserve,
                minQuoteReserve
            );
    }

    // ============ Admin Version Control ============

    function version() external pure returns (string memory) {
        return "DPPAdmin 1.0.0"; // 1.0.0
    }
}
