/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

import {InitializableOwnable} from "../lib/InitializableOwnable.sol";
import {SafeERC20} from "../lib/SafeERC20.sol";
import {SafeMath} from "../lib/SafeMath.sol";
import {IERC20} from "../intf/IERC20.sol";

interface ICrosspolyIncentive {
    function triggerIncentive(
        address fromToken,
        address toToken,
        address assetTo
    ) external;
}

/**
 * @title CrosspolyIncentive
 * @author Crosspoly Breeder
 *
 * @notice Trade Incentive in Crosspoly platform
 */
contract CrosspolyIncentive is InitializableOwnable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage ============
    address public immutable _Crosspoly_TOKEN_;
    address public _Crosspoly_PROXY_;
    uint256 public crosspolyPerBlock;
    uint256 public defaultRate = 10;
    mapping(address => uint256) public boosts;

    uint32 public lastRewardBlock;
    uint112 public totalReward;
    uint112 public totalDistribution;

    // ============ Events ============

    event SetBoost(address token, uint256 boostRate);
    event SetNewProxy(address crosspolyProxy);
    event SetPerReward(uint256 crosspolyPerBlock);
    event SetDefaultRate(uint256 defaultRate);
    event Incentive(address user, uint256 reward);

    constructor(address _crosspolyToken) public {
        _Crosspoly_TOKEN_ = _crosspolyToken;
    }

    // ============ Ownable ============

    function changeBoost(address _token, uint256 _boostRate) public onlyOwner {
        require(_token != address(0));
        require(_boostRate + defaultRate <= 1000);
        boosts[_token] = _boostRate;
        emit SetBoost(_token, _boostRate);
    }

    function changePerReward(uint256 _crosspolyPerBlock) public onlyOwner {
        _updateTotalReward();
        crosspolyPerBlock = _crosspolyPerBlock;
        emit SetPerReward(crosspolyPerBlock);
    }

    function changeDefaultRate(uint256 _defaultRate) public onlyOwner {
        defaultRate = _defaultRate;
        emit SetDefaultRate(defaultRate);
    }

    function changeCrosspolyProxy(address _crosspolyProxy) public onlyOwner {
        _Crosspoly_PROXY_ = _crosspolyProxy;
        emit SetNewProxy(_Crosspoly_PROXY_);
    }

    function emptyReward(address assetTo) public onlyOwner {
        uint256 balance = IERC20(_Crosspoly_TOKEN_).balanceOf(address(this));
        IERC20(_Crosspoly_TOKEN_).transfer(assetTo, balance);
    }

    // ============ Incentive  function ============

    function triggerIncentive(
        address fromToken,
        address toToken,
        address assetTo
    ) external {
        require(msg.sender == _Crosspoly_PROXY_, "CrosspolyIncentive:Access restricted");

        uint256 curTotalDistribution = totalDistribution;
        uint256 fromRate = boosts[fromToken];
        uint256 toRate = boosts[toToken];
        uint256 rate = (fromRate >= toRate ? fromRate : toRate) + defaultRate;
        require(rate <= 1000, "RATE_INVALID");
        
        uint256 _totalReward = _getTotalReward();
        uint256 reward = ((_totalReward - curTotalDistribution) * rate) / 1000;
        uint256 _totalDistribution = curTotalDistribution + reward;

        _update(_totalReward, _totalDistribution);
        if (reward != 0) {
            IERC20(_Crosspoly_TOKEN_).transfer(assetTo, reward);
            emit Incentive(assetTo, reward);
        }
    }

    function _updateTotalReward() internal {
        uint256 _totalReward = _getTotalReward();
        require(_totalReward < uint112(-1), "OVERFLOW");
        totalReward = uint112(_totalReward);
        lastRewardBlock = uint32(block.number);
    }

    function _update(uint256 _totalReward, uint256 _totalDistribution) internal {
        require(
            _totalReward < uint112(-1) && _totalDistribution < uint112(-1) && block.number < uint32(-1),
            "OVERFLOW"
        );
        lastRewardBlock = uint32(block.number);
        totalReward = uint112(_totalReward);
        totalDistribution = uint112(_totalDistribution);
    }

    function _getTotalReward() internal view returns (uint256) {
        if (lastRewardBlock == 0) {
            return totalReward;
        } else {
            return totalReward + (block.number - lastRewardBlock) * crosspolyPerBlock;
        }
    }

    // ============= Helper function ===============

    function incentiveStatus(address fromToken, address toToken)
        external
        view
        returns (
            uint256 reward,
            uint256 baseRate,
            uint256 totalRate,
            uint256 curTotalReward,
            uint256 perBlockReward
        )
    {
        baseRate = defaultRate;
        uint256 fromRate = boosts[fromToken];
        uint256 toRate = boosts[toToken];
        totalRate = (fromRate >= toRate ? fromRate : toRate) + defaultRate;
        uint256 _totalReward = _getTotalReward();
        reward = ((_totalReward - totalDistribution) * totalRate) / 1000;
        curTotalReward = _totalReward - totalDistribution;
        perBlockReward = crosspolyPerBlock;
    }
}
