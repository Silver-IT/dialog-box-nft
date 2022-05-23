// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "./ArtToken.sol";

error InvalidCollectionAddress();

contract ArtTokenManager is Context {
    address[] public addresses;

    event CollectionDeployed(address _addr);

    function deployCollection(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initLogoURI,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) external {
        ArtToken collection = new ArtToken(
            _msgSender(),
            _name,
            _symbol,
            _initBaseURI,
            _initLogoURI,
            _maxSupply,
            _mintPrice
        );
        address addr = address(collection);
        addresses.push(addr);

        emit CollectionDeployed(addr);
    }

    function getCollectionAddresses() external view returns (address[] memory) {
        return addresses;
    }
}
