const fs = require("fs");
const { deploySwitch } = require('../truffle-config.js')
const file = fs.createWriteStream("../deploy-detail-periphery.txt", { 'flags': 'a' });
let logger = new console.Console(file, file);
const { GetConfig } = require("../configAdapter.js")

const CrosspolyRecharge = artifacts.require("CrosspolyRecharge");
const DvmTemplate = artifacts.require("DVM");
const CpTemplate = artifacts.require("CP");
const vCrosspolyToken = artifacts.require("vCrosspolyToken");
const CrosspolyCirculationHelper = artifacts.require("CrosspolyCirculationHelper");
const CrosspolyMine = artifacts.require("CrosspolyMine");
const FeeRateImpl = artifacts.require("FeeRateImpl");
const WETH9 = artifacts.require("WETH9");
const CrosspolyToken = artifacts.require("CrosspolyToken");
const UpCrowdPoolingFactory = artifacts.require("UpCrowdPoolingFactory");
const CpFactory = artifacts.require("CrowdPoolingFactory");
const MultiCall = artifacts.require("Multicall");
const LockedTokenVault = artifacts.require("LockedTokenVault");
const CrosspolyRouteProxy = artifacts.require("CrosspolyRouteProxy");
const CrosspolyCpProxy = artifacts.require("CrosspolyCpProxy");
const CrosspolyApproveProxy = artifacts.require("CrosspolyApproveProxy");

const DspTemplate = artifacts.require("DSP");
const DspFactory = artifacts.require("DSPFactory");
const CrosspolyDspProxy = artifacts.require("CrosspolyDspProxy");
const CrosspolyV2RouteHelper = artifacts.require("CrosspolyV2RouteHelper");

const ERC20Mine = artifacts.require("ERC20Mine");
const vCrosspolyMine = artifacts.require("vCrosspolyMine");
const ERC20V2Factory = artifacts.require("ERC20V2Factory");
const ERC20 = artifacts.require("InitializableERC20");
const CustomERC20 = artifacts.require("CustomERC20");

const ERC20MineV3 = artifacts.require("ERC20MineV3");
const CrosspolyMineV3Registry = artifacts.require("CrosspolyMineV3Registry");
const CrosspolyMineV3Proxy = artifacts.require("CrosspolyMineV3Proxy");


const CurveAdapter = artifacts.require("CurveUnderlyingAdapter");

