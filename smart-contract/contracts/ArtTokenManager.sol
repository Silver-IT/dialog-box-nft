// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ArtToken.sol";

error InvalidCollectionAddress();
error AlreadyRegisteredAddress();
error OutOfPermission();
error Unauthorized();

contract ArtTokenManager is Context, Ownable {
    bytes4 internal constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    address[] private addresses;
    mapping(address => bool) private isRegisteredAddress;
    mapping(address => bool) public authorizedAddresses;

    event CollectionAdded(address _addr);
    event AuthorizationUpdated(address _addr, bool _authorized);

    modifier isAuthorizedAddress(address _addr) {
        if (!authorizedAddresses[_addr]) {
            revert Unauthorized();
        }
        _;
    }

    modifier isValidAddress(address _addr) {
        if (!IERC165(_addr).supportsInterface(INTERFACE_ID_ERC721)) {
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
        isRegisteredAddress[addr] = true;
        addresses.push(addr);

        emit CollectionAdded(addr);
    }

    function getAllAddresses() external view returns (address[] memory) {
        return addresses;
    }

    function addAddress(address _addr) public onlyOwner isValidAddress(_addr) {
        if (isRegisteredAddress[_addr]) {
            revert AlreadyRegisteredAddress();
        }
        isRegisteredAddress[_addr] = true;
        addresses.push(_addr);

        emit CollectionAdded(_addr);
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
