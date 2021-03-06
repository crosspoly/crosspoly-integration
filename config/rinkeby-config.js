module.exports = {
    RINKEBY_CONFIG: {
        //TOKEN
        WETH: "0xB26c0d8Be2960c70641A95A9195BE1f59Ac83aC0",
        CHI: "0x0000000000000000000000000000000000000000",
        Crosspoly: "0xeaa70c2a40820dF9D38149C84dd943CFcB562587",

        //Helper
        CrosspolySellHelper: "0x4635FAc4471BC5B5839007f1EF65ff469ace333F",
        CrosspolyCalleeHelper: "0x87C296100df953aFa324ABB870891baD9dDBf0fC",
        CrosspolyV1PmmHelper: "0xEb06236b035f1Db7F1D181Efd635Edd621874472",
        CrosspolyV2RouteHelper: "0x80a70F228D8faBF20fdaf8274b9A7c4AE3551861",

        //Template
        CloneFactory: "0x823ECBfCCD3e6Cb67d4c9334F743BEe0E60A7349",
        FeeRateModel: "0x0ae835f585638CCbD4D7eAA339ED033f8194Bcfe",
        PermissionManager: "0x7949a4D350F69ef5Ff4c3079751250f5b7B86a00",
        DVM: "0x44BD801ACAf994bD628d01d84299BE94010dc08B",
        DPP: "0x604BFaDa2EAC7E011DdF9aA8848b38e8b02aDdD2",
        DSP: "0xe2C23cBF03930418BF97e173FE3E950aD29fdb06",
        DPPAdmin: "0x2FF619B4Cfe36b0F92dD933256B1581a3269a5F4",
        CP: "0x6850eE8cF963B913a8eC3610B5f128C3100178E5",
        ERC20MineV3: "0xd5Bbb5497d0503a8d0CB5A9410EcFfF840Fe0012",
        ERC20: "0x7119D1Ec8235bd0a82289fDb1cCAa4bD4D1e0605",
        MintableERC20: "",
        CustomERC20: "0x0Cd57DC8367362314C510446FD106B66989Eb81a",


        //Factory
        DVMFactory: "0x17DddEFA0c82E0c850a4Adac2aFE3F1fe977A242",
        DPPFactory: "0x510b49803E356C750f3a93bA5508C0FFD9f71bDD",
        DSPFactory: "0xa1ab675cB49BA0DC3F39fA4C20E216572A8dD3c8",
        CrowdPoolingFactory: "0xDD43520779dDCfbDe373174Ee36aEaD39771cD4f",
        UpCpFactory: "0xb09E91505347234Cb722D67042290f50F1C13749",
        ERC20Factory: "0x48476599281CB7DD46dbE47264C4594d1d2E19A8",
        ERC20V2Factory: "0x7A22e361cB74E69B5B1C800A3aAbE3E50e84F4F6",
        CrosspolyMineV3Registry: "0xeA12A4F762B6D8e2a122847aB1ecF60BB690fEd8",

        //Approve
        CrosspolyApprove: "0xcC8d87A7C747eeE4242045C47Ef25e0A81D56ae3",
        CrosspolyApproveProxy: "0x790917CA55c9B01974BFDd066537Fb3DF42Bb0E3",

        //Periphery
        CrosspolyIncentive: "0x0000000000000000000000000000000000000000",

        //Adpater
        CrosspolyV1Adapter: "0x7ffd33271765E37FdD527a03ca13783DCD4dD3E6",
        CrosspolyV2Adapter: "0x733488ea274561fe8543cF5386fEcC6EE932Ba5E",
        UniAdapter: "0x5964Af417A0cdFa8C0E171733FB1c570b2b515E8",

        //Proxy
        CrosspolyV2Proxy: "0xba001E96AF87bF9d8D0BDA667067A9921FE6d294",
        DSPProxy: "0x0f6345D1d07C134BB0973AD102F38eA9195F6f78",
        CpProxy: "0x2E483CBb9e76fE6543168DEd698d9244EE1ED8Dd",
        RouteProxy: "0xe2b538a781eB5a115a1359B8f363B9703Fd19dE6",
        CrosspolyMineV3Proxy: "0xcb15BBb59AC8a4B64A4db9B8d9F66c397d89Bd22",

        //vCrosspoly
        CrosspolyCirculationHelper: "0xe4Aec985debDDbbCB2358e8C8F9384DD6421d163",
        Governance: "0x0000000000000000000000000000000000000000",
        crosspolyTeam: "0x7e83d9d94837eE82F0cc18a691da6f42F03F1d86",
        vCrosspolyToken: "0x8751f874eCd2874f2a5ced95A08364C203e4146A",

        //Account
        multiSigAddress: "0x7e83d9d94837eE82F0cc18a691da6f42F03F1d86",
        defaultMaintainer: "0x7e83d9d94837eE82F0cc18a691da6f42F03F1d86",

        //FeeRateImpl: "0xCc5e58B59158A9dfb13e4d902958689fA0e7dE9c",
        //multiCall: "0xb7E1C577f95959a3eD11f9281702850328b4e0e4",
        //Crosspoly: "0xF65899222FC7C73044Fe24f954b3b29Ff092B9e2",
        //CrosspolyZoo: "0x168442Fec1e1E782c8770185dBb8328B91dC45c0",
        //CrosspolySwapCalcHelper: "0x5020d289E1140Dc733126a71818A08F7f0fe1AE1",
        //CrosspolyMineV2Factory: "0x3932E00a51d0D3b85C8Eb7C3ED0FcCB0dF98B3FF"

        //================== NFT ====================
        BuyoutModel: "0x98F5aF1E7Fb03A085D2a28713995e4A923860288",
        Fragment: "0xDF7eccee9f5C92D1Baf036DB9410456f9382E045",
        NFTCollateralVault: "0x23d72eA97a9E43411Eeb908d128DF337aD334582",
        CrosspolyNFTRouteHelper: "0xb0Ca341b6fbdC607A507D821780e29f9601a58B3",

        InitializableERC721: "0xC0ccfC832BD45Cd3A2d62e47FE92Fc50DD2210ac",
        InitializableERC1155: "0x9DC9086B65cCBec43F92bFa37Db81150Ed1DDDed",
        NFTTokenFactory: "0xd2BffcCBC1F2a7356f8DaBB55B33E47D62de1bB1",

        DodoNftErc721: "0x3Bc20358B31aD498d5a245B36bC993DDBE9A4405",
        DodoNftErc1155: "0xc498F36eF82Aa5dBE0ecF6DD56DD55398E80E13D",

        CrosspolyNFTRegistry: "0x69efeCA5070Cb22c1094cffEbacafC09c058c139",
        CrosspolyNFTProxy: "0x0CF019E13C6527BD34eC6c8323F11aB5DF6f0922",

        //================= DropsV1 =================
        MysteryBoxV1: "",
        RandomGenerator: "0x69C8a7fc6E05d7aa36114B3e35F62DEcA8E11F6E",
        RandomPool: [],

        //================= DropsV2 ==================
        DropsFeeModel: "0xA012249Fac6D77Daf246BFBdC193fFBC8814298C",
        DropsProxy: "0xa968a8B14174395c922347Ab593a0CD7EFf30cf1",

        //CrosspolyDropsV2: "0x4A2b9f63AE41cF3003A494F2d8Fcd9Ed850b9A6f"
        // DropsERC721: "0x3df8d553275781C777f432A74EEE9099226B9d13",
        // DropsERC1155: "0x3a8EcF30428bd4e33Cd7011533DFd596F7705c8F",
    }
}