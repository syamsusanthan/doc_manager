// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://raw.githubusercontent.com/syamsusanthan/doc_manager/main/contracts/interfaces/IDocumentManager.sol";
import "https://raw.githubusercontent.com/syamsusanthan/doc_manager/main/contracts/access/Ownable.sol";

abstract contract DCCDocumentManager is IDocumentManager, Ownable {

    enum DocumentType {
        LEGAL,
        FINANCIAL,
        TECHNICAL,
        OTHER
    }

    struct DocumentVersion {
        string uri;
        bytes32 hash;
        uint256 timestamp;
        uint256 validUntil;
    }

    struct Document {
        DocumentType docType;
        DocumentVersion[] versions;
        bool exists;
    }

    mapping(bytes32 => Document) internal _documents;
    bytes32[] internal _documentNames;

    function setDocument(
        bytes32 name,
        string calldata uri,
        bytes32 documentHash
    ) public virtual override onlyOwner {
        require(bytes(uri).length > 0, "Invalid URI");

        if (!_documents[name].exists) {
            _documents[name].exists = true;
            _documents[name].docType = DocumentType.OTHER;
            _documentNames.push(name);
        }

        _documents[name].versions.push(
            DocumentVersion({
                uri: uri,
                hash: documentHash,
                timestamp: block.timestamp,
                validUntil: 0
            })
        );

        emit DocumentUpdated(name, uri, documentHash);
    }

    function getDocument(bytes32 name)
        public
        view
        override
        returns (string memory, bytes32, uint256)
    {
        require(_documents[name].exists, "Not found");

        uint256 len = _documents[name].versions.length;
        DocumentVersion memory v = _documents[name].versions[len - 1];

        return (v.uri, v.hash, v.timestamp);
    }

    function getAllDocuments()
        public
        view
        override
        returns (bytes32[] memory)
    {
        return _documentNames;
    }

    function removeDocument(bytes32 name)
        public
        override
        onlyOwner
    {
        require(_documents[name].exists, "Not found");

        delete _documents[name];

        for (uint256 i = 0; i < _documentNames.length; i++) {
            if (_documentNames[i] == name) {
                _documentNames[i] = _documentNames[_documentNames.length - 1];
                _documentNames.pop();
                break;
            }
        }

        emit DocumentRemoved(name);
    }

    function getDocumentVersions(bytes32 name)
        public
        view
        returns (DocumentVersion[] memory)
    {
        return _documents[name].versions;
    }
}
