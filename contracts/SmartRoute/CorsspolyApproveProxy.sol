/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {ICrosspolyApprove} from "../intf/ICrosspolyApprove.sol";
import {InitializableOwnable} from "../lib/InitializableOwnable.sol";

interface ICrosspolyApproveProxy {
    function isAllowedProxy(address _proxy) external view returns (bool);
    function claimTokens(address token,address who,address dest,uint256 amount) external;
}

/**
 * @title CrosspolyApproveProxy
 * @author Crosspoly Breeder
 *
 * @notice Allow different version crosspolyproxy to claim from CrosspolyApprove
 */
contract CrosspolyApproveProxy is InitializableOwnable {
    
    // ============ Storage ============
    uint256 private constant _TIMELOCK_DURATION_ = 3 days;
    mapping (address => bool) public _IS_ALLOWED_PROXY_;
    uint256 public _TIMELOCK_;
    address public _PENDING_ADD_Crosspoly_PROXY_;
    address public immutable _Crosspoly_APPROVE_;

    // ============ Modifiers ============
    modifier notLocked() {
        require(
            _TIMELOCK_ <= block.timestamp,
            "SetProxy is timelocked"
        );
        _;
    }

    constructor(address crosspolyApporve) public {
        _Crosspoly_APPROVE_ = crosspolyApporve;
    }

    function init(address owner, address[] memory proxies) external {
        initOwner(owner);
        for(uint i = 0; i < proxies.length; i++) 
            _IS_ALLOWED_PROXY_[proxies[i]] = true;
    }

    function unlockAddProxy(address newDodoProxy) public onlyOwner {
        _TIMELOCK_ = block.timestamp + _TIMELOCK_DURATION_;
        _PENDING_ADD_Crosspoly_PROXY_ = newDodoProxy;
    }

    function lockAddProxy() public onlyOwner {
       _PENDING_ADD_Crosspoly_PROXY_ = address(0);
       _TIMELOCK_ = 0;
    }


    function addCrosspolyProxy() external onlyOwner notLocked() {
        _IS_ALLOWED_PROXY_[_PENDING_ADD_Crosspoly_PROXY_] = true;
        lockAddProxy();
    }

    function removeCrosspolyProxy (address oldDodoProxy) public onlyOwner {
        _IS_ALLOWED_PROXY_[oldDodoProxy] = false;
    }
    
    function claimTokens(
        address token,
        address who,
        address dest,
        uint256 amount
    ) external {
        require(_IS_ALLOWED_PROXY_[msg.sender], "CrosspolyApproveProxy:Access restricted");
        ICrosspolyApprove(_Crosspoly_APPROVE_).claimTokens(
            token,
            who,
            dest,
            amount
        );
    }

    function isAllowedProxy(address _proxy) external view returns (bool) {
        return _IS_ALLOWED_PROXY_[_proxy];
    }
}
