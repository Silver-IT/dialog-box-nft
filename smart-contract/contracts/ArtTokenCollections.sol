// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "./ArtToken.sol";

error InvalidCollectionAddress();

contract ArtTokenCollections is Context {
    struct ArtTokenMetadata {
        address creator;
        string name;
        string symbol;
        string imageURL;
    }

    mapping(address => ArtTokenMetadata) addressToMetadata;
    address[] public addresses;

    function deployCollection(
        string memory _name,
        string memory _symbol,
        string memory _imageURL,
        string memory _initBaseURI
    ) external {
        ArtToken collection = new ArtToken(
            _msgSender(),
            _name,
            _symbol,
            _initBaseURI
        );
        address addr = address(collection);
        addresses.push(addr);

        ArtTokenMetadata storage metadata = addressToMetadata[addr];
        metadata.creator = _msgSender();
        metadata.name = _name;
        metadata.symbol = _symbol;
        metadata.imageURL = _imageURL;
    }

    function getCollectionMetadata(address _addr)
        public
        view
        returns (ArtTokenMetadata memory)
    {
        if (addressToMetadata[_addr].creator == address(0)) {
            revert InvalidCollectionAddress();
        }

        return addressToMetadata[_addr];
    }

    function getCollectionAddresses() external view returns (address[] memory) {
        return addresses;
    }
}
