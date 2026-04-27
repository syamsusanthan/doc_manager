// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @dev Constructor allows setting a custom owner.
     * If `initialOwner` is address(0), then msg.sender (deployer) becomes the owner.
     */
    constructor(address initialOwner) {
        address _owner = (initialOwner == address(0)) ? msg.sender : initialOwner;
        require(_owner != address(0), "Owner cannot be zero address");
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}
