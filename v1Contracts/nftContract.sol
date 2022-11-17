// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MSysERC721 is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MSysNFT", "MNFT") {
        admin=msg.sender;
    }

     struct NFT{
            string name;
            uint tokenId;
            string tokenUri;
            uint price;
            address owner;
            bool forSale;
        }

        address public admin;
        NFT[] public NFTs;

    // ===================================MODIFIERS================================================

        modifier onlyAdmin{
        require(msg.sender == admin,"Only admin can call this function");
        _;
        }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/";
    }

    function countAllNfts() public view returns (uint count) {
        return _tokenIdCounter.current();
    }

    function getAllNfts() public view returns (NFT[] memory) {
        return NFTs;
    }

    function safeMint(string memory name,uint price,bool forSale,string memory tokenUri) public onlyAdmin {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenUri);
        NFTs.push(NFT(name,tokenId,tokenUri,price,msg.sender,forSale));
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
