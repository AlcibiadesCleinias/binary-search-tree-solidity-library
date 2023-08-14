import {expect} from "chai";

import {ethers} from "hardhat";
import {loadFixture} from "@nomicfoundation/hardhat-network-helpers";

import {BinarySearchTreeContractExample} from "../typechain-types";


describe("#BinarySearchTreeContractExample", function () {
  async function deployFixture() {
    const BinarySearchTreeLibraryFactory = await ethers.getContractFactory("BinarySearchTreeContractExample");
    const [owner, addr1, addr2] = await ethers.getSigners();
    const contract = await BinarySearchTreeLibraryFactory.deploy() as BinarySearchTreeContractExample;
    await contract.deployed();
    return { contract, owner, addr1, addr2 };
  }

  describe("#getMin", function () {
    it("It returns min.", async function () {
      const { contract } = await loadFixture(deployFixture);

      let _min = await contract.getMin();
      expect(_min).to.eq(0);

      await contract.push(99);
      _min = await contract.getMin();
      expect(_min).to.eq(99);

      await contract.push(1);
      _min = await contract.getMin();
      expect(_min).to.eq(1);

      await contract.push(2);

      _min = await contract.getMin();
      expect(_min).to.eq(1);
    });
  });

  describe("#has", function () {
    it("It returns true if exists.", async function () {
      const { contract } = await loadFixture(deployFixture);

      await contract.push(3);

      let has = await contract.has(3)
      expect(has).to.eq(true);

      has = await contract.has(999)
      expect(has).to.eq(false);

      await contract.push(999);
    });
  });

  describe("#remove", function () {
    it("It removes.", async function () {
      const { contract } = await loadFixture(deployFixture);

      await contract.push(99);
      await contract.push(4);
      await contract.push(3);

      let has = await contract.has(4)
      expect(has).to.eq(true);

      await contract.remove(4);

      has = await contract.has(4)
      expect(has).to.eq(false);

      let _min = await contract.getMin();
      expect(_min).to.eq(3, "Get min works correctly again.");
    });
  });
});
