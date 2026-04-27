// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDocumentManager {
    struct DocumentVersion {
        string uri;
        bytes32 hash;
        uint256 timestamp;
        uint256 validUntil;
    }

    struct DocumentDetails {
        string uri;
        bytes32 hash;
        uint256 timestamp;
        uint256 validUntil;
        uint8 docType;
        bool expired;
    }

    event DocumentUpdated(
        bytes32 indexed name,
        string uri,
        bytes32 documentHash,
        uint8 docType,
        uint256 validUntil
    );

    event DocumentRemoved(bytes32 indexed name);

    function setDocument(
        bytes32 name,
        string memory uri,
        bytes32 documentHash,
        uint8 docType,          // 0 = LEGAL, 1 = FINANCIAL, etc. or custom
        uint256 validUntil      // 0 = lifetime, otherwise timestamp
    ) external;

    function getDocument(bytes32 name)
        external
        view
        returns (string memory, bytes32, uint256);

    function getDocumentDetails(bytes32 name)
        external
        view
        returns (DocumentDetails memory);

    function getDocumentVersion(bytes32 name, uint256 index)
        external
        view
        returns (DocumentVersion memory);

    function getDocumentVersionCount(bytes32 name) external view returns (uint256);

    function getDocumentVersions(bytes32 name)
        external
        view
        returns (DocumentVersion[] memory);

    function getDocumentType(bytes32 name) external view returns (uint8);

    function isDocumentExpired(bytes32 name) external view returns (bool);

    function documentExists(bytes32 name) external view returns (bool);

    function removeDocument(bytes32 name) external;

    function getAllDocuments() external view returns (bytes32[] memory);
}
