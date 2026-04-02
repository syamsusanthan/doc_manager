// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDocumentManager {
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

    function removeDocument(bytes32 name) external;

    function getAllDocuments() external view returns (bytes32[] memory);
}