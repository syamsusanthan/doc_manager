// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDocumentManager {

    event DocumentUpdated(bytes32 indexed name, string uri, bytes32 documentHash);
    event DocumentRemoved(bytes32 indexed name);

    function setDocument(
        bytes32 name,
        string memory uri
        bytes32 documentHash
    ) external;

    function getDocument(bytes32 name)
        external
        view
        returns (string memory, bytes32, uint256);

    function removeDocument(bytes32 name) external;

    function getAllDocuments() external view returns (bytes32[] memory);
}
