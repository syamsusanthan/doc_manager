// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IDocumentManager.sol";
import "../access/Ownable.sol";

abstract contract DCCDocumentManager is IDocumentManager, Ownable {
    struct Document {
        uint8 docType;
        DocumentVersion[] versions;
        bool exists;
    }

    mapping(bytes32 => Document) internal _documents;
    bytes32[] internal _documentNames;

    constructor(address initialOwner) Ownable(initialOwner) {
    }

    function setDocument(
        bytes32 name,
        string memory uri,
        bytes32 documentHash,
        uint8 docType,
        uint256 validUntil
    ) public virtual override onlyOwner {
        require(name != bytes32(0), "Invalid name");
        require(bytes(uri).length > 0, "Invalid URI");
        require(documentHash != bytes32(0), "Invalid hash");
        require(validUntil == 0 || validUntil > block.timestamp, "Invalid expiry");

        if (!_documents[name].exists) {
            _documents[name].exists = true;
            _documentNames.push(name);
        }

        _documents[name].docType = docType;

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

    function getDocumentDetails(
        bytes32 name
    ) public view override returns (DocumentDetails memory) {
        DocumentVersion memory v = _latestVersion(name);

        return DocumentDetails({
            uri: v.uri,
            hash: v.hash,
            timestamp: v.timestamp,
            validUntil: v.validUntil,
            docType: _documents[name].docType,
            expired: _isExpired(v.validUntil)
        });
    }

    function getAllDocuments() public view override returns (bytes32[] memory) {
        return _documentNames;
    }

    function removeDocument(bytes32 name) public virtual override onlyOwner {
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
    ) public view override returns (DocumentVersion[] memory) {
        require(_documents[name].exists, "Document not found");
        return _documents[name].versions;
    }

    function getDocumentVersion(
        bytes32 name,
        uint256 index
    ) public view override returns (DocumentVersion memory) {
        require(_documents[name].exists, "Document not found");
        require(index < _documents[name].versions.length, "Invalid version");
        return _documents[name].versions[index];
    }

    function getDocumentVersionCount(
        bytes32 name
    ) public view override returns (uint256) {
        require(_documents[name].exists, "Document not found");
        return _documents[name].versions.length;
    }

    function getDocumentType(bytes32 name) public view override returns (uint8) {
        require(_documents[name].exists, "Document not found");
        return _documents[name].docType;
    }

    function isDocumentExpired(bytes32 name) public view override returns (bool) {
        DocumentVersion memory v = _latestVersion(name);
        return _isExpired(v.validUntil);
    }

    function documentExists(bytes32 name) public view override returns (bool) {
        return _documents[name].exists;
    }

    function _latestVersion(bytes32 name) internal view returns (DocumentVersion memory) {
        require(_documents[name].exists, "Document not found");

        uint256 len = _documents[name].versions.length;
        return _documents[name].versions[len - 1];
    }

    function _isExpired(uint256 validUntil) internal view returns (bool) {
        return validUntil != type(uint256).max && validUntil < block.timestamp;
    }
}
