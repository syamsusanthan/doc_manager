const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DCCDocumentMetadata", function () {
  const NAME = ethers.id("terms");
  const URI = "ipfs://bafybeigdyrzt";
  const HASH = ethers.keccak256(ethers.toUtf8Bytes("terms-v1"));
  const DOC_TYPE = 1;

  async function deployFixture() {
    const [owner, other, newOwner] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("TestDocumentManager");
    const manager = await Factory.deploy(owner.address);

    return { manager, owner, other, newOwner };
  }

  it("stores and returns the latest document version", async function () {
    const { manager } = await deployFixture();

    await expect(manager.setDocument(NAME, URI, HASH, DOC_TYPE, 0))
      .to.emit(manager, "DocumentUpdated")
      .withArgs(NAME, URI, HASH, DOC_TYPE, ethers.MaxUint256);

    const [uri, hash] = await manager.getDocument(NAME);
    const details = await manager.getDocumentDetails(NAME);

    expect(uri).to.equal(URI);
    expect(hash).to.equal(HASH);
    expect(details.validUntil).to.equal(ethers.MaxUint256);
    expect(details.docType).to.equal(DOC_TYPE);
    expect(details.expired).to.equal(false);
    expect(await manager.getDocumentVersionCount(NAME)).to.equal(1);
  });

  it("keeps document version history", async function () {
    const { manager } = await deployFixture();
    const uriV2 = "ipfs://bafybeifinal";
    const hashV2 = ethers.keccak256(ethers.toUtf8Bytes("terms-v2"));

    await manager.setDocument(NAME, URI, HASH, DOC_TYPE, 0);
    await manager.setDocument(NAME, uriV2, hashV2, 2, 0);

    const firstVersion = await manager.getDocumentVersion(NAME, 0);
    const latest = await manager.getDocumentDetails(NAME);

    expect(firstVersion.uri).to.equal(URI);
    expect(latest.uri).to.equal(uriV2);
    expect(latest.hash).to.equal(hashV2);
    expect(latest.docType).to.equal(2);
    expect(await manager.getDocumentVersionCount(NAME)).to.equal(2);
  });

  it("restricts writes to the owner", async function () {
    const { manager, other } = await deployFixture();

    await expect(
      manager.connect(other).setDocument(NAME, URI, HASH, DOC_TYPE, 0)
    ).to.be.revertedWith("Not owner");
  });

  it("supports ownership transfer", async function () {
    const { manager, owner, newOwner } = await deployFixture();

    await expect(manager.transferOwnership(newOwner.address))
      .to.emit(manager, "OwnershipTransferred")
      .withArgs(owner.address, newOwner.address);

    await manager.connect(newOwner).setDocument(NAME, URI, HASH, DOC_TYPE, 0);
    expect(await manager.documentExists(NAME)).to.equal(true);
  });

  it("stores metadata and removes it with the document", async function () {
    const { manager } = await deployFixture();

    await manager.setDocument(NAME, URI, HASH, DOC_TYPE, 0);
    await expect(manager.setMetadata(NAME, "author", "DCC"))
      .to.emit(manager, "MetadataUpdated")
      .withArgs(NAME, "author", "DCC");

    expect(await manager.getMetadata(NAME, "author")).to.equal("DCC");
    expect(await manager.getMetadataKeys(NAME)).to.deep.equal(["author"]);

    await manager.removeDocument(NAME);
    expect(await manager.documentExists(NAME)).to.equal(false);
    await expect(manager.getMetadata(NAME, "author")).to.be.revertedWith(
      "Document not found"
    );
  });

  it("validates input", async function () {
    const { manager } = await deployFixture();

    await expect(
      manager.setDocument(ethers.ZeroHash, URI, HASH, DOC_TYPE, 0)
    ).to.be.revertedWith("Invalid name");
    await expect(
      manager.setDocument(NAME, "", HASH, DOC_TYPE, 0)
    ).to.be.revertedWith("Invalid URI");
    await expect(
      manager.setDocument(NAME, URI, ethers.ZeroHash, DOC_TYPE, 0)
    ).to.be.revertedWith("Invalid hash");
  });
});