module.exports = async (deployer, network, accounts) => {
    let CONFIG = GetConfig(network, accounts)
    if (CONFIG == null) return;

    let WETHAddress = CONFIG.WETH;
    let CrosspolyTokenAddress = CONFIG.Crosspoly;
    let CrosspolyApproveProxyAddress = CONFIG.CrosspolyApproveProxy;
    let WETH = CONFIG.WETH;

    let DspTemplateAddress = CONFIG.DSP;
    let DspFactoryAddress = CONFIG.DSPFactory;
    let DvmFactoryAddress = CONFIG.DVMFactory;
    let DppFactoryAddress = CONFIG.DPPFactory;
    let UpCpFactoryAddress = CONFIG.UpCpFactory;
    let CpFactoryAddress = CONFIG.CrowdPoolingFactory;
    let ERC20V2FactoryAddress = CONFIG.ERC20V2Factory;

    let CrosspolyCirculationHelperAddress = CONFIG.CrosspolyCirculationHelper;
    let GovernanceAddress = CONFIG.Governance;
    let vCrosspolyTokenAddress = CONFIG.vCrosspolyToken;
    let crosspolyTeam = CONFIG.crosspolyTeam;

    let CloneFactoryAddress = CONFIG.CloneFactory;
    let DefaultMtFeeRateAddress = CONFIG.FeeRateModel;
    let DefaultPermissionAddress = CONFIG.PermissionManager;
    let CpTemplateAddress = CONFIG.CP;
    let DvmTemplateAddress = CONFIG.DVM;
    let CustomERC20Address = CONFIG.CustomERC20;
    let ERC20Address = CONFIG.ERC20;

    let multiSigAddress = CONFIG.multiSigAddress;
    let defaultMaintainer = CONFIG.defaultMaintainer;

    let ERC20MineV3Address = CONFIG.ERC20MineV3;
    let CrosspolyMineV3RegistryAddress = CONFIG.CrosspolyMineV3Registry;
    let CrosspolyMineV3ProxyAddress = CONFIG.CrosspolyMineV3Proxy;


    if (deploySwitch.MineV3) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: MineV3");

        if (ERC20MineV3Address == "") {
            await deployer.deploy(ERC20MineV3);
            ERC20MineV3Address = ERC20MineV3.address;
            logger.log("ERC20MineV3Address: ", ERC20MineV3Address);
        }

        if (CrosspolyMineV3RegistryAddress == "") {
            await deployer.deploy(CrosspolyMineV3Registry);
            CrosspolyMineV3RegistryAddress = CrosspolyMineV3Registry.address;
            logger.log("CrosspolyMineV3RegistryAddress: ", CrosspolyMineV3RegistryAddress);

            const crosspolyMineV3RegistryInstance = await CrosspolyMineV3Registry.at(CrosspolyMineV3RegistryAddress);
            var tx = await crosspolyMineV3RegistryInstance.initOwner(multiSigAddress);
            logger.log("Init CrosspolyMineV3Registry Tx:", tx.tx);
        }

        if (CrosspolyMineV3ProxyAddress == "") {
            await deployer.deploy(
                CrosspolyMineV3Proxy,
                CloneFactoryAddress,
                ERC20MineV3Address,
                CrosspolyApproveProxyAddress,
                CrosspolyMineV3RegistryAddress
            );
            CrosspolyMineV3ProxyAddress = CrosspolyMineV3Proxy.address;
            logger.log("CrosspolyMineV3ProxyAddress: ", CrosspolyMineV3ProxyAddress);

            const crosspolyMineV3ProxyInstance = await CrosspolyMineV3Proxy.at(CrosspolyMineV3ProxyAddress);
            var tx = await crosspolyMineV3ProxyInstance.initOwner(multiSigAddress);
            logger.log("Init CrosspolyMineV3Proxy Tx:", tx.tx);
        }

        if (network == 'kovan' || network == 'rinkeby') {
            const crosspolyMineV3RegistryInstance = await CrosspolyMineV3Registry.at(CrosspolyMineV3RegistryAddress);
            var tx = await crosspolyMineV3RegistryInstance.addAdminList(CrosspolyMineV3ProxyAddress);
            logger.log("CrosspolyMineV3RegistryAddress Init tx: ", tx.tx);

            const CrosspolyApproveProxyInstance = await CrosspolyApproveProxy.at(CrosspolyApproveProxyAddress);
            tx = await CrosspolyApproveProxyInstance.unlockAddProxy(CrosspolyMineV3ProxyAddress);
            logger.log("CrosspolyApproveProxy Unlock tx: ", tx.tx);

            tx = await CrosspolyApproveProxyInstance.addCrosspolyProxy();
            logger.log("CrosspolyApproveProxy AddProxy tx: ", tx.tx);
        }

    }

    if (deploySwitch.ERC20V2Factory) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: ERC20V2Factory");

        if (ERC20Address == "") {
            await deployer.deploy(ERC20);
            ERC20Address = ERC20.address;
            logger.log("ERC20Address: ", ERC20Address);
        }
        if (CustomERC20Address == "") {
            await deployer.deploy(CustomERC20);
            CustomERC20Address = CustomERC20.address;
            logger.log("CustomERC20Address: ", CustomERC20Address);
        }

        if (ERC20V2FactoryAddress == "") {
            await deployer.deploy(
                ERC20V2Factory,
                CloneFactoryAddress,
                ERC20Address,
                CustomERC20Address
            );
            ERC20V2FactoryAddress = ERC20V2Factory.address;
            logger.log("ERC20V2FactoryAddress: ", ERC20V2FactoryAddress);

            const erc20V2FactoryInstance = await ERC20V2Factory.at(ERC20V2FactoryAddress);
            var tx = await erc20V2FactoryInstance.initOwner(multiSigAddress);
            logger.log("Init ERC20V2Factory Tx:", tx.tx);
        }

    }


    if (deploySwitch.ERC20Mine) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: ERC20Mine");

        var erc20TokenAddress = "0x86a7649aD78F6a0432189C99B909fe1E6682E0d8";
        var owner = multiSigAddress;

        await deployer.deploy(ERC20Mine);

        logger.log("erc20Mine address: ", ERC20Mine.address);
        const erc20MineInstance = await ERC20Mine.at(ERC20Mine.address);
        var tx = await erc20MineInstance.init(owner, erc20TokenAddress);
        logger.log("Init ERC20Mine Tx:", tx.tx);

        //add Token
        var reward0Token = "0xd7f02d1b4f9495b549787808503ecfd231c3fbda"
        var reward1Token = "0xfe1133ea03d701c5006b7f065bbf987955e7a67c"
        var rewardPerBlock = "10000000000000000" //0.01
        var startBlock = 24368900
        var endBlock = 25368900
        tx = await erc20MineInstance.addRewardToken(
            reward0Token,
            rewardPerBlock,
            startBlock,
            endBlock
        );
        logger.log("Add rewardToken0 Tx:", tx.tx);

        // tx = await erc20MineInstance.addRewardToken(
        //     reward1Token,
        //     rewardPerBlock,
        //     startBlock,
        //     endBlock
        // );
        // logger.log("Add rewardToken1 Tx:", tx.tx);

        //TODO: TransferReward to RewardVault
    }

    if (deploySwitch.LockedVault) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: LockedVault");
        await deployer.deploy(
            LockedTokenVault,
            "0xd8C30a4E866B188F16aD266dC3333BD47F34ebaE",
            1616468400,
            2592000,
            "100000000000000000"
        );
        logger.log("LockedVault address: ", LockedTokenVault.address);
        //TODO: approve && deposit
    }

    if (deploySwitch.DSP) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: DSP");

        if (DspTemplateAddress == "") {
            await deployer.deploy(DspTemplate);
            DspTemplateAddress = DspTemplate.address;
            logger.log("DspTemplateAddress: ", DspTemplateAddress);
        }

        if (DspFactoryAddress == "") {
            await deployer.deploy(
                DspFactory,
                CloneFactoryAddress,
                DspTemplateAddress,
                defaultMaintainer,
                DefaultMtFeeRateAddress
            );
            DspFactoryAddress = DspFactory.address;
            logger.log("DspFactoryAddress: ", DspFactoryAddress);
            const DspFactoryInstance = await DspFactory.at(DspFactoryAddress);
            var tx = await DspFactoryInstance.initOwner(multiSigAddress);
            logger.log("Init DspFactory Tx:", tx.tx);
        }

        await deployer.deploy(CrosspolyV2RouteHelper, DvmFactoryAddress, DppFactoryAddress, DspFactoryAddress);
        CrosspolyV2RouteHelperAddress = CrosspolyV2RouteHelper.address;
        logger.log("CrosspolyV2RouteHelper Address: ", CrosspolyV2RouteHelperAddress);

        await deployer.deploy(
            CrosspolyDspProxy,
            DspFactoryAddress,
            WETHAddress,
            CrosspolyApproveProxyAddress
        );
        logger.log("CrosspolyDspProxy Address: ", CrosspolyDspProxy.address);
    }

    if (deploySwitch.CpProxy) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: CrosspolyCpProxy");
        await deployer.deploy(
            CrosspolyCpProxy,
            WETHAddress,
            CpFactoryAddress,
            UpCpFactoryAddress,
            CrosspolyApproveProxyAddress
        );
        logger.log("CpProxy address: ", CrosspolyCpProxy.address);
    }


    if (deploySwitch.UpCP) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: UpCrowdPoolingFactory");
        await deployer.deploy(
            UpCrowdPoolingFactory,
            CloneFactoryAddress,
            CpTemplateAddress,
            DvmFactoryAddress,
            defaultMaintainer,
            DefaultMtFeeRateAddress,
            DefaultPermissionAddress
        );
        logger.log("UpCrowdPoolingFactory address: ", UpCrowdPoolingFactory.address);
        const UpCpFactoryInstance = await UpCrowdPoolingFactory.at(UpCrowdPoolingFactory.address);
        var tx = await UpCpFactoryInstance.initOwner(multiSigAddress);
        logger.log("Init UpCpFactory Tx:", tx.tx);
    }

    if (deploySwitch.MultiCall) {
        await deployer.deploy(MultiCall);
        MultiCallAddress = MultiCall.address;
        logger.log("MultiCallAddress: ", MultiCallAddress);
    }

    if (deploySwitch.CPFactory) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: CrowdPoolingFactory");
        await deployer.deploy(
            CpFactory,
            CloneFactoryAddress,
            CpTemplateAddress,
            DvmFactoryAddress,
            defaultMaintainer,
            DefaultMtFeeRateAddress,
            DefaultPermissionAddress
        );
        logger.log("CrowdPoolingFactory address: ", CpFactory.address);
        const cpFactoryInstance = await CpFactory.at(CpFactory.address);
        var tx = await cpFactoryInstance.initOwner(multiSigAddress);
        logger.log("Init CpFactory Tx:", tx.tx);
    }

    if (deploySwitch.DVM) {
        await deployer.deploy(DvmTemplate);
        DvmTemplateAddress = DvmTemplate.address;
        logger.log("DvmTemplateAddress: ", DvmTemplateAddress);
    }

    if (deploySwitch.CP) {
        await deployer.deploy(CpTemplate);
        CpTemplateAddress = CpTemplate.address;
        logger.log("CpTemplateAddress: ", CpTemplateAddress);
    }

    if (deploySwitch.FEERATEIMPL) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: FeeRateImpl");
        await deployer.deploy(FeeRateImpl);
        var FeeRateImplAddress = FeeRateImpl.address;
        logger.log("FeeRateImplAddress: ", FeeRateImplAddress);
        const feeRateImplInstance = await FeeRateImpl.at(FeeRateImplAddress);
        var tx = await feeRateImplInstance.initOwner(multiSigAddress);
        logger.log("Init feeRateImpl Tx:", tx.tx);
    }

    if (deploySwitch.Crosspoly) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: CrosspolyToken");
        await deployer.deploy(CrosspolyToken);
        logger.log("CrosspolyTokenAddress: ", CrosspolyToken.address);
    }

    if (deploySwitch.WETH) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: WETH9");
        await deployer.deploy(WETH9);
        var WETH9Address = WETH9.address;
        logger.log("WETH9Address: ", WETH9Address);
    }

    if (deploySwitch.MINE) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: CrosspolyMine");
        await deployer.deploy(CrosspolyMine, CrosspolyTokenAddress, 5008500);
        CrosspolyMineAddress = CrosspolyMine.address;
        logger.log("CrosspolyMineAddress: ", CrosspolyMineAddress);
        const crosspolyMineInstance = await CrosspolyMine.at(CrosspolyMineAddress);
        //Add crosspoly
        var tx = await crosspolyMineInstance.addLpToken(CrosspolyTokenAddress, "3000000000000000000000", true);
        logger.log("Add Crosspoly Tx:", tx.tx);
        //set BLockReward
        tx = await crosspolyMineInstance.setReward("1000000000000000", true);
        logger.log("Set blockReward Tx:", tx.tx);

        //transfer Crosspoly to Vault

        //transfer owner
    }


    if (deploySwitch.CrosspolyRecharge) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: CrosspolyRecharge");
        await deployer.deploy(CrosspolyRecharge, CrosspolyTokenAddress, CrosspolyApproveProxyAddress);
        CrosspolyRechargeAddress = CrosspolyRecharge.address;
        logger.log("CrosspolyRechargeAddress: ", CrosspolyRechargeAddress);
        const crosspolyRechargeInstance = await CrosspolyRecharge.at(CrosspolyRechargeAddress);
        var tx = await crosspolyRechargeInstance.initOwner(multiSigAddress);
        logger.log("Init CrosspolyRechargeAddress Tx:", tx.tx);
    }

    if (deploySwitch.MULTIHOP) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: CrosspolyRouteProxy");

        await deployer.deploy(
            CrosspolyRouteProxy,
            WETHAddress,
            CrosspolyApproveProxyAddress
        );

        logger.log("CrosspolyRouteProxy Address: ", CrosspolyRouteProxy.address);
    }


    if (deploySwitch.vCrosspolyToken) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: vCrosspolyToken");

        if (vCrosspolyTokenAddress == "") {
            await deployer.deploy(
                vCrosspolyToken,
                GovernanceAddress,
                CrosspolyTokenAddress,
                CrosspolyApproveProxyAddress,
                crosspolyTeam
            );
            vCrosspolyTokenAddress = vCrosspolyToken.address;
            logger.log("vCrosspolyTokenAddress: ", vCrosspolyTokenAddress);
            const vCrosspolyTokenInstance = await vCrosspolyToken.at(vCrosspolyTokenAddress);
            var tx = await vCrosspolyTokenInstance.initOwner(multiSigAddress);
            logger.log("Init vCrosspolyTokenAddress Tx:", tx.tx);
        }

        if (CrosspolyCirculationHelperAddress == "") {
            await deployer.deploy(CrosspolyCirculationHelper, vCrosspolyTokenAddress, CrosspolyTokenAddress);
            CrosspolyCirculationHelperAddress = CrosspolyCirculationHelper.address;
            logger.log("CrosspolyCirculationHelperAddress: ", CrosspolyCirculationHelperAddress);
            const CrosspolyCirculationHelperInstance = await CrosspolyCirculationHelper.at(CrosspolyCirculationHelperAddress);
            var tx = await CrosspolyCirculationHelperInstance.initOwner(multiSigAddress);
            logger.log("Init CrosspolyCirculationHelperAddress Tx:", tx.tx);
        }

        if (network == 'kovan' || network == 'rinkeby') {
            const vCrosspolyTokenInstance = await vCrosspolyToken.at(vCrosspolyTokenAddress);
            //updateCrosspolyCirculationHelper
            var tx = await vCrosspolyTokenInstance.updateCrosspolyCirculationHelper(CrosspolyCirculationHelperAddress);
            logger.log("vCrosspolyToken setCrosspolyCirculationHelper tx: ", tx.tx);

            //ApproveProxy add
            const CrosspolyApproveProxyInstance = await CrosspolyApproveProxy.at(CrosspolyApproveProxyAddress);
            tx = await CrosspolyApproveProxyInstance.unlockAddProxy(vCrosspolyTokenAddress);
            logger.log("CrosspolyApproveProxy Unlock tx: ", tx.tx);
            tx = await CrosspolyApproveProxyInstance.addCrosspolyProxy();
            logger.log("CrosspolyApproveProxy add tx: ", tx.tx);

            // //Mint Crosspoly first
            tx = await vCrosspolyTokenInstance.mint("100000000000000000000000",crosspolyTeam);
            logger.log("vCrosspolyToken first mint tx: ", tx.tx);

            // //preDepositedBlockReward
            tx = await vCrosspolyTokenInstance.preDepositedBlockReward("10000000000000000000000000");
            logger.log("vCrosspolyToken injected crosspoly tx: ", tx.tx);

            // //changePerReward
            tx = await vCrosspolyTokenInstance.changePerReward("10000000000000000");
            logger.log("vCrosspolyToken changeReward tx: ", tx.tx);

        }
    }

    if (deploySwitch.test_ADAPTER) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: test - Adapter");

        await deployer.deploy(CurveAdapter);

        logger.log("test_Adapter Address: ", CurveAdapter.address);
    }
};
