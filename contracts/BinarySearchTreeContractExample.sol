// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./BinarySearchTreeLibrary.sol";


contract BinarySearchTreeContractExample {

    using BinarySearchTreeLibrary for BinarySearchTreeLibrary.BinarySearchTree;
    BinarySearchTreeLibrary.BinarySearchTree public binarySearchTree;

    function push(uint value) external {
        binarySearchTree.push(value);
    }

    function getMin() external view returns (uint _min) {
        return binarySearchTree.getMin();
    }

    function has(uint value) external view returns (bool _has) {
        return binarySearchTree.has(value);
    }

    function remove(uint value) external {
        return binarySearchTree.remove(value);
    }
}
