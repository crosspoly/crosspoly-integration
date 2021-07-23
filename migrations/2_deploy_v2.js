const fs = require("fs");
const { deploySwitch } = require('../truffle-config.js')
const file = fs.createWriteStream("../deploy-detail-v2.0.txt", { 'flags': 'a' });
let logger = new console.Console(file, file);
const { GetConfig } = require("../configAdapter.js")

const CloneFactory = artifacts.require("CloneFactory");
const FeeRateModelTemplate = artifacts.require("FeeRateModel");
const PermissionManagerTemplate = artifacts.require("PermissionManager");
const CrosspolySellHelper = artifacts.require("CrosspolySellHelper");
const CrosspolyCalleeHelper = artifacts.require("CrosspolyCalleeHelper");
const CrosspolyV1PmmHelper = artifacts.require("CrosspolyV1PmmHelper");
const CrosspolyV2RouteHelper = artifacts.require("CrosspolyV2RouteHelper");

const DvmTemplate = artifacts.require("DVM");
const DppTemplate = artifacts.require("DPP");
const DspTemplate = artifacts.require("DSP");
const DppAdminTemplate = artifacts.require("DPPAdmin");
const CpTemplate = artifacts.require("CP");

const ERC20Template = artifacts.require("InitializableERC20");
const MintableERC20Template = artifacts.require("InitializableMintableERC20");
const ERC20Factory = artifacts.require("ERC20Factory");

const DvmFactory = artifacts.require("DVMFactory");
const DppFactory = artifacts.require("DPPFactory");
const DspFactory = artifacts.require("DSPFactory");
const CpFactory = artifacts.require("CrowdPoolingFactory");
const UpCpFactory = artifacts.require("UpCrowdPoolingFactory");

const CrosspolyApprove = artifacts.require("CrosspolyApprove");
const CrosspolyApproveProxy = artifacts.require("CrosspolyApproveProxy");

const CrosspolyDspProxy = artifacts.require("CrosspolyDspProxy");
const CrosspolyCpProxy = artifacts.require("CrosspolyCpProxy");
const CrosspolyProxyV2 = artifacts.require("CrosspolyV2Proxy02");

const CrosspolyV1Adapter = artifacts.require("CrosspolyV1Adapter");
const CrosspolyV2Adapter = artifacts.require("CrosspolyV2Adapter");
const UniAdapter = artifacts.require("UniAdapter");


