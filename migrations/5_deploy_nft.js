const fs = require("fs");
const { deploySwitch } = require('../truffle-config.js')
const file = fs.createWriteStream("../deploy-nft.txt", { 'flags': 'a' });
let logger = new console.Console(file, file);
const { GetConfig } = require("../configAdapter.js")

const CrosspolyApproveProxy = artifacts.require("CrosspolyApproveProxy");
const NFTCollateralVault = artifacts.require("NFTCollateralVault");
const BuyoutModel = artifacts.require("BuyoutModel");
const Fragment = artifacts.require("Fragment");
const CrosspolyNFTRegistry = artifacts.require("CrosspolyNFTRegistry");
const CrosspolyNFTProxy = artifacts.require("CrosspolyNFTProxy");
const CrosspolyNFTRouteHelper = artifacts.require("CrosspolyNFTRouteHelper");

const InitializableERC721 = artifacts.require("InitializableERC721");
const InitializableERC1155 = artifacts.require("InitializableERC1155");
const NFTTokenFactory = artifacts.require("NFTTokenFactory");

const DodoNftErc721 = artifacts.require("CrosspolyNFT");
const DodoNftErc1155 = artifacts.require("CrosspolyNFT1155");

const CrosspolyDropsV1 = artifacts.require("CrosspolyDropsV1");
const RandomGenerator = artifacts.require("RandomGenerator");

