// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../structs/CategoryStructs.sol"; // Import struct Category

interface ICategoryManager {
    event CategoryCreated(uint categoryId, string name);
    event CategoryUpdated(uint categoryId, string newName);
    event CategoryDeleted(uint categoryId);

    function createCategory(uint categoryId, string memory name) external;
    function getCategory(uint categoryId) external view returns (Category memory);
    function addFoodIdToCategory (uint categoryId,uint foodId)  external ;
    function updateCategory(uint categoryId, string memory newName) external;
    function deleteCategory(uint categoryId) external;
    function getAllCategories() external view returns (Category[] memory);
}