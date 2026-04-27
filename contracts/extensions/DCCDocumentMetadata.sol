// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/DCCDocumentManager.sol";

abstract contract DCCDocumentMetadata is DCCDocumentManager {
    mapping(bytes32 => mapping(string => string)) internal _metadata;
    mapping(bytes32 => string[]) internal _metadataKeys;
    mapping(bytes32 => mapping(string => bool)) internal _hasMetadataKey;

    event MetadataUpdated(bytes32 indexed name, string key, string value);
    event MetadataRemoved(bytes32 indexed name, string key);

    constructor(address initialOwner) DCCDocumentManager(initialOwner) {}

    function setMetadata(
        bytes32 name,
        string memory key,
        string memory value
    ) public virtual onlyOwner {
        require(_documents[name].exists, "Document not found");
        require(bytes(key).length > 0, "Invalid key");

        if (!_hasMetadataKey[name][key]) {
            _hasMetadataKey[name][key] = true;
            _metadataKeys[name].push(key);
        }

        _metadata[name][key] = value;
        emit MetadataUpdated(name, key, value);
    }

    function getMetadata(bytes32 name, string memory key)
        public
        view
        returns (string memory)
    {
        require(_documents[name].exists, "Document not found");
        return _metadata[name][key];
    }

    function getMetadataKeys(bytes32 name) public view returns (string[] memory) {
        require(_documents[name].exists, "Document not found");
        return _metadataKeys[name];
    }

    function removeMetadata(bytes32 name, string memory key) public virtual onlyOwner {
        require(_documents[name].exists, "Document not found");
        require(_hasMetadataKey[name][key], "Metadata not found");

        delete _metadata[name][key];
        delete _hasMetadataKey[name][key];
        _removeMetadataKey(name, key);

        emit MetadataRemoved(name, key);
    }

    function removeDocument(bytes32 name) public virtual override onlyOwner {
        require(_documents[name].exists, "Document not found");

        string[] memory keys = _metadataKeys[name];
        for (uint256 i = 0; i < keys.length; i++) {
            delete _metadata[name][keys[i]];
            delete _hasMetadataKey[name][keys[i]];
        }
        delete _metadataKeys[name];

        super.removeDocument(name);
    }

    function _removeMetadataKey(bytes32 name, string memory key) internal {
        bytes32 keyHash = keccak256(bytes(key));

        for (uint256 i = 0; i < _metadataKeys[name].length; i++) {
            if (keccak256(bytes(_metadataKeys[name][i])) == keyHash) {
                _metadataKeys[name][i] = _metadataKeys[name][_metadataKeys[name].length - 1];
                _metadataKeys[name].pop();
                break;
            }
        }
    }
}
