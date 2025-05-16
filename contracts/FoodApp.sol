// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./manager/FoodManager.sol";
import "./structs/FoodStructs.sol";
import "./interfaces/IFoodManager.sol";
import "./interfaces/ICategoryManager.sol";
import "./access/RoleAccess.sol";
import "./interfaces/ITableManager.sol";
import "./interfaces/IOrderManager.sol";
contract FoodApp  {
    RoleAccess public roleAccess;

    address public foodManager;
    address public categoryManager;
    address public tableManager;
    address public orderManager;

    constructor(address _roleAccessAddress) {
        roleAccess = RoleAccess(_roleAccessAddress);
    }

    modifier onlyAdmin() {
        require(roleAccess.isAdmin(msg.sender), "You are not admin");
        _;
    }
    function getOwner () view public returns (address owner ){
        return roleAccess.getOwner();
    }
    function addAmin (address _address) public {
        roleAccess.addAdmin(_address);
    }
    function setFoodManager(address _foodManager) external onlyAdmin {
        require(_foodManager != address(0), "Invalid address");
        foodManager = _foodManager;
    }

    function setCategoryManager(address _categoryManager) external onlyAdmin {
        require(_categoryManager != address(0), "Invalid address");
        categoryManager = _categoryManager;
    }

    function setTableManager(address _tableManager) external onlyAdmin {
        require(_tableManager != address(0), "Invalid address");
        tableManager = _tableManager;
    }

    function setOrderManager(address _orderManager) external onlyAdmin {
        require(_orderManager != address(0), "Invalid address");
        orderManager = _orderManager;
    }

    // Manage food
    function createFood(
        uint256 foodId,
        string memory name,
        string memory description,
        uint256 categoryId,
        string[] memory imageUrl,
        UpdateFoodDetail[] memory fd
    ) external onlyAdmin {
        IFoodManager(foodManager).createFood(foodId, name, description, categoryId, imageUrl, fd);
    }

    function updateFood(
        uint256 foodId,
        string memory name,
        string memory description,
        uint256 categoryId,
        string[] memory imageUrl
    ) external onlyAdmin {
        IFoodManager(foodManager).updateFood(foodId, name, description, categoryId, imageUrl);
    }

    function deleteFood(uint256 foodId) external onlyAdmin {
        IFoodManager(foodManager).deleteFood(foodId);
    }

    function addFoodDetails(uint foodId, UpdateFoodDetail[] memory details) external onlyAdmin {
        IFoodManager(foodManager).addFoodDetails(foodId, details);
    }

    function updateFoodDetail(uint foodId, uint foodDetailId, UpdateFoodDetail memory newDetail) external onlyAdmin {
        IFoodManager(foodManager).updateFoodDetail(foodId, foodDetailId, newDetail);
    }

    function deleteFoodDetail(uint foodId, uint foodDetailId) external onlyAdmin {
        IFoodManager(foodManager).deleteFoodDetail(foodId, foodDetailId);
    }

    function getFoodDetails(uint foodId) external view returns (FoodDetail[] memory) {
        return IFoodManager(foodManager).getFoodDetails(foodId);
    }

    function getFood(uint foodId) external view returns (Food memory) {
        return IFoodManager(foodManager).getFood(foodId);
    }

    function getAllFoods() external view returns (FoodWithDetails[] memory) {
        return IFoodManager(foodManager).getAllFoods();
    }

    // CategoryManager
    function createCategory(uint categoryId, string memory name) external onlyAdmin {
        ICategoryManager(categoryManager).createCategory(categoryId, name);
    }

    function getCategory(uint categoryId) external view returns (Category memory) {
        return ICategoryManager(categoryManager).getCategory(categoryId);
    }

    function updateCategory(uint categoryId, string memory newName) external onlyAdmin {
        ICategoryManager(categoryManager).updateCategory(categoryId, newName);
    }

    function deleteCategory(uint categoryId) external onlyAdmin {
        ICategoryManager(categoryManager).deleteCategory(categoryId);
    }

    function getAllCategories() external view returns (Category[] memory) {
        return ICategoryManager(categoryManager).getAllCategories();
    }

    // Order
    function createOrder(
        address _user,
        uint256 _foodId,
        string memory _userInfo,
        string memory _note,
        OrderItemRequest[] memory _items
    ) external returns (Order memory) {
        return IOrderManager(orderManager).createOrder(_user, _foodId, _userInfo, _note, _items);
    }

    function updateOrderItemStatus(
        uint256 _orderId,
        uint256 _orderItemId,
        OrderItemStatus _newStatus
    ) external {
        IOrderManager(orderManager).updateOrderItemStatus(_orderId, _orderItemId, _newStatus);
    }

    function getOrdersByStatus(OrderStatus _status)
        external
        view
        returns (Order[] memory)
    {
        return IOrderManager(orderManager).getOrdersByStatus(_status);
    }

    function updateOrderStatus(uint256 _orderId, OrderStatus _status) external {
        IOrderManager(orderManager).updateOrderStatus(_orderId, _status);
    }

    function getUserOrders(address _user)
        external
        view
        returns (uint256[] memory)
    {
        return IOrderManager(orderManager).getUserOrders(_user);
    }

    // Table
    function addTable(uint _row, uint _col) external onlyAdmin returns (uint) {
        return ITableManager(tableManager).addTable(_row, _col);
    }

    function editTable(uint _tableId, uint _row, uint _col) external onlyAdmin {
        ITableManager(tableManager).editTable(_tableId, _row, _col);
    }

    function deleteTable(uint _tableId) external onlyAdmin {
        ITableManager(tableManager).deleteTable(_tableId);
    }

    function getTableById(uint _tableId) external view returns (Table memory) {
        return ITableManager(tableManager).getTableById(_tableId);
    }
}
