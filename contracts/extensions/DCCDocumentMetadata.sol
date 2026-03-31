// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/DCCDocumentManager.sol";

abstract contract DCCDocumentMetadata is DCCDocumentManager {

    mapping(bytes32 => mapping(string => string)) internal _metadata;

    function setMetadata(
        bytes32 name,
        string calldata key,
        string calldata value
    ) external onlyOwner {
        require(_documents[name].exists, "Not found");
        _metadata[name][key] = value;
    }

    function getMetadata(bytes32 name, string calldata key)
        external
        view
        returns (string memory)
    {
        return _metadata[name][key];
    }
}