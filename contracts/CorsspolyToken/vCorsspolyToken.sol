/*
    Copyright 2020 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0
*/
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import {IERC20} from "../intf/IERC20.sol";
import {SafeMath} from "../lib/SafeMath.sol";
import {DecimalMath} from "../lib/DecimalMath.sol";
import {InitializableOwnable} from "../lib/InitializableOwnable.sol";
import {SafeERC20} from "../lib/SafeERC20.sol";
import {ICrosspolyApproveProxy} from "../SmartRoute/CrosspolyApproveProxy.sol";

interface IGovernance {
    function getLockedvCrosspoly(address account) external view returns (uint256);
}

interface ICrosspolyCirculationHelper {
    // Locked vDOOD not counted in circulation
    function getCirculation() external view returns (uint256);

    function getDodoWithdrawFeeRatio() external view returns (uint256);
}

contract vCrosspolyToken is InitializableOwnable {
    using SafeMath for uint256;

    // ============ Storage(ERC20) ============

    string public name = "vCrosspoly Membership Token";
    string public symbol = "vCrosspoly";
    uint8 public decimals = 18;
    mapping(address => mapping(address => uint256)) internal _ALLOWED_;

    // ============ Storage ============

    address public immutable _Crosspoly_TOKEN_;
    address public immutable _Crosspoly_APPROVE_PROXY_;
    address public immutable _Crosspoly_TEAM_;
    address public _DOOD_GOV_;
    address public _Crosspoly_CIRCULATION_HELPER_;

    bool public _CAN_TRANSFER_;

    // staking reward parameters
    uint256 public _Crosspoly_PER_BLOCK_;
    uint256 public constant _SUPERIOR_RATIO_ = 10**17; // 0.1
    uint256 public constant _Crosspoly_RATIO_ = 100; // 100
    uint256 public _Crosspoly_FEE_BURN_RATIO_;

    // accounting
    uint112 public alpha = 10**18; // 1
    uint112 public _TOTAL_BLOCK_DISTRIBUTION_;
    uint32 public _LAST_REWARD_BLOCK_;

    uint256 public _TOTAL_BLOCK_REWARD_;
    uint256 public _TOTAL_STAKING_POWER_;
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint128 stakingPower;
        uint128 superiorSP;
        address superior;
        uint256 credit;
    }

    // ============ Events ============

    event MintVCrosspoly(address user, address superior, uint256 mintCrosspoly);
    event RedeemVCrosspoly(address user, uint256 receiveCrosspoly, uint256 burnCrosspoly, uint256 feeCrosspoly);
    event DonateCrosspoly(address user, uint256 donateCrosspoly);
    event SetCantransfer(bool allowed);

    event PreDeposit(uint256 crosspolyAmount);
    event ChangePerReward(uint256 crosspolyPerBlock);
    event UpdateCrosspolyFeeBurnRatio(uint256 crosspolyFeeBurnRatio);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // ============ Modifiers ============

    modifier canTransfer() {
        require(_CAN_TRANSFER_, "vCrosspolyToken: not allowed transfer");
        _;
    }

    modifier balanceEnough(address account, uint256 amount) {
        require(availableBalanceOf(account) >= amount, "vCrosspolyToken: available amount not enough");
        _;
    }

    // ============ Constructor ============

    constructor(
        address crosspolyGov,
        address crosspolyToken,
        address crosspolyApproveProxy,
        address crosspolyTeam
    ) public {
        _DOOD_GOV_ = crosspolyGov;
        _Crosspoly_TOKEN_ = crosspolyToken;
        _Crosspoly_APPROVE_PROXY_ = crosspolyApproveProxy;
        _Crosspoly_TEAM_ = crosspolyTeam;
    }

    // ============ Ownable Functions ============`

    function setCantransfer(bool allowed) public onlyOwner {
        _CAN_TRANSFER_ = allowed;
        emit SetCantransfer(allowed);
    }

    function changePerReward(uint256 crosspolyPerBlock) public onlyOwner {
        _updateAlpha();
        _Crosspoly_PER_BLOCK_ = crosspolyPerBlock;
        emit ChangePerReward(crosspolyPerBlock);
    }

    function updateCrosspolyFeeBurnRatio(uint256 crosspolyFeeBurnRatio) public onlyOwner {
        _Crosspoly_FEE_BURN_RATIO_ = crosspolyFeeBurnRatio;
        emit UpdateCrosspolyFeeBurnRatio(_Crosspoly_FEE_BURN_RATIO_);
    }

    function updateCrosspolyCirculationHelper(address helper) public onlyOwner {
        _Crosspoly_CIRCULATION_HELPER_ = helper;
    }

    function updateGovernance(address governance) public onlyOwner {
        _DOOD_GOV_ = governance;
    }

    function emergencyWithdraw() public onlyOwner {
        uint256 crosspolyBalance = IERC20(_Crosspoly_TOKEN_).balanceOf(address(this));
        IERC20(_Crosspoly_TOKEN_).transfer(_OWNER_, crosspolyBalance);
    }

    // ============ Mint & Redeem & Donate ============

    function mint(uint256 crosspolyAmount, address superiorAddress) public {
        require(
            superiorAddress != address(0) && superiorAddress != msg.sender,
            "vCrosspolyToken: Superior INVALID"
        );
        require(crosspolyAmount > 0, "vCrosspolyToken: must mint greater than 0");

        UserInfo storage user = userInfo[msg.sender];

        if (user.superior == address(0)) {
            require(
                superiorAddress == _Crosspoly_TEAM_ || userInfo[superiorAddress].superior != address(0),
                "vCrosspolyToken: INVALID_SUPERIOR_ADDRESS"
            );
            user.superior = superiorAddress;
        }

        _updateAlpha();

        ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).claimTokens(
            _Crosspoly_TOKEN_,
            msg.sender,
            address(this),
            crosspolyAmount
        );

        uint256 newStakingPower = DecimalMath.divFloor(crosspolyAmount, alpha);

        _mint(user, newStakingPower);

        emit MintVCrosspoly(msg.sender, superiorAddress, crosspolyAmount);
    }

    function redeem(uint256 vcrosspolyAmount, bool all) public balanceEnough(msg.sender, vcrosspolyAmount) {
        _updateAlpha();
        UserInfo storage user = userInfo[msg.sender];

        uint256 crosspolyAmount;
        uint256 stakingPower;

        if (all) {
            stakingPower = uint256(user.stakingPower).sub(DecimalMath.divFloor(user.credit, alpha));
            crosspolyAmount = DecimalMath.mulFloor(stakingPower, alpha);
        } else {
            crosspolyAmount = vcrosspolyAmount.mul(_Crosspoly_RATIO_);
            stakingPower = DecimalMath.divFloor(crosspolyAmount, alpha);
        }

        _redeem(user, stakingPower);

        (uint256 crosspolyReceive, uint256 burnDodoAmount, uint256 withdrawFeeDodoAmount) = getWithdrawResult(crosspolyAmount);

        IERC20(_Crosspoly_TOKEN_).transfer(msg.sender, crosspolyReceive);
        
        if (burnDodoAmount > 0) {
            IERC20(_Crosspoly_TOKEN_).transfer(address(0), burnDodoAmount);
        }
        
        if (withdrawFeeDodoAmount > 0) {
            alpha = uint112(
                uint256(alpha).add(
                    DecimalMath.divFloor(withdrawFeeDodoAmount, _TOTAL_STAKING_POWER_)
                )
            );
        }

        emit RedeemVCrosspoly(msg.sender, crosspolyReceive, burnDodoAmount, withdrawFeeDodoAmount);
    }

    function donate(uint256 crosspolyAmount) public {
        ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).claimTokens(
            _Crosspoly_TOKEN_,
            msg.sender,
            address(this),
            crosspolyAmount
        );
        alpha = uint112(
            uint256(alpha).add(DecimalMath.divFloor(crosspolyAmount, _TOTAL_STAKING_POWER_))
        );
        emit DonateCrosspoly(msg.sender, crosspolyAmount);
    }

    function preDepositedBlockReward(uint256 crosspolyAmount) public {
        ICrosspolyApproveProxy(_Crosspoly_APPROVE_PROXY_).claimTokens(
            _Crosspoly_TOKEN_,
            msg.sender,
            address(this),
            crosspolyAmount
        );
        _TOTAL_BLOCK_REWARD_ = _TOTAL_BLOCK_REWARD_.add(crosspolyAmount);
        emit PreDeposit(crosspolyAmount);
    }

    // ============ ERC20 Functions ============

    function totalSupply() public view returns (uint256 vCrosspolySupply) {
        uint256 totalCrosspoly = IERC20(_Crosspoly_TOKEN_).balanceOf(address(this));
        (,uint256 curDistribution) = getLatestAlpha();
        uint256 actualCrosspoly = totalCrosspoly.sub(_TOTAL_BLOCK_REWARD_.sub(curDistribution.add(_TOTAL_BLOCK_DISTRIBUTION_)));
        vCrosspolySupply = actualCrosspoly / _Crosspoly_RATIO_;
    }
    
    function balanceOf(address account) public view returns (uint256 vCrosspolyAmount) {
        vCrosspolyAmount = crosspolyBalanceOf(account) / _Crosspoly_RATIO_;
    }

    function transfer(address to, uint256 vCrosspolyAmount) public returns (bool) {
        _updateAlpha();
        _transfer(msg.sender, to, vCrosspolyAmount);
        return true;
    }

    function approve(address spender, uint256 vCrosspolyAmount) canTransfer public returns (bool) {
        _ALLOWED_[msg.sender][spender] = vCrosspolyAmount;
        emit Approval(msg.sender, spender, vCrosspolyAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 vCrosspolyAmount
    ) public returns (bool) {
        require(vCrosspolyAmount <= _ALLOWED_[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");
        _updateAlpha();
        _transfer(from, to, vCrosspolyAmount);
        _ALLOWED_[from][msg.sender] = _ALLOWED_[from][msg.sender].sub(vCrosspolyAmount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _ALLOWED_[owner][spender];
    }

    // ============ Helper Functions ============

    function getLatestAlpha() public view returns (uint256 newAlpha, uint256 curDistribution) {
        if (_LAST_REWARD_BLOCK_ == 0) {
            curDistribution = 0;
        } else {
            curDistribution = _Crosspoly_PER_BLOCK_ * (block.number - _LAST_REWARD_BLOCK_);
        }
        if (_TOTAL_STAKING_POWER_ > 0) {
            newAlpha = uint256(alpha).add(DecimalMath.divFloor(curDistribution, _TOTAL_STAKING_POWER_));
        } else {
            newAlpha = alpha;
        }
    }

    function availableBalanceOf(address account) public view returns (uint256 vCrosspolyAmount) {
        if (_DOOD_GOV_ == address(0)) {
            vCrosspolyAmount = balanceOf(account);
        } else {
            uint256 lockedvCrosspolyAmount = IGovernance(_DOOD_GOV_).getLockedvCrosspoly(account);
            vCrosspolyAmount = balanceOf(account).sub(lockedvCrosspolyAmount);
        }
    }

    function crosspolyBalanceOf(address account) public view returns (uint256 crosspolyAmount) {
        UserInfo memory user = userInfo[account];
        (uint256 newAlpha,) = getLatestAlpha();
        uint256 nominalDodo =  DecimalMath.mulFloor(uint256(user.stakingPower), newAlpha);
        if(nominalDodo > user.credit) {
            crosspolyAmount = nominalDodo - user.credit;
        }else {
            crosspolyAmount = 0;
        }
    }

    function getWithdrawResult(uint256 crosspolyAmount)
        public
        view
        returns (
            uint256 crosspolyReceive,
            uint256 burnDodoAmount,
            uint256 withdrawFeeDodoAmount
        )
    {
        uint256 feeRatio =
            ICrosspolyCirculationHelper(_Crosspoly_CIRCULATION_HELPER_).getDodoWithdrawFeeRatio();

        withdrawFeeDodoAmount = DecimalMath.mulFloor(crosspolyAmount, feeRatio);
        crosspolyReceive = crosspolyAmount.sub(withdrawFeeDodoAmount);

        burnDodoAmount = DecimalMath.mulFloor(withdrawFeeDodoAmount, _Crosspoly_FEE_BURN_RATIO_);
        withdrawFeeDodoAmount = withdrawFeeDodoAmount.sub(burnDodoAmount);
    }

    function getCrosspolyWithdrawFeeRatio() public view returns (uint256 feeRatio) {
        feeRatio = ICrosspolyCirculationHelper(_Crosspoly_CIRCULATION_HELPER_).getDodoWithdrawFeeRatio();
    }

    function getSuperior(address account) public view returns (address superior) {
        return userInfo[account].superior;
    }

    // ============ Internal Functions ============

    function _updateAlpha() internal {
        (uint256 newAlpha, uint256 curDistribution) = getLatestAlpha();
        uint256 newTotalDistribution = curDistribution.add(_TOTAL_BLOCK_DISTRIBUTION_);
        require(newAlpha <= uint112(-1) && newTotalDistribution <= uint112(-1), "OVERFLOW");
        alpha = uint112(newAlpha);
        _TOTAL_BLOCK_DISTRIBUTION_ = uint112(newTotalDistribution);
        _LAST_REWARD_BLOCK_ = uint32(block.number);
    }

    function _mint(UserInfo storage to, uint256 stakingPower) internal {
        require(stakingPower <= uint128(-1), "OVERFLOW");
        UserInfo storage superior = userInfo[to.superior];
        uint256 superiorIncreSP = DecimalMath.mulFloor(stakingPower, _SUPERIOR_RATIO_);
        uint256 superiorIncreCredit = DecimalMath.mulFloor(superiorIncreSP, alpha);

        to.stakingPower = uint128(uint256(to.stakingPower).add(stakingPower));
        to.superiorSP = uint128(uint256(to.superiorSP).add(superiorIncreSP));

        superior.stakingPower = uint128(uint256(superior.stakingPower).add(superiorIncreSP));
        superior.credit = uint128(uint256(superior.credit).add(superiorIncreCredit));

        _TOTAL_STAKING_POWER_ = _TOTAL_STAKING_POWER_.add(stakingPower).add(superiorIncreSP);
    }

    function _redeem(UserInfo storage from, uint256 stakingPower) internal {
        from.stakingPower = uint128(uint256(from.stakingPower).sub(stakingPower));

        // superior decrease sp = min(stakingPower*0.1, from.superiorSP)
        uint256 superiorDecreSP = DecimalMath.mulFloor(stakingPower, _SUPERIOR_RATIO_);
        superiorDecreSP = from.superiorSP <= superiorDecreSP ? from.superiorSP : superiorDecreSP;
        from.superiorSP = uint128(uint256(from.superiorSP).sub(superiorDecreSP));

        UserInfo storage superior = userInfo[from.superior];
        uint256 creditSP = DecimalMath.divFloor(superior.credit, alpha);

        if (superiorDecreSP >= creditSP) {
            superior.credit = 0;
            superior.stakingPower = uint128(uint256(superior.stakingPower).sub(creditSP));
        } else {
            superior.credit = uint128(
                uint256(superior.credit).sub(DecimalMath.mulFloor(superiorDecreSP, alpha))
            );
            superior.stakingPower = uint128(uint256(superior.stakingPower).sub(superiorDecreSP));
        }

        _TOTAL_STAKING_POWER_ = _TOTAL_STAKING_POWER_.sub(stakingPower).sub(superiorDecreSP);
    }

    function _transfer(
        address from,
        address to,
        uint256 vCrosspolyAmount
    ) internal canTransfer balanceEnough(from, vCrosspolyAmount) {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(from != to, "transfer from same with to");

        uint256 stakingPower = DecimalMath.divFloor(vCrosspolyAmount * _Crosspoly_RATIO_, alpha);

        UserInfo storage fromUser = userInfo[from];
        UserInfo storage toUser = userInfo[to];

        _redeem(fromUser, stakingPower);
        _mint(toUser, stakingPower);

        emit Transfer(from, to, vCrosspolyAmount);
    }
}