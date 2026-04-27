# DCC Document Manager

Solidity contracts for managing document references, document hashes, version history, expiry timestamps, and key-value metadata on-chain.

The package is designed as a small reusable library that can be inherited by your own contracts.

## Features

- Owner-controlled document creation, versioning, and removal
- Latest document lookup
- Full version history lookup
- Document type support through flexible `uint8` values
- Optional expiry timestamp support
- Key-value metadata extension
- Ownership transfer and renounce support
- Hardhat test setup

## Installation

```bash
npm install @syamsusanthan/doc-manager
```

## Usage

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@syamsusanthan/doc-manager/contracts/extensions/DCCDocumentMetadata.sol";

contract MyDocumentRegistry is DCCDocumentMetadata {
    constructor(address initialOwner) DCCDocumentMetadata(initialOwner) {}
}
```

If `initialOwner` is `address(0)`, the deployer becomes the owner.

## Document Names

Documents are identified by `bytes32` names. A common pattern is to hash a readable label:

```solidity
bytes32 name = keccak256(bytes("terms-and-conditions"));
```

## Main API

### Documents

```solidity
function setDocument(
    bytes32 name,
    string memory uri,
    bytes32 documentHash,
    uint8 docType,
    uint256 validUntil
) public onlyOwner;
```

Adds a new document or appends a new version to an existing document.

- `name`: unique document identifier
- `uri`: off-chain location, such as IPFS, Arweave, HTTPS, or another content URI
- `documentHash`: hash of the document contents
- `docType`: flexible document type, such as `0 = legal`, `1 = financial`, or your own mapping
- `validUntil`: Unix timestamp; use `0` for no expiry

```solidity
function getDocument(bytes32 name)
    public
    view
    returns (string memory uri, bytes32 hash, uint256 timestamp);
```

Returns the latest version in the original compact format.

```solidity
function getDocumentDetails(bytes32 name)
    public
    view
    returns (DocumentDetails memory);
```

Returns latest URI, hash, timestamp, expiry, document type, and expiry status.

```solidity
function getDocumentVersions(bytes32 name)
    public
    view
    returns (DocumentVersion[] memory);
```

Returns all versions for a document.

```solidity
function removeDocument(bytes32 name) public onlyOwner;
```

Removes the document and its version history.

### Metadata

```solidity
function setMetadata(bytes32 name, string memory key, string memory value)
    public
    onlyOwner;
```

Stores metadata for an existing document.

```solidity
function getMetadata(bytes32 name, string memory key)
    public
    view
    returns (string memory);
```

Reads metadata for an existing document.

```solidity
function getMetadataKeys(bytes32 name)
    public
    view
    returns (string[] memory);
```

Returns all metadata keys tracked for a document.

## Development

Install dependencies:

```bash
npm install
```

Compile:

```bash
npm run compile
```

Run tests:

```bash
npm test
```

## Publishing To NPM

Before publishing:

```bash
npm test
npm pack --dry-run
npm publish --access public
```

The published package includes the Solidity source contracts under:

- `contracts/access`
- `contracts/base`
- `contracts/extensions`
- `contracts/interfaces`

Test-only mock contracts are not included in the NPM package.

## Security

This package has tests, but it has not been externally audited. Review the contracts carefully before using them in systems that control valuable assets, legal records, identity data, or other high-impact workflows.

## License

MIT
