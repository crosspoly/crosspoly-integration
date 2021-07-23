/*

    Copyright 2021 Crosspoly ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;

import {ERC721URIStorage} from "../external/ERC721/ERC721URIStorage.sol";
import {InitializableOwnable} from "../lib/InitializableOwnable.sol";

contract CrosspolyNFT is ERC721URIStorage, InitializableOwnable {
    
    uint256 public _CUR_TOKENID_;

    // ============ Event =============
    event CrosspolyNFTMint(address creator, uint256 tokenId);
    event CrosspolyNFTBurn(uint256 tokenId);
    
    function init(
        address owner,
        string memory name,
        string memory symbol
    ) public {
        initOwner(owner);
        _name = name;
        _symbol = symbol;
    }

    function mint(string calldata uri) external {
        _safeMint(msg.sender, _CUR_TOKENID_);
        _setTokenURI(_CUR_TOKENID_, uri);
        emit CrosspolyNFTMint(msg.sender, _CUR_TOKENID_);
        _CUR_TOKENID_ = _CUR_TOKENID_ + 1;
    }

    function burn(uint256 tokenId) external onlyOwner {
        require(tokenId < _CUR_TOKENID_, "TOKENID_INVALID");
        _burn(tokenId);
        emit CrosspolyNFTBurn(tokenId);
    }
}