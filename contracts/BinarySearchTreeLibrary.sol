// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./BinarySearchTreeContractExample.sol";

//import "hardhat/console.sol";

/*
* @title It stores sorted uint except 0: {1, 2, ...}.
* @dev It saved space by abusing index as node value and store it in the mapping.
* @dev This library if for "jump" call (in order to be more gas efficient, than delegate call as it is in
* @dev  external libs),
* @dev  Thus, all methods to be used are internal.
*
* @dev # Another Realisation Suggestion:
*
* @dev Maybe cheaper to mark node as deleted.
* @dev  Thus, we could store even 0 values and we could not go too deep in recursion.
*
* @dev Maybe better to create library only for keys in the trees and to store
* @dev  mappings of actual objects in the contract. By pre-pushing already sorted keys to
* @dev  the tree in order to perform different lookups and deletions on that objects.
*/
library BinarySearchTreeLibrary {
    struct Node {
        uint leftValue;
        uint rightValue;
    }

    struct BinarySearchTree {
        uint rootValue;
        mapping(uint => Node) valueToNode;
    }

    uint constant private ZERO_NODE_VALUE = uint(0);

    function push(BinarySearchTree storage self, uint newValue) internal {
        Node memory newNode = Node(ZERO_NODE_VALUE, ZERO_NODE_VALUE);

        if (self.rootValue == ZERO_NODE_VALUE) {
            self.rootValue = newValue;
            self.valueToNode[newValue] = newNode;
        } else {
            // TODO: If value already exists: early pass.
            _applyToLeaf(self, newValue, self.rootValue);
        }
    }

    function remove(BinarySearchTree storage self, uint value) internal {
        _delete(self, value, self.rootValue);
    }

    function has(BinarySearchTree storage self, uint value) internal view returns (bool _has){
        uint rootValue = self.rootValue;
        if (rootValue == value) {
            return true;
        }
        return _hasSubTreeValue(self, value, rootValue);
    }

    /*
    * @title Get the smallest tree value.
    */
    function getMin(BinarySearchTree storage self) internal view returns (uint _min) {
        (uint lastValue, uint parentValue) = _getMin(self, self.rootValue);
        return lastValue;
    }

    function _delete(
        BinarySearchTree storage self,
        uint valueToDelete,
        uint rootValue
    ) private returns (uint _root) {
        uint parentValue = 0;

        // From where to start search.
        uint curr = rootValue;
        Node memory currentNode = self.valueToNode[curr];

        // Search value in the tree and set its parentValue.
        while (curr != ZERO_NODE_VALUE && curr != valueToDelete) {
            parentValue = curr;

            currentNode = self.valueToNode[curr];
            if (valueToDelete < curr) {
                curr = currentNode.leftValue;
            }
            else {
                curr = currentNode.rightValue;
            }
        }

        // Upd current node.
        currentNode = self.valueToNode[curr];

        // Early return if no key.
        if (curr == ZERO_NODE_VALUE) {
            return rootValue;
        }

        Node storage parentNode = self.valueToNode[parentValue];

        // 1. Node to be deleted  is a leaf node.
        if (currentNode.leftValue == ZERO_NODE_VALUE && currentNode.rightValue == ZERO_NODE_VALUE) {
            // Set parent left/right child to None.
            if (curr != rootValue) {
                if (parentNode.leftValue == curr) {
                    parentNode.leftValue = ZERO_NODE_VALUE;
                } else {
                    parentNode.rightValue = ZERO_NODE_VALUE;
                }
            } else {
                // If the tree has only a root node, set it to None.
                self.rootValue = ZERO_NODE_VALUE;
            }
        } else if (currentNode.leftValue != ZERO_NODE_VALUE && currentNode.rightValue != ZERO_NODE_VALUE) {
            // 2. Node has two children.

            // Find its inorder successor.
            (uint successor, uint _successorParent) = _getMin(self, currentNode.rightValue);

            // Store successor value.
            uint val = successor;
            // Recursively delete the successor at most one child (right child).
            _delete(self, val, _successorParent);
            // copy value of the successor to the current node
            if (parentNode.leftValue == curr) {
                parentNode.leftValue = successor;
            } else {
                parentNode.rightValue = successor;
            }
        }

        // 3. Node to be deleted has only one child.
        else {
            uint child;
            if (currentNode.leftValue != ZERO_NODE_VALUE) {
                child = currentNode.leftValue;
            } else {
                child = currentNode.rightValue;
            }

            // If the node to be deleted is not a root node, set its parent to its child.
            if (curr != self.rootValue) {
                if (curr == parentNode.leftValue) { // 4 == 4
                    parentNode.leftValue = child;
                } else {
                    parentNode.rightValue = child;
                }
            } else {
                // If the node to be deleted is a root node, then set the root to the child.
                self.rootValue = child;
            }
        }
        // Finally, return 15.000 gas.
        delete self.valueToNode[valueToDelete];
        return self.rootValue;
    }

//    /*
//    @dev Example how to abuse value search of the current binary search tree realisation
//    @dev But only if additional parameter will be added and stored (e.g. exist).
//    @dev Classic search realisation is below.
//    */
//    function hasViaMapping(uint value) external view returns (bool _has) {
//        Node memory node = self.valueToNode[value];
//        return node.exist;
//    }

    function _hasSubTreeValue(
        BinarySearchTree storage self,
        uint _value,
        uint _nodeValue
    ) private view returns (bool _has) {
        Node memory node = self.valueToNode[_nodeValue];

        if ((node.leftValue == _value) || node.rightValue == _value) {
            return true;
        }

        if (node.leftValue < _value) {
            if (node.leftValue == 0) {
                return false;
            } else {
                return _hasSubTreeValue(self, _value, node.leftValue);
            }
        } else {
            if (node.rightValue == 0) {
                return false;
            } else {
                return _hasSubTreeValue(self, _value, node.rightValue);
            }
        }
    }

    /*
    * @dev It moves down to a leaf with the value, and apply one of the available methods.
    */
    function _applyToLeaf(BinarySearchTree storage self, uint newValue, uint parentValue) private {
        Node memory parentNode = self.valueToNode[parentValue];
        if (newValue < parentValue) {
            uint parentNodeLeftValue = parentNode.leftValue;
            if (parentNodeLeftValue == ZERO_NODE_VALUE) {
                _createLeaf(self, parentValue, newValue, true);
            } else {
                _applyToLeaf(self, newValue, parentNodeLeftValue);
            }
        } else {
            uint parentNodeRightValue = parentNode.rightValue;
            if (parentNodeRightValue == ZERO_NODE_VALUE) {
                _createLeaf(self, parentValue, newValue, false);
            } else {
                _applyToLeaf(self, newValue, parentNodeRightValue);
            }
        }
    }

    // Create leaf in the storage.
    function _createLeaf(BinarySearchTree storage self, uint _parentValue, uint _newValue, bool _leftLeaf) private {
        Node storage parentNode = self.valueToNode[_parentValue];
        if (_leftLeaf) {
            parentNode.leftValue = _newValue;
        } else {
            parentNode.rightValue = _newValue;
        }
        Node memory newNode = Node(ZERO_NODE_VALUE, ZERO_NODE_VALUE);
        self.valueToNode[_newValue] = newNode;
    }

    function _getMin(
        BinarySearchTree storage self,
        uint fromNodeValue
    ) private view returns (uint _min, uint _parentValue) {
        uint parentValue = 0;
        uint lastValue = 0;
        Node memory currentNode = self.valueToNode[fromNodeValue];
        uint currentValue = fromNodeValue;

        while (currentValue != ZERO_NODE_VALUE) {
            parentValue = lastValue;
            lastValue = currentValue;
            currentValue = currentNode.leftValue;
            currentNode = self.valueToNode[currentValue];
        }
        return (lastValue, parentValue);
    }
}
