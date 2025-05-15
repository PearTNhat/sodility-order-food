// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ICategoryManager.sol";
import "../structs/FoodStructs.sol"; // Import struct Category

contract CategoryManager is ICategoryManager {
    mapping(uint => Category) public categories;
    uint[] private categoryIds;
    mapping(uint => uint[]) public categoryToFoodId;

    function createCategory(uint categoryId, string memory name) external override {
        require(bytes(name).length > 0, "Category name cannot be empty");
        require(categories[categoryId].categoryId == 0, "Category ID already exists"); //prevent overwrite
        Category memory newCategory = Category({categoryId: categoryId, name: name});
        categories[categoryId] = newCategory;
        categoryIds.push(categoryId);
        emit CategoryCreated(categoryId, name);
    }
    function addFoodIdToCategory (uint categoryId,uint foodId)  external override {
        categoryToFoodId[categoryId].push(foodId);
    }

    function getCategory(uint categoryId) external view override returns (Category memory) {
        require(categories[categoryId].categoryId != 0, "Category does not exist");
        return categories[categoryId];
    }

    function updateCategory(uint categoryId, string memory newName) external override {
        require(bytes(newName).length > 0, "Category name cannot be empty");
        require(categories[categoryId].categoryId != 0, "Category does not exist");
        categories[categoryId].name = newName;
        emit CategoryUpdated(categoryId, newName);
    }

    function deleteCategory(uint categoryId) external override {
        require(categories[categoryId].categoryId != 0, "Category does not exist");
        require(categoryToFoodId[categoryId].length != 0, "Category contains food items");
        delete categories[categoryId];

        // Remove from categoryIds array
        for (uint i = 0; i < categoryIds.length; i++) {
            if (categoryIds[i] == categoryId) {
                categoryIds[i] = categoryIds[categoryIds.length - 1];
                categoryIds.pop();
                break;
            }
        }

        emit CategoryDeleted(categoryId);
    }

    function getAllCategories() external view override returns (Category[] memory) {
        Category[] memory allCategories = new Category[](categoryIds.length);
        for (uint i = 0; i < categoryIds.length; i++) {
            allCategories[i] = categories[categoryIds[i]];
        }
        return allCategories;
    }
}