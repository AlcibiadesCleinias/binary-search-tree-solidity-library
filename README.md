# Binary Search Tree in Solidity Library

In order to demonstrate a solidity library realisation of binary search tree algo.

# Library
According to [BinarySearchTreeLibrary.sol](contracts/BinarySearchTreeLibrary.sol) description:
```typescript
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
```

Additionally, hardhat config is designed to run 1k optimizer cycles (gas time amortized gas-efficiency).

# Usage Example
Check out an example contract [BinarySearchTreeLibrary](contracts/BinarySearchTreeLibrary.sol)

# Test
Several tests for main methods in the repo:
[test/BinarySearchTreeContractExample.ts](test/BinarySearchTreeContractExample.ts)
To run - go to the next section.

## Develop Env
Run `npm i`. And then you are able to run tests: `npx hardhat test`

