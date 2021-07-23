/*

    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/
pragma solidity 0.6.9;

import {InitializableOwnable} from "../lib/InitializableOwnable.sol";
import {SafeMath} from "../lib/SafeMath.sol";

interface IVCrosspolyMine {
    function balanceOf(address account) external view returns (uint256);
}

contract Governance is InitializableOwnable {
    using SafeMath for uint256;

    // ============ Storage ============
    address[] public _VCrosspoly_MINE_LIST_;


    // ============ Event =============
    event AddMineContract(address mineContract);
    event RemoveMineContract(address mineContract);


    function getLockedvCrosspoly(address account) external view returns (uint256 lockedvCrosspoly) {
        uint256 len = _VCrosspoly_MINE_LIST_.length;
        for(uint i = 0; i < len; i++){
            uint256 curLocked = IVCrosspolyMine(_VCrosspoly_MINE_LIST_[i]).balanceOf(account);
            lockedvCrosspoly = lockedvCrosspoly.add(curLocked);
        }
    }

    // =============== Ownable  ================

    function addMineContract(address[] memory mineContracts) external onlyOwner {
        for(uint i = 0; i < mineContracts.length; i++){
            require(mineContracts[i] != address(0),"ADDRESS_INVALID");
            _VCrosspoly_MINE_LIST_.push(mineContracts[i]);
            emit AddMineContract(mineContracts[i]);
        }
    }

    function removeMineContract(address mineContract) external onlyOwner {
        uint256 len = _VCrosspoly_MINE_LIST_.length;
        for (uint256 i = 0; i < len; i++) {
            if (mineContract == _VCrosspoly_MINE_LIST_[i]) {
                _VCrosspoly_MINE_LIST_[i] = _VCrosspoly_MINE_LIST_[len - 1];
                _VCrosspoly_MINE_LIST_.pop();
                emit RemoveMineContract(mineContract);
                break;
            }
        }
    }
}
