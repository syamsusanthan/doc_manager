// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IDocumentManager.sol";
import "../access/Ownable.sol";

abstract contract DCCDocumentManager is IDocumentManager, Ownable {
    struct DocumentVersion {
        string uri;
        bytes32 hash;
        uint256 timestamp;
        uint256 validUntil;
    }

    struct Document {
        uint8 docType; // Changed from enum to uint8 for flexibility
        DocumentVersion[] versions;
        bool exists;
    }

    mapping(bytes32 => Document) internal _documents;
    bytes32[] internal _documentNames;

    constructor(address initialOwner) Ownable(initialOwner) {
        // You can add more initialization here later if needed
    }
    function setDocument(
        bytes32 name,
        string memory uri,
        bytes32 documentHash,
        uint8 docType,
        uint256 validUntil
    ) public virtual override onlyOwner {
        require(bytes(uri).length > 0, "Invalid URI");

        if (!_documents[name].exists) {
            _documents[name].exists = true;
            _documents[name].docType = docType;
            _documentNames.push(name);
        }

        // If validUntil is 0, treat as lifetime (no expiry)
        uint256 expiry = (validUntil == 0) ? type(uint256).max : validUntil;

        _documents[name].versions.push(
            DocumentVersion({
                uri: uri,
                hash: documentHash,
                timestamp: block.timestamp,
                validUntil: expiry
            })
        );

        emit DocumentUpdated(name, uri, documentHash, docType, expiry);
    }

    function getDocument(
        bytes32 name
    ) public view override returns (string memory, bytes32, uint256) {
        require(_documents[name].exists, "Document not found");

        uint256 len = _documents[name].versions.length;
        DocumentVersion memory v = _documents[name].versions[len - 1];

        return (v.uri, v.hash, v.timestamp);
    }

    function getAllDocuments() public view override returns (bytes32[] memory) {
        return _documentNames;
    }

    function removeDocument(bytes32 name) public override onlyOwner {
        require(_documents[name].exists, "Document not found");

        delete _documents[name];

        // Efficient removal from array using swap-and-pop
        for (uint256 i = 0; i < _documentNames.length; i++) {
            if (_documentNames[i] == name) {
                _documentNames[i] = _documentNames[_documentNames.length - 1];
                _documentNames.pop();
                break;
            }
        }

        emit DocumentRemoved(name);
    }

    function getDocumentVersions(
        bytes32 name
    ) public view returns (DocumentVersion[] memory) {
        require(_documents[name].exists, "Document not found");
        return _documents[name].versions;
    }

    // Helper function to get document type
    function getDocumentType(bytes32 name) public view returns (uint8) {
        require(_documents[name].exists, "Document not found");
        return _documents[name].docType;
    }
}
