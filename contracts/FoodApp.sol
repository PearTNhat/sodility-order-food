// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./manager/FoodManager.sol";
import "./structs/FoodStructs.sol";
import "./interfaces/IFoodManager.sol"; 
import "./interfaces/ICategoryManager.sol"; 
import "./access/RoleAccess.sol";
import "./interfaces/ITableManager.sol"; 

contract FoodApp is RoleAccess  {
    IFoodManager public foodManager;
    ICategoryManager public categoryManager;
    ITableManager public tableManager; // Add TableManager
    constructor(address _foodManagerAddress, address _categoryManager,address _tableManagerAddress) {
        foodManager = IFoodManager(_foodManagerAddress);
        categoryManager = ICategoryManager(_categoryManager);
        tableManager = ITableManager(_tableManagerAddress); 
    }
// manage food
    function createFood(
        uint256 foodId,
        string memory name,
        string memory description,
        uint256 categoryId,
        string[] memory imageUrl,
        UpdateFoodDetail[] memory fd
    ) external onlyAdmin {
        foodManager.createFood(foodId, name, description, categoryId, imageUrl, fd);
    }

    function updateFood(
        uint256 foodId,
        string memory name,
        string memory description,
        uint256 categoryId,
        string[] memory imageUrl
    ) external onlyAdmin {
        foodManager.updateFood(foodId, name, description, categoryId, imageUrl);
    }

    function deleteFood(uint256 foodId) external onlyAdmin {
        foodManager.deleteFood(foodId);
    }

    function addFoodDetails(uint foodId, UpdateFoodDetail[] memory details) external onlyAdmin {
        foodManager.addFoodDetails(foodId, details);
    }

    function updateFoodDetail(uint foodId, uint foodDetailId, UpdateFoodDetail memory newDetail) external onlyAdmin {
        foodManager.updateFoodDetail(foodId, foodDetailId, newDetail);
    }

    function deleteFoodDetail(uint foodId, uint foodDetailId) external onlyAdmin {
        foodManager.deleteFoodDetail(foodId, foodDetailId);
    }

    function getFoodDetails(uint foodId) external view returns (FoodDetail[] memory) {
        return foodManager.getFoodDetails(foodId);
    }

    function getFood(uint foodId) external view returns (Food memory) {
        return foodManager.getFood(foodId);
    }

    function getAllFoods() external view returns (FoodWithDetails[] memory) {
        return foodManager.getAllFoods();
    }

    //CategoryManager
    function createCategory(uint categoryId, string memory name) external onlyAdmin {
        categoryManager.createCategory(categoryId, name);
    }

    function getCategory(uint categoryId) external view returns (Category memory) {
        return categoryManager.getCategory(categoryId);
    }

    function updateCategory(uint categoryId, string memory newName) external onlyAdmin {
        categoryManager.updateCategory(categoryId, newName);
    }

    function deleteCategory(uint categoryId) external onlyAdmin {
        categoryManager.deleteCategory(categoryId);
    }

    function getAllCategories() external view returns (Category[] memory) {
        return categoryManager.getAllCategories();
    }

    //table
    function addTable(uint _row, uint _col) external onlyAdmin returns (uint) {
        return tableManager.addTable(_row, _col);
    }

    function editTable(uint _tableId, uint _row, uint _col) external onlyAdmin {
        tableManager.editTable(_tableId, _row, _col);
    }

    function deleteTable(uint _tableId) external onlyAdmin {
        tableManager.deleteTable(_tableId);
    }

    function updateStaffTable(uint _tableId, uint _staffId) external onlyAdmin {
        tableManager.updateStaffTable(_tableId, _staffId);
    }
}
