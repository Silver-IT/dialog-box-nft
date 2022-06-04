// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ArtToken.sol";

error InvalidCollectionAddress();
error AlreadyRegisteredAddress();
error OutOfPermission();
error AlreadyAuthorized();
error NotAuthorizedAddress();
error Unauthorized();

contract ArtTokenManager is Context, Ownable {
    bytes4 internal constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    address[] private collections;
    mapping(address => bool) public isRegisteredCollection;
    address[] private addresses;
    mapping(address => bool) public isAuthorizedUser;
    mapping(address => uint256) private addressToIndex;

    event CollectionAdded(address _addr);
    event AuthorizationUpdated(address _addr, bool _authorized);

    modifier isAuthorized() {
        if (!isAuthorizedUser[_msgSender()]) {
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
    ) external isAuthorized {
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
        isRegisteredCollection[addr] = true;
        collections.push(addr);

        emit CollectionAdded(addr);
    }

    function getAllCollections() external view returns (address[] memory) {
        return collections;
    }

    function addCollection(address _addr)
        public
        onlyOwner
        isValidAddress(_addr)
    {
        if (isRegisteredCollection[_addr]) {
            revert AlreadyRegisteredAddress();
        }
        isRegisteredCollection[_addr] = true;
        collections.push(_addr);

        emit CollectionAdded(_addr);
    }

    function getAllAuthorizedAddresses()
        external
        view
        returns (address[] memory)
    {
        return addresses;
    }

    function authorizeAddress(address _addr) public onlyOwner {
        if (isAuthorizedUser[_addr]) {
            revert AlreadyAuthorized();
        }
        isAuthorizedUser[_addr] = true;
        addressToIndex[_addr] = addresses.length;
        addresses.push(_addr);

        emit AuthorizationUpdated(_addr, true);
    }

    function unauthorizeAddress(address _addr) public {
        if (_msgSender() != _addr && _msgSender() != owner()) {
            revert OutOfPermission();
        }

        if (!isAuthorizedUser[_addr]) {
            revert NotAuthorizedAddress();
        }

        uint256 index = addressToIndex[_addr];
        address lastAddress = addresses[addresses.length - 1];
        addresses[index] = lastAddress;
        addressToIndex[lastAddress] = index;

        addresses.pop();
        delete addressToIndex[_addr];
        delete isAuthorizedUser[_addr];

        emit AuthorizationUpdated(_addr, false);
    }
}