module.exports = async (deployer, network, accounts) => {
    let CONFIG = GetConfig(network, accounts)
    if (CONFIG == null) return;
    //TOKEN
    let WETHAddress = CONFIG.WETH;

    //Helper
    let CrosspolySellHelperAddress = CONFIG.CrosspolySellHelper;
    let CrosspolyCalleeHelperAddress = CONFIG.CrosspolyCalleeHelper;
    let CrosspolyRouteV2HelperAddress = CONFIG.CrosspolyV2RouteHelper;
    let CrosspolyV1PmmHelperAddress = CONFIG.CrosspolyV1PmmHelper;

    //Template
    let CloneFactoryAddress = CONFIG.CloneFactory;
    let DefaultMtFeeRateAddress = CONFIG.FeeRateModel;
    let DefaultPermissionAddress = CONFIG.PermissionManager;
    let DvmTemplateAddress = CONFIG.DVM;
    let DspTemplateAddress = CONFIG.DSP;
    let DppTemplateAddress = CONFIG.DPP;
    let DppAdminTemplateAddress = CONFIG.DPPAdmin;
    let CpTemplateAddress = CONFIG.CP;
    let ERC20TemplateAddress = CONFIG.ERC20;
    let MintableERC20TemplateAddress = CONFIG.MintableERC20;

    //Facotry
    let DvmFactoryAddress = CONFIG.DVMFactory;
    let DspFactoryAddress = CONFIG.DSPFactory;
    let DppFactoryAddress = CONFIG.DPPFactory;
    let CpFactoryAddress = CONFIG.CrowdPoolingFactory;
    let UpCpFactoryAddress = CONFIG.UpCpFactory;
    let ERC20FactoryAddress = CONFIG.ERC20Factory;

    //Approve
    let CrosspolyApproveAddress = CONFIG.CrosspolyApprove;
    let CrosspolyApproveProxyAddress = CONFIG.CrosspolyApproveProxy;

    //Account
    let multiSigAddress = CONFIG.multiSigAddress;
    let defaultMaintainer = CONFIG.defaultMaintainer;


    if (deploySwitch.ADAPTER) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: V2 - Adapter");

        await deployer.deploy(CrosspolyV1Adapter, CrosspolySellHelperAddress)
        logger.log("CrosspolyV1Adapter Address: ", CrosspolyV1Adapter.address);
        await deployer.deploy(CrosspolyV2Adapter)
        logger.log("CrosspolyV2Adapter Address: ", CrosspolyV2Adapter.address);
        await deployer.deploy(UniAdapter)
        logger.log("UniAdapter Address: ", UniAdapter.address);
    }

    if (deploySwitch.DEPLOY_V2) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: V2");
        logger.log("multiSigAddress: ", multiSigAddress)

        //Helper
        if (CrosspolySellHelperAddress == "") {
            await deployer.deploy(CrosspolySellHelper);
            CrosspolySellHelperAddress = CrosspolySellHelper.address;
            logger.log("CrosspolySellHelper Address: ", CrosspolySellHelperAddress);
        }
        if (CrosspolyCalleeHelperAddress == "") {
            await deployer.deploy(CrosspolyCalleeHelper, WETHAddress);
            CrosspolyCalleeHelperAddress = CrosspolyCalleeHelper.address;
            logger.log("CrosspolyCalleeHelperAddress: ", CrosspolyCalleeHelperAddress);
        }

        if (CrosspolyV1PmmHelperAddress == "") {
            await deployer.deploy(CrosspolyV1PmmHelper);
            CrosspolyV1PmmHelperAddress = CrosspolyV1PmmHelper.address;
            logger.log("CrosspolyV1RouterHelper Address: ", CrosspolyV1PmmHelperAddress);
        }

        //Template
        if (CloneFactoryAddress == "") {
            await deployer.deploy(CloneFactory);
            CloneFactoryAddress = CloneFactory.address;
            logger.log("CloneFactoryAddress: ", CloneFactoryAddress);
        }

        if (DefaultMtFeeRateAddress == "") {
            await deployer.deploy(FeeRateModelTemplate);
            DefaultMtFeeRateAddress = FeeRateModelTemplate.address;
            logger.log("DefaultMtFeeRateAddress: ", DefaultMtFeeRateAddress);
            const defaultMtFeeRateInstance = await FeeRateModelTemplate.at(DefaultMtFeeRateAddress);
            var tx = await defaultMtFeeRateInstance.initOwner(multiSigAddress);
            logger.log("Init DefaultMtFeeRateAddress Tx:", tx.tx);
        }

        if (DefaultPermissionAddress == "") {
            await deployer.deploy(PermissionManagerTemplate);
            DefaultPermissionAddress = PermissionManagerTemplate.address;
            logger.log("DefaultPermissionAddress: ", DefaultPermissionAddress);
            const defaultPermissionInstance = await PermissionManagerTemplate.at(DefaultPermissionAddress);
            var tx = await defaultPermissionInstance.initOwner(multiSigAddress);
            logger.log("Init DefaultPermissionAddress Tx:", tx.tx);
        }

        if (DvmTemplateAddress == "") {
            await deployer.deploy(DvmTemplate);
            DvmTemplateAddress = DvmTemplate.address;
            logger.log("DvmTemplateAddress: ", DvmTemplateAddress);
        }

        if (DspTemplateAddress == "") {
            await deployer.deploy(DspTemplate);
            DspTemplateAddress = DspTemplate.address;
            logger.log("DspTemplateAddress: ", DspTemplateAddress);
        }

        if (DppTemplateAddress == "") {
            await deployer.deploy(DppTemplate);
            DppTemplateAddress = DppTemplate.address;
            logger.log("DppTemplateAddress: ", DppTemplateAddress);
        }

        if (DppAdminTemplateAddress == "") {
            await deployer.deploy(DppAdminTemplate);
            DppAdminTemplateAddress = DppAdminTemplate.address;
            logger.log("DppAdminTemplateAddress: ", DppAdminTemplateAddress);
        }
        if (CpTemplateAddress == "") {
            await deployer.deploy(CpTemplate);
            CpTemplateAddress = CpTemplate.address;
            logger.log("CpTemplateAddress: ", CpTemplateAddress);
        }

        if (ERC20TemplateAddress == "") {
            await deployer.deploy(ERC20Template);
            ERC20TemplateAddress = ERC20Template.address;
            logger.log("ERC20TemplateAddress: ", ERC20TemplateAddress);
        }
        if (MintableERC20TemplateAddress == "") {
            await deployer.deploy(MintableERC20Template);
            MintableERC20TemplateAddress = MintableERC20Template.address;
            logger.log("MintableERC20TemplateAddress: ", MintableERC20TemplateAddress);
        }

        if (ERC20FactoryAddress == "") {
            await deployer.deploy(
                ERC20Factory,
                CloneFactoryAddress,
                ERC20TemplateAddress,
                MintableERC20TemplateAddress
            );
            ERC20FactoryAddress = ERC20Factory.address;
            logger.log("ERC20FactoryAddress: ", ERC20FactoryAddress);
        }

        //Approve
        if (CrosspolyApproveAddress == "") {
            await deployer.deploy(CrosspolyApprove);
            CrosspolyApproveAddress = CrosspolyApprove.address;
            logger.log("CrosspolyApprove Address: ", CrosspolyApproveAddress);
        }

        if (CrosspolyApproveProxyAddress == "") {
            await deployer.deploy(CrosspolyApproveProxy, CrosspolyApproveAddress);
            CrosspolyApproveProxyAddress = CrosspolyApproveProxy.address;
            logger.log("CrosspolyApproveProxy Address: ", CrosspolyApproveProxyAddress);
        }

        //Factory
        if (DvmFactoryAddress == "") {
            await deployer.deploy(
                DvmFactory,
                CloneFactoryAddress,
                DvmTemplateAddress,
                defaultMaintainer,
                DefaultMtFeeRateAddress
            );
            DvmFactoryAddress = DvmFactory.address;
            logger.log("DvmFactoryAddress: ", DvmFactoryAddress);
            const DvmFactoryInstance = await DvmFactory.at(DvmFactoryAddress);
            var tx = await DvmFactoryInstance.initOwner(multiSigAddress);
            logger.log("Init DvmFactory Tx:", tx.tx);
        }

        if (DppFactoryAddress == "") {
            await deployer.deploy(
                DppFactory,
                CloneFactoryAddress,
                DppTemplateAddress,
                DppAdminTemplateAddress,
                defaultMaintainer,
                DefaultMtFeeRateAddress,
                CrosspolyApproveProxyAddress
            );
            DppFactoryAddress = DppFactory.address;
            logger.log("DppFactoryAddress: ", DppFactoryAddress);
            const DppFactoryInstance = await DppFactory.at(DppFactoryAddress);
            var tx = await DppFactoryInstance.initOwner(multiSigAddress);
            logger.log("Init DppFactory Tx:", tx.tx);
        }

        if (UpCpFactoryAddress == "") {
            await deployer.deploy(
                UpCpFactory,
                CloneFactoryAddress,
                CpTemplateAddress,
                DvmFactoryAddress,
                defaultMaintainer,
                DefaultMtFeeRateAddress,
                DefaultPermissionAddress
            );
            logger.log("UpCrowdPoolingFactory address: ", UpCpFactory.address);
            UpCpFactoryAddress = UpCpFactory.address;
            const UpCpFactoryInstance = await UpCpFactory.at(UpCpFactory.address);
            var tx = await UpCpFactoryInstance.initOwner(multiSigAddress);
            logger.log("Init UpCpFactory Tx:", tx.tx);
        }

        if (CpFactoryAddress == "") {
            await deployer.deploy(
                CpFactory,
                CloneFactoryAddress,
                CpTemplateAddress,
                DvmFactoryAddress,
                defaultMaintainer,
                DefaultMtFeeRateAddress,
                DefaultPermissionAddress
            );
            CpFactoryAddress = CpFactory.address;
            logger.log("CpFactoryAddress: ", CpFactoryAddress);
            const CpFactoryInstance = await CpFactory.at(CpFactoryAddress);
            var tx = await CpFactoryInstance.initOwner(multiSigAddress);
            logger.log("Init CpFactory Tx:", tx.tx);
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

        if (CrosspolyRouteV2HelperAddress == "") {
            await deployer.deploy(CrosspolyV2RouteHelper, DvmFactoryAddress, DppFactoryAddress, DspFactoryAddress);
            CrosspolyV2RouteHelperAddress = CrosspolyV2RouteHelper.address;
            logger.log("CrosspolyV2RouteHelper Address: ", CrosspolyV2RouteHelperAddress);
        }

        //Proxy 
        await deployer.deploy(
            CrosspolyDspProxy,
            DspFactoryAddress,
            WETHAddress,
            CrosspolyApproveProxyAddress
        );
        logger.log("CrosspolyDspProxy Address: ", CrosspolyDspProxy.address);


        await deployer.deploy(
            CrosspolyCpProxy,
            WETHAddress,
            CpFactoryAddress,
            UpCpFactoryAddress,
            CrosspolyApproveProxyAddress
        );
        logger.log("CpProxy address: ", CrosspolyCpProxy.address);


        await deployer.deploy(
            CrosspolyProxyV2,
            DvmFactoryAddress,
            DppFactoryAddress,
            WETHAddress,
            CrosspolyApproveProxyAddress,
            CrosspolySellHelperAddress
        );
        logger.log("CrosspolyV2Proxy02 Address: ", CrosspolyProxyV2.address);
        const CrosspolyProxyV2Instance = await CrosspolyProxyV2.at(CrosspolyProxyV2.address);
        var tx = await CrosspolyProxyV2Instance.initOwner(multiSigAddress);
        logger.log("Init CrosspolyProxyV2 Tx:", tx.tx);


        if (network == 'kovan' || network == 'mbtestnet' || network == 'oktest' || network == 'matic' || network == 'arb' || network == 'rinkeby') {

            const CrosspolyApproveProxyInstance = await CrosspolyApproveProxy.at(CrosspolyApproveProxyAddress);
            var tx = await CrosspolyApproveProxyInstance.init(multiSigAddress, [CrosspolyProxyV2.address, CrosspolyCpProxy.address, CrosspolyDspProxy.address]);
            logger.log("CrosspolyApproveProxy Init tx: ", tx.tx);


            const CrosspolyApproveInstance = await CrosspolyApprove.at(CrosspolyApproveAddress);
            var tx = await CrosspolyApproveInstance.init(multiSigAddress, CrosspolyApproveProxy.address);
            logger.log("CrosspolyApprove Init tx: ", tx.tx);
        }

    }
};
