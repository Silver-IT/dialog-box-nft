// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error NotExistingToken();
error ExistingToken();
error NotApprovedOrOwner();
error NotEnoughEtherProvided();
error SoldOut();

contract ArtToken is ERC721Royalty, ERC721Burnable, ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public constant MINT_PRICE = 0.1 ether;
    uint256 public constant MAX_SUPPLY = 10000;

    string private baseURI;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        baseURI = _initBaseURI;
    }

    event TokenMinted(uint256 _tokenId);
    event BaseURIUpdated(string _baseURI);

    modifier isTokenExist(uint256 _tokenId) {
        if (!_exists(_tokenId)) {
            revert NotExistingToken();
        }

        _;
    }

    modifier isTokenNotExist(uint256 _tokenId) {
        if (_exists(_tokenId)) {
            revert ExistingToken();
        }

        _;
    }

    modifier isApprovedOrOwner(uint256 _tokenId) {
        if (!_isApprovedOrOwner(_msgSender(), _tokenId)) {
            revert NotApprovedOrOwner();
        }

        _;
    }

    modifier isMaxSupplyLimit() {
        if (totalSupply() >= MAX_SUPPLY) {
            revert SoldOut();
        }

        _;
    }

    function publicMint(uint256 _tokenId, uint96 _royaltyFraction)
        external
        payable
        isTokenNotExist(_tokenId)
        isMaxSupplyLimit
    {
        if (msg.value < MINT_PRICE) {
            revert NotEnoughEtherProvided();
        }
        _processMint(_msgSender(), _tokenId, _royaltyFraction);
    }

    function reservedMint(
        address _to,
        uint256 _tokenId,
        uint96 _royaltyFraction
    ) external onlyOwner isTokenNotExist(_tokenId) isMaxSupplyLimit {
        _processMint(_to, _tokenId, _royaltyFraction);
    }

    function _processMint(
        address _to,
        uint256 _tokenId,
        uint96 _royaltyFraction
    ) private {
        _safeMint(_to, _tokenId);
        _setTokenRoyalty(_tokenId, _msgSender(), _royaltyFraction);

        emit TokenMinted(_tokenId);
    }

    function _burn(uint256 _tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(_tokenId);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;

        emit BaseURIUpdated(_newBaseURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721)
        isTokenExist(_tokenId)
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    "token/",
                    _tokenId.toString(),
                    ".json"
                )
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721Royalty, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function deleteRoyalty(uint256 _tokenId)
        public
        isApprovedOrOwner(_tokenId)
    {
        _resetTokenRoyalty(_tokenId);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        return super._beforeTokenTransfer(_from, _to, _tokenId);
    }
}
