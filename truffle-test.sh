#!/bin/bash
# truffle compile --all

if [ "$1"x = "proxy-dpp"x ]
then
	truffle test ./test/V2Proxy/proxy.dpp.test.ts
fi
 
if [ "$1"x = "proxy-dvm"x ]
then
	truffle test ./test/V2Proxy/proxy.dvm.test.ts
fi

if [ "$1"x = "proxy-mix"x ]
then
	truffle test ./test/V2Proxy/proxy.mix.test.ts
fi

if [ "$1"x = "proxy-classical"x ]
then
	truffle test ./test/V2Proxy/proxy.classical.test.ts
fi

if [ "$1"x = "proxy-cp"x ]
then
	truffle test ./test/V2Proxy/proxy.cp.test.ts
fi

if [ "$1"x = "proxy-incentive"x ]
then
	truffle test ./test/V2Proxy/proxy.incentive.test.ts
fi

if [ "$1"x = "proxy-incentive-bsc"x ]
then
	truffle test ./test/V2Proxy/proxy.incentive.bsc.test.ts
fi

if [ "$1"x = "proxy-twap"x ]
then
	truffle test ./test/V2Proxy/proxy.twap.test.ts
fi

if [ "$1"x = "vcrosspoly-mintRedeem"x ]
then
	truffle test ./test/vCrosspoly/mintRedeem.test.ts
fi

if [ "$1"x = "erc20-mine"x ]
then
	truffle test ./test/CrosspolyMineV2/erc20Mine.test.ts
fi

if [ "$1"x = "vcrosspoly-mine"x ]
then
	truffle test ./test/CrosspolyMineV2/vCrosspolyMine.test.ts
fi

if [ "$1"x = "nft"x ]
then
	truffle test ./test/CrosspolyNFT/nftMainFlow.test.ts
fi

if [ "$1"x = "boxV1"x ]
then
	truffle test ./test/CrosspolyNFT/mysteryBoxV1.test.ts
fi

if [ "$1"x = "boxV2"x ]
then
	truffle test ./test/CrosspolyDrops/dropsV2.test.ts
fi

# if [ "$1"x = "route-incentive"x ]
# then
# 	truffle test ./test/Route/Incentive.test.ts
# fi

# if [ "$1"x = "route"x ]
# then
# 	truffle test ./test/Route/route.test.ts
# fi