/*

    Copyright 2021 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {IDPPOracle} from "../../intf/IDPPOracle.sol";
import {ICrosspolyApproveProxy} from "../../../SmartRoute/CrosspolyApproveProxy.sol";
import {InitializableOwnable} from "../../../lib/InitializableOwnable.sol";

/**
 * @title DPPOracleAdmin
 * @author Crosspoly Breeder
 *
 * @notice Admin of Oracle CrosspolyPrivatePool
 */
contract DPPOracleAdmin is InitializableOwnable {
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
        IDPPOracle(_DPP_).ratioSync();
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
        IDPPOracle(_DPP_).retrieve(to, token, amount);
    }

    function tuneParameters(
        address operator,
        uint256 newLpFeeRate,
        uint256 newK,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external notFreezed returns (bool) {
        require(
            msg.sender == _OWNER_ ||
                (ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).isAllowedProxy(msg.sender) &&
                    operator == _OPERATOR_),
            "TUNEPARAMS FORBIDDEN!"
        );
        return
            IDPPOracle(_DPP_).tuneParameters(
                newLpFeeRate,
                newK,
                minBaseReserve,
                minQuoteReserve
            );
    }


    function reset(
        address operator,
        uint256 newLpFeeRate,
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
            IDPPOracle(_DPP_).reset(
                _OWNER_, //only support asset transfer out to owner
                newLpFeeRate,
                newK,
                baseOutAmount,
                quoteOutAmount,
                minBaseReserve,
                minQuoteReserve
            );
    }

    // ============ Admin Version Control ============

    function version() external pure returns (string memory) {
        return "DPPOracle Admin 1.0.0"; // 1.0.0
    }
}
