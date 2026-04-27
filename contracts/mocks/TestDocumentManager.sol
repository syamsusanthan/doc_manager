// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../extensions/DCCDocumentMetadata.sol";

contract TestDocumentManager is DCCDocumentMetadata {
    constructor(address initialOwner) DCCDocumentMetadata(initialOwner) {}
}
