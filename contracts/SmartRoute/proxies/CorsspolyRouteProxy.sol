/*

    Copyright 2021 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {ICrosspolyApproveProxy} from "../CrosspolyApproveProxy.sol";
import {IERC20} from "../../intf/IERC20.sol";
import {IWETH} from "../../intf/IWETH.sol";
import {SafeMath} from "../../lib/SafeMath.sol";
import {UniversalERC20} from "../lib/UniversalERC20.sol";
import {SafeERC20} from "../../lib/SafeERC20.sol";
import {ICrosspolyAdapter} from "../intf/ICrosspolyAdapter.sol";


/**
 * @title CrosspolyRouteProxy
 * @author Crosspoly Breeder
 *
 * @notice Entrance of Split trading in Crosspoly platform
 */
contract CrosspolyRouteProxy {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    // ============ Storage ============

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _WETH_;
    address public immutable _Crosspoly_APPROVE_PROXY_;

    struct PoolInfo {
        uint256 direction;
        uint256 poolEdition;
        uint256 weight;
        address pool;
        address adapter;
        bytes moreInfo;
    }

    // ============ Events ============

     event OrderHistory(
        address fromToken,
        address toToken,
        address sender,
        uint256 fromAmount,
        uint256 returnAmount
    );

    // ============ Modifiers ============

    modifier judgeExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "CrosspolyRouteProxy: EXPIRED");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    constructor (
        address payable weth,
        address crosspolyApproveProxy
    ) public {
        _WETH_ = weth;
        _Crosspoly_APPROVE_PROXY_ = crosspolyApproveProxy;
    }

    function mixSwap(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory mixAdapters,
        address[] memory mixPairs,
        address[] memory assetTo,
        uint256 directions,
        bytes[] memory moreInfos,
        uint256 deadLine
    ) external payable judgeExpired(deadLine) returns (uint256 returnAmount) {
        require(mixPairs.length > 0, "CrosspolyRouteProxy: PAIRS_EMPTY");
        require(mixPairs.length == mixAdapters.length, "CrosspolyRouteProxy: PAIR_ADAPTER_NOT_MATCH");
        require(mixPairs.length == assetTo.length - 1, "CrosspolyRouteProxy: PAIR_ASSETTO_NOT_MATCH");
        require(minReturnAmount > 0, "CrosspolyRouteProxy: RETURN_AMOUNT_ZERO");

        address _fromToken = fromToken;
        address _toToken = toToken;
        uint256 _fromTokenAmount = fromTokenAmount;
        
        uint256 toTokenOriginBalance = IERC20(_toToken).universalBalanceOf(msg.sender);
        
        _deposit(msg.sender, assetTo[0], _fromToken, _fromTokenAmount, _fromToken == _ETH_ADDRESS_);

        for (uint256 i = 0; i < mixPairs.length; i++) {
            if (directions & 1 == 0) {
                ICrosspolyAdapter(mixAdapters[i]).sellBase(assetTo[i + 1],mixPairs[i], moreInfos[i]);
            } else {
                ICrosspolyAdapter(mixAdapters[i]).sellQuote(assetTo[i + 1],mixPairs[i], moreInfos[i]);
            }
            directions = directions >> 1;
        }

        if(_toToken == _ETH_ADDRESS_) {
            returnAmount = IWETH(_WETH_).balanceOf(address(this));
            IWETH(_WETH_).withdraw(returnAmount);
            msg.sender.transfer(returnAmount);
        }else {
            returnAmount = IERC20(_toToken).tokenBalanceOf(msg.sender).sub(toTokenOriginBalance);
        }

        require(returnAmount >= minReturnAmount, "CrosspolyRouteProxy: Return amount is not enough");

        emit OrderHistory(
            _fromToken,
            _toToken,
            msg.sender,
            _fromTokenAmount,
            returnAmount
        );
    }

    function crosspolyMutliSwap(
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        uint256[] memory totalWeight,
        uint256[] memory splitNumber,
        address[] memory midToken,
        address[] memory assetFrom,
        bytes[] memory sequence,
        uint256 deadLine
    ) external payable judgeExpired(deadLine) returns (uint256 returnAmount) {
        require(assetFrom.length == splitNumber.length, 'CrosspolyRouteProxy: PAIR_ASSETTO_NOT_MATCH');        
        require(minReturnAmount > 0, "CrosspolyRouteProxy: RETURN_AMOUNT_ZERO");
        
        uint256 _fromTokenAmount = fromTokenAmount;
        address fromToken = midToken[0];
        address toToken = midToken[midToken.length - 1];

        uint256 toTokenOriginBalance = IERC20(toToken).universalBalanceOf(msg.sender);
        _deposit(msg.sender, assetFrom[0], fromToken, _fromTokenAmount, fromToken == _ETH_ADDRESS_);

        _multiSwap(totalWeight, midToken, splitNumber, sequence, assetFrom);
    
        if(toToken == _ETH_ADDRESS_) {
            returnAmount = IWETH(_WETH_).balanceOf(address(this));
            IWETH(_WETH_).withdraw(returnAmount);
            msg.sender.transfer(returnAmount);
        }else {
            returnAmount = IERC20(toToken).tokenBalanceOf(msg.sender).sub(toTokenOriginBalance);
        }

        require(returnAmount >= minReturnAmount, "CrosspolyRouteProxy: Return amount is not enough");
    
        emit OrderHistory(
            fromToken,
            toToken,
            msg.sender,
            _fromTokenAmount,
            returnAmount
        );    
    }

    
    //====================== internal =======================

    function _multiSwap(
        uint256[] memory totalWeight,
        address[] memory midToken,
        uint256[] memory splitNumber,
        bytes[] memory swapSequence,
        address[] memory assetFrom
    ) internal { 
        for(uint256 i = 1; i < splitNumber.length; i++) { 
            // define midtoken address, ETH -> WETH address
            uint256 curTotalAmount = IERC20(midToken[i]).tokenBalanceOf(assetFrom[i-1]);
            uint256 curTotalWeight = totalWeight[i-1];
            
            for(uint256 j = splitNumber[i-1]; j < splitNumber[i]; j++) {
                PoolInfo memory curPoolInfo;
                {
                    (address pool, address adapter, uint256 mixPara, bytes memory moreInfo) = abi.decode(swapSequence[j], (address, address, uint256, bytes));
                
                    curPoolInfo.direction = mixPara >> 17;
                    curPoolInfo.weight = (0xffff & mixPara) >> 9;
                    curPoolInfo.poolEdition = (0xff & mixPara);
                    curPoolInfo.pool = pool;
                    curPoolInfo.adapter = adapter;
                    curPoolInfo.moreInfo = moreInfo;
                }

                if(assetFrom[i-1] == address(this)) {
                    uint256 curAmount = curTotalAmount.div(curTotalWeight).mul(curPoolInfo.weight);
                    //can improved
                    // uint256 curAmount = curTotalAmount.mul(curPoolInfo.weight).div(curTotalWeight);
            
                    if(curPoolInfo.poolEdition == 1) {   
                        //For using transferFrom pool (like crosspolyV1, Curve)
                        IERC20(midToken[i]).transfer(curPoolInfo.adapter, curAmount);
                    } else {
                        //For using transfer pool (like crosspolyV2)
                        IERC20(midToken[i]).transfer(curPoolInfo.pool, curAmount);
                    }
                }
                
                if(curPoolInfo.direction == 0) {
                    ICrosspolyAdapter(curPoolInfo.adapter).sellBase(assetFrom[i], curPoolInfo.pool, curPoolInfo.moreInfo);
                } else {
                    ICrosspolyAdapter(curPoolInfo.adapter).sellQuote(assetFrom[i], curPoolInfo.pool, curPoolInfo.moreInfo);
                }
            }
        }
    }

    function _deposit(
        address from,
        address to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {
        if (isETH) {
            if (amount > 0) {
                IWETH(_WETH_).deposit{value: amount}();
                if (to != address(this)) SafeERC20.safeTransfer(IERC20(_WETH_), to, amount);
            }
        } else {
            ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).claimTokens(token, from, to, amount);
        }
    }
}