module.exports = async (deployer, network, accounts) => {
    let CONFIG = GetConfig(network, accounts)
    if (CONFIG == null) return;
    //Need Deploy first
    let WETHAddress = CONFIG.WETH;
    let DVMTemplateAddress = CONFIG.DVM;
    let CloneFactoryAddress = CONFIG.CloneFactory;
    let CrosspolyApproveProxyAddress = CONFIG.CrosspolyApproveProxy;

    if (CrosspolyApproveProxyAddress == "" || CloneFactoryAddress == "") return;

    let MtFeeRateModelAddress = CONFIG.FeeRateModel;
    let FragmentAddress = CONFIG.Fragment;
    let BuyoutModelAddress = CONFIG.BuyoutModel;
    let NFTCollateralVaultAddress = CONFIG.NFTCollateralVault;
    let CrosspolyNFTRouteHelperAddress = CONFIG.CrosspolyNFTRouteHelper;

    let CrosspolyNFTRegistryAddress = CONFIG.CrosspolyNFTRegistry;
    let CrosspolyNFTProxyAddress = CONFIG.CrosspolyNFTProxy;

    let ERC721Address = CONFIG.InitializableERC721;
    let ERC1155Address = CONFIG.InitializableERC1155;
    let NFTTokenFactoryAddress = CONFIG.NFTTokenFactory;

    let MysteryBoxV1Address = CONFIG.MysteryBoxV1;
    let RandomGeneratorAddress = CONFIG.RandomGenerator;
    let RandomPool = CONFIG.RandomPool;

    let DodoNftErc721Address = CONFIG.DodoNftErc721;
    let DodoNftErc1155Address = CONFIG.DodoNftErc1155;

    let multiSigAddress = CONFIG.multiSigAddress;
    let defaultMaintainer = CONFIG.defaultMaintainer;

    if (deploySwitch.MYSTERYBOX_V1) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: FearNFT");

        if (RandomGeneratorAddress == "") {
            await deployer.deploy(RandomGenerator, RandomPool);
            RandomGeneratorAddress = RandomGenerator.address;
            logger.log("RandomGeneratorAddress: ", RandomGeneratorAddress);
        }

        if (MysteryBoxV1Address == "") {
            await deployer.deploy(CrosspolyDropsV1);
            MysteryBoxV1Address = CrosspolyDropsV1.address;
            logger.log("MysteryBoxV1Address: ", MysteryBoxV1Address);
            const MysteryBoxV1Instance = await CrosspolyDropsV1.at(MysteryBoxV1Address);
            var tx = await MysteryBoxV1Instance.init(
                "CrosspolyTest",
                "CrosspolyTest",
                "",
                multiSigAddress,
                RandomGeneratorAddress
            );
            logger.log("Init MysteryBoxV1 Tx:", tx.tx);
        }
    }

    if (deploySwitch.COLLECTIONS) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: Crosspoly Collections");

        //ERC721
        if (DodoNftErc721Address == "") {
            await deployer.deploy(DodoNftErc721);
            DodoNftErc721Address = DodoNftErc721.address;
            logger.log("DodoNftErc721Address: ", DodoNftErc721Address);
            const DodoNftErc721Instance = await DodoNftErc721.at(DodoNftErc721Address);
            var tx = await DodoNftErc721Instance.init(
                multiSigAddress,
                "CrosspolyNFT",
                "CrosspolyNFT"
            );
            logger.log("Init DodoNftErc721 Tx:", tx.tx);
        }

        //ERC1155
        if (DodoNftErc1155Address == "") {
            await deployer.deploy(DodoNftErc1155);
            DodoNftErc1155Address = DodoNftErc1155.address;
            logger.log("DodoNftErc1155Address: ", DodoNftErc1155Address);
            const DodoNftErc1155Instance = await DodoNftErc1155.at(DodoNftErc1155Address);
            var tx = await DodoNftErc1155Instance.initOwner(multiSigAddress);
            logger.log("Init DodoNftErc1155 Tx:", tx.tx);
        }
    }

    if (deploySwitch.DEPLOY_NFT) {
        logger.log("====================================================");
        logger.log("network type: " + network);
        logger.log("Deploy time: " + new Date().toLocaleString());
        logger.log("Deploy type: NFT");
        logger.log("multiSigAddress: ", multiSigAddress)

        //ERC721
        if (ERC721Address == "") {
            await deployer.deploy(InitializableERC721);
            ERC721Address = InitializableERC721.address;
            logger.log("ERC721Address: ", ERC721Address);
        }
        //ERC1155
        if (ERC1155Address == "") {
            await deployer.deploy(InitializableERC1155);
            ERC1155Address = InitializableERC1155.address;
            logger.log("ERC1155Address: ", ERC1155Address);
        }
        //NFTTokenFactory
        if (NFTTokenFactoryAddress == "") {
            await deployer.deploy(
                NFTTokenFactory,
                CloneFactoryAddress,
                ERC721Address,
                ERC1155Address
            );
            NFTTokenFactoryAddress = NFTTokenFactory.address;
            logger.log("NFTTokenFactoryAddress: ", NFTTokenFactoryAddress);
        }

        //NFTRegister
        if (CrosspolyNFTRegistryAddress == "") {
            await deployer.deploy(CrosspolyNFTRegistry);
            CrosspolyNFTRegistryAddress = CrosspolyNFTRegistry.address;
            logger.log("CrosspolyNFTRegistryAddress: ", CrosspolyNFTRegistryAddress);
            const CrosspolyNFTRegistrynstance = await CrosspolyNFTRegistry.at(CrosspolyNFTRegistryAddress);
            var tx = await CrosspolyNFTRegistrynstance.initOwner(multiSigAddress);
            logger.log("Init CrosspolyNFTRegistryAddress Tx:", tx.tx);

            await deployer.deploy(
                CrosspolyNFTRouteHelper,
                CrosspolyNFTRegistryAddress
            );
            CrosspolyNFTRouteHelperAddress = CrosspolyNFTRouteHelper.address;
            logger.log("CrosspolyNFTRouteHelperAddress: ", CrosspolyNFTRouteHelperAddress);
        }

        //BuyoutModel
        if(BuyoutModelAddress == "") {
            await deployer.deploy(BuyoutModel);
            BuyoutModelAddress = BuyoutModel.address;
            logger.log("BuyoutModelAddress: ", BuyoutModelAddress);
            const BuyoutModelInstance = await BuyoutModel.at(BuyoutModelAddress);
            var tx = await BuyoutModelInstance.initOwner(multiSigAddress);
            logger.log("Init BuyoutModelAddress Tx:", tx.tx);

        }

        //CrosspolyNFTRouteHelper
        if (CrosspolyNFTRouteHelperAddress == "") {
            await deployer.deploy(
                CrosspolyNFTRouteHelper,
                CrosspolyNFTRegistryAddress
            );
            CrosspolyNFTRouteHelperAddress = CrosspolyNFTRouteHelper.address;
            logger.log("CrosspolyNFTRouteHelperAddress: ", CrosspolyNFTRouteHelperAddress);
        }

        //Vault
        if (NFTCollateralVaultAddress == "") {
            await deployer.deploy(NFTCollateralVault);
            NFTCollateralVaultAddress = NFTCollateralVault.address;
            logger.log("NFTCollateralVaultAddress: ", NFTCollateralVaultAddress);
        }

        //Frag
        if (FragmentAddress == "") {
            await deployer.deploy(Fragment);
            FragmentAddress = Fragment.address;
            logger.log("FragmentAddress: ", FragmentAddress);
        }

        if (CrosspolyNFTProxyAddress == "") {
            await deployer.deploy(
                CrosspolyNFTProxy,
                CloneFactoryAddress,
                WETHAddress,
                CrosspolyApproveProxyAddress,
                defaultMaintainer,
                BuyoutModelAddress,
                MtFeeRateModelAddress,
                NFTCollateralVaultAddress,
                FragmentAddress,
                DVMTemplateAddress,
                CrosspolyNFTRegistryAddress
            );
            CrosspolyNFTProxyAddress = CrosspolyNFTProxy.address;
            logger.log("CrosspolyNFTProxyAddress: ", CrosspolyNFTProxyAddress);
            const CrosspolyNFTProxyInstance = await CrosspolyNFTProxy.at(CrosspolyNFTProxyAddress);
            var tx = await CrosspolyNFTProxyInstance.initOwner(multiSigAddress);
            logger.log("Init CrosspolyNFTProxyAddress Tx:", tx.tx);
        }

        if (network == 'kovan' || network == 'rinkeby') {

            const CrosspolyApproveProxyInstance = await CrosspolyApproveProxy.at(CrosspolyApproveProxyAddress);
            var tx = await CrosspolyApproveProxyInstance.unlockAddProxy(CrosspolyNFTProxyAddress);
            logger.log("CrosspolyApproveProxy unlockAddProxy tx: ", tx.tx);

            tx = await CrosspolyApproveProxyInstance.addCrosspolyProxy();
            logger.log("CrosspolyApproveProxy addCrosspolyProxy tx: ", tx.tx);

            const CrosspolyNFTRegistrynstance = await CrosspolyNFTRegistry.at(CrosspolyNFTRegistryAddress);
            var tx = await CrosspolyNFTRegistrynstance.addAdminList(CrosspolyNFTProxyAddress);
            logger.log("Add AdminList on CrosspolyNFTRegistry Tx:", tx.tx);
        }
    }
};
