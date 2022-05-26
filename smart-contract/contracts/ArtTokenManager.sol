// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ArtToken.sol";

error InvalidCollectionAddress();
error OutOfPermission();
error Unauthorized();

contract ArtTokenManager is Context, Ownable {
    bytes4 internal constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 internal constant INTERFACE_ID_ERC1155 = 0xd9b67a26;

    address[] public addresses;
    mapping(address => bool) public authorizedAddresses;

    event CollectionDeployed(address _addr);
    event AuthorizationUpdated(address _addr, bool _authorized);

    modifier isAuthorizedAddress(address _addr) {
        if (!authorizedAddresses[_addr]) {
            revert Unauthorized();
        }
        _;
    }

    modifier isValidAddress(address _addr) {
        if (
            !IERC165(_addr).supportsInterface(INTERFACE_ID_ERC721) &&
            !IERC165(_addr).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            revert InvalidCollectionAddress();
        }
        _;
    }

    function deployCollection(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initLogoURI,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) external isAuthorizedAddress(_msgSender()) {
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

    function addAddress(address _addr) public onlyOwner isValidAddress(_addr) {
        // Need to take care if the _addr is already added
        addresses.push(_addr);
    }

    function authorizeAddress(address _addr) public onlyOwner {
        authorizedAddresses[_addr] = true;

        emit AuthorizationUpdated(_addr, true);
    }

    function unauthorizeAddress(address _addr) public {
        if (_msgSender() != _addr && _msgSender() != owner()) {
            revert OutOfPermission();
        }

        delete authorizedAddresses[_addr];

        emit AuthorizationUpdated(_addr, false);
    }
}
