/*

    Copyright 2021 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

import {SafeERC20} from "../../lib/SafeERC20.sol";
import {IERC20} from "../../intf/IERC20.sol";
import {SafeMath} from "../../lib/SafeMath.sol";
import {BaseMine} from "./BaseMine.sol";

interface IVCrosspolyToken {
    function availableBalanceOf(address account) external view returns (uint256);
}

contract vCrosspolyMine is BaseMine {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // ============ Storage ============
    address public _vCrosspoly_TOKEN_;

    function init(address owner, address vCrosspolyToken) external {
        super.initOwner(owner);
        _vCrosspoly_TOKEN_ = vCrosspolyToken;
    }

    // ============ Event =============

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event SyncBalance();

    // ============ Deposit && Withdraw && Exit ============

    function deposit(uint256 amount) external {
        require(amount > 0, "CrosspolyMineV2: CANNOT_DEPOSIT_ZERO");
        require(
            amount <= IVCrosspolyToken(_vCrosspoly_TOKEN_).availableBalanceOf(msg.sender),
            "CrosspolyMineV2: vCrosspoly_NOT_ENOUGH"
        );
        _updateAllReward(msg.sender);
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "CrosspolyMineV2: CANNOT_WITHDRAW_ZERO");
        require(amount <= _balances[msg.sender], "CrosspolyMineV2: WITHDRAW_BALANCE_NOT_ENOUGH");
        _updateAllReward(msg.sender);
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit Withdraw(msg.sender, amount);
    }

    function syncBalance(address[] calldata userList) external {
        for (uint256 i = 0; i < userList.length; ++i) {
            address user = userList[i];
            uint256 curBalance = balanceOf(user);
            uint256 vCrosspolyBalance = IERC20(_vCrosspoly_TOKEN_).balanceOf(user);
            if (curBalance > vCrosspolyBalance) {
                _updateAllReward(user);
                _totalSupply = _totalSupply.add(vCrosspolyBalance).sub(curBalance);
                _balances[user] = vCrosspolyBalance;
            }
        }
        emit SyncBalance();
    }

    // ============ View  ============

    function getLockedvCrosspoly(address account) external view returns (uint256) {
        return balanceOf(account);
    }
}
