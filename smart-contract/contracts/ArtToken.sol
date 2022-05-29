// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error NotExistingToken();
error ExistingToken();
error NotApprovedOrOwner();
error NotEnoughEtherProvided();
error SoldOut();
error NoTrailingSlash();
error InvalidAddress();

contract ArtToken is ERC721Royalty, ERC721Burnable, ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _currentTokenId;

    uint256 public MINT_PRICE = 0.1 ether;
    uint256 public MAX_SUPPLY = 100;

    string public baseURI;
    string public logoURI;

    address private royaltyReceiver;

    constructor(
        address _initOwner,
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initLogoURI,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) ERC721(_name, _symbol) {
        require(
            _initOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(_initOwner);
        royaltyReceiver = _initOwner;

        baseURI = _initBaseURI;
        logoURI = _initLogoURI;

        MAX_SUPPLY = _maxSupply;
        MINT_PRICE = _mintPrice;
    }

    event TokenMinted(uint256 _tokenId, bytes32 _metadataId);
    event BaseURIUpdated(string _baseURI);
    event RoyaltyReceiverUpdated(address _royaltyReceiver);

    modifier isTokenExist(uint256 _tokenId) {
        if (!_exists(_tokenId)) {
            revert NotExistingToken();
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

    function publicMint(bytes32 _metadataId, uint96 _royaltyFraction)
        external
        payable
        isMaxSupplyLimit
    {
        if (msg.value < MINT_PRICE) {
            revert NotEnoughEtherProvided();
        }
        _processMint(_msgSender(), _metadataId, _royaltyFraction);
    }

    function reservedMint(
        address _to,
        bytes32 _metadataId,
        uint96 _royaltyFraction
    ) external onlyOwner isMaxSupplyLimit {
        _processMint(_to, _metadataId, _royaltyFraction);
    }

    function _processMint(
        address _to,
        bytes32 _metadataId,
        uint96 _royaltyFraction
    ) private {
        _currentTokenId.increment();
        uint256 curTokenId = _currentTokenId.current();
        _safeMint(_to, curTokenId);
        _setTokenRoyalty(curTokenId, royaltyReceiver, _royaltyFraction);

        emit TokenMinted(curTokenId, _metadataId);
    }

    function _burn(uint256 _tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(_tokenId);
    }

    function setRoyaltyReceiver(address _royaltyReceiver) external onlyOwner {
        royaltyReceiver = _royaltyReceiver;

        emit RoyaltyReceiverUpdated(_royaltyReceiver);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        if (bytes(_newBaseURI)[bytes(_newBaseURI).length - 1] != bytes1("/"))
            revert NoTrailingSlash();

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

    function setLogoURI(string memory _newLogoURI) public onlyOwner {
        logoURI = _newLogoURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Royalty, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            ERC721Enumerable.supportsInterface(interfaceId);
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
