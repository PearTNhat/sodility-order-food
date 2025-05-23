// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./access/RoleAccess.sol";
import "./structs/FoodStructs.sol";
import "./interfaces/IFoodManager.sol";
import "./interfaces/ICategoryManager.sol";
import "./interfaces/ITableManager.sol";
import "./interfaces/IOrderManager.sol";
import "./interfaces/IStaffManager.sol";
import "./interfaces/IStaffRatingManager.sol";
import "./interfaces/IFoodRatingManager.sol";

import "hardhat/console.sol";
contract FoodApp {
    RoleAccess public roleAccess;

    address public foodManager;
    address public categoryManager;
    address public tableManager;
    address public orderManager;
    address public staffManager;
    address public staffRatingManager;
    address public foodRatingManager;

    constructor(address _roleAccessAddress) {
        roleAccess = RoleAccess(_roleAccessAddress);
    }

    modifier onlyAdmin() {
        require(roleAccess.hasRole(msg.sender, RoleType.ADMIN), "Not admin");
        _;
    }
    modifier onlyAdminOrStaff() {
        require(
            roleAccess.hasRole(msg.sender, RoleType.ADMIN) ||
                roleAccess.hasRole(msg.sender, RoleType.STAFF),
            "Not admin or staff"
        );
        _;
    }

    function getOwner() public view returns (address) {
        return roleAccess.getOwner();
    }

    function getCurrentUser() public view returns (address) {
        return msg.sender;
    }

    function addAdminRole(address _address) public {
        roleAccess.assignRole(_address, 1);
    }

    function addStaffRole(address _address) public {
        roleAccess.assignRole(_address, 2);
    }

    function setFoodManager(address _foodManager) external onlyAdmin {
        require(_foodManager != address(0), "Invalid address");
        foodManager = _foodManager;
    }

    function setCategory(address _categoryManager) external onlyAdmin {
        require(_categoryManager != address(0), "Invalid address");
        categoryManager = _categoryManager;
    }

    function setTableManager(address _tableManager, address _orderManager)
        external
        onlyAdmin
    {
        require(_tableManager != address(0), "Invalid address");
        require(_orderManager != address(0), "Invalid address");
        tableManager = _tableManager;
        ITableManager(tableManager).setOrderManager(_orderManager);
    }

    function setOrderManager(
        address _orderManager,
        address _staffManagerAddress
    ) external onlyAdmin {
        require(_orderManager != address(0), "Invalid address");
        require(_staffManagerAddress != address(0), "Invalid address");
        orderManager = _orderManager;
        IOrderManager(orderManager).setStaffManager(_staffManagerAddress);
    }

    function setStaffManager(address _staffManager) external onlyAdmin {
        require(_staffManager != address(0), "Invalid address");
        staffManager = _staffManager;
    }

    function setStaffRatingManager(
        address _staffRatingManager,
        address _staffManager
    ) external onlyAdmin {
        require(_staffManager != address(0), "Invalid address");
        require(_staffRatingManager != address(0), "Invalid address");
        staffRatingManager = _staffRatingManager;
        IStaffRatingManager(_staffRatingManager).setStaffManager(_staffManager);
    }

    function initFoodRatingManager(
        address _foodRatingManager,
        address _foodManager
    ) external onlyAdmin {
        require(_foodRatingManager != address(0), "FoodRatingManager not set");
        require(_foodRatingManager != address(0), "Invalid address");
        foodRatingManager = _foodRatingManager;
        IFoodRatingManager(_foodRatingManager).setFoodManager(_foodManager);
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
        IFoodManager(foodManager).createFood(
            foodId,
            name,
            description,
            categoryId,
            imageUrl,
            fd
        );
    }

    function updateFood(
        uint256 foodId,
        string memory name,
        string memory description,
        uint256 categoryId,
        string[] memory imageUrl
    ) external onlyAdmin {
        IFoodManager(foodManager).updateFood(
            foodId,
            name,
            description,
            categoryId,
            imageUrl
        );
    }

    function deleteFood(uint256 foodId) external onlyAdmin {
        IFoodManager(foodManager).deleteFood(foodId);
    }

    function addFoodDetails(uint256 foodId, UpdateFoodDetail[] memory details)
        external
        onlyAdmin
    {
        IFoodManager(foodManager).addFoodDetails(foodId, details);
    }

    function updateFoodDetail(
        uint256 foodId,
        uint256 foodDetailId,
        UpdateFoodDetail memory newDetail
    ) external onlyAdmin {
        IFoodManager(foodManager).updateFoodDetail(
            foodId,
            foodDetailId,
            newDetail
        );
    }

    function deleteFoodDetail(uint256 foodId, uint256 foodDetailId)
        external
        onlyAdmin
    {
        IFoodManager(foodManager).deleteFoodDetail(foodId, foodDetailId);
    }

    function getFoodDetails(uint256 foodId)
        external
        view
        returns (FoodDetail[] memory)
    {
        return IFoodManager(foodManager).getFoodDetails(foodId);
    }

    function getFood(uint256 foodId) external view returns (Food memory) {
        return IFoodManager(foodManager).getFood(foodId);
    }

    function getAllFoods() external view returns (FoodWithDetails[] memory) {
        return IFoodManager(foodManager).getAllFoods();
    }

    function getHiddenFoods() external view returns (FoodWithDetails[] memory) {
        return IFoodManager(foodManager).getHiddenFoods();
    }

    // thêm
    function getHiddenFoodDetails() external returns (FoodDetail[] memory) {
        return IFoodManager(foodManager).getHiddenFoodDetails();
    }

    // thêm
    function setFoodDetailHidden(
        uint256 _foodId,
        uint256 _foodDetailId,
        bool _hidden
    ) external {
        IFoodManager(foodManager).setFoodDetailHidden(
            _foodId,
            _foodDetailId,
            _hidden
        );
    }

    function setFoodVisibility(uint256 _foodId, bool _hidden) public onlyAdmin {
        IFoodManager(foodManager).setFoodVisibility(_foodId, _hidden);
    }

    // CategoryManager
    function createCategory(uint256 categoryId, string memory name)
        external
        onlyAdmin
    {
        require(
            address(categoryManager) != address(0),
            "CategoryManager not deployed"
        );
        ICategoryManager(categoryManager).createCategory(categoryId, name);
    }

    function getCategory(uint256 categoryId)
        external
        view
        returns (Category memory)
    {
        require(
            address(categoryManager) != address(0),
            "CategoryManager not deployed"
        );
        return ICategoryManager(categoryManager).getCategory(categoryId);
    }

    function updateCategory(uint256 categoryId, string memory newName)
        external
        onlyAdmin
    {
        require(
            address(categoryManager) != address(0),
            "CategoryManager not deployed"
        );
        ICategoryManager(categoryManager).updateCategory(categoryId, newName);
    }

    function deleteCategory(uint256 categoryId) external onlyAdmin {
        require(
            address(categoryManager) != address(0),
            "CategoryManager not deployed"
        );
        ICategoryManager(categoryManager).deleteCategory(categoryId);
    }

    function getAllCategories() external view returns (Category[] memory) {
        require(
            address(categoryManager) != address(0),
            "CategoryManager not deployed"
        );
        return ICategoryManager(categoryManager).getAllCategories();
    }

    // Order
    function createOrder(
        address _user,
        uint256 _foodId,
        string memory _userInfo,
        string memory _note,
        uint256 _tableId,
        OrderItemRequest[] memory _items
    ) external returns (Order memory) {
        return
            IOrderManager(orderManager).createOrder(
                _user,
                _foodId,
                _userInfo,
                _note,
                _tableId,
                _items
            );
    }

    function updateOrderItemStatus(
        uint256 _orderId,
        uint256 _orderItemId,
        OrderItemStatus _newStatus
    ) external onlyAdminOrStaff {
        IOrderManager(orderManager).updateOrderItemStatus(
            _orderId,
            _orderItemId,
            _newStatus
        );
    }

    function getOrdersByStatus(OrderStatus _status)
        external
        view
    onlyAdminOrStaff
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
    function getAllTables() external view returns (Table[] memory) {
        return ITableManager(tableManager).getAllTables();
    }
    function addTable(
        uint256 _row,
        uint256 _col,
        string memory _qrUrl
    ) external onlyAdmin returns (uint256) {
        return ITableManager(tableManager).addTable(_row, _col, _qrUrl);
    }

    function updateTable(
        uint256 _tableId,
        uint256 _row,
        uint256 _col,
        string memory _qrUrl
    ) external {
        ITableManager(tableManager).updateTable(_tableId, _row, _col, _qrUrl);
    }

    function editTable(
        uint256 _tableId,
        uint256 _row,
        uint256 _col
    ) external onlyAdmin {
        ITableManager(tableManager).editTable(_tableId, _row, _col);
    }

    function deleteTable(uint256 _tableId) external onlyAdmin {
        ITableManager(tableManager).deleteTable(_tableId);
    }

    function getTableById(uint256 _tableId)
        external
        view
        returns (Table memory)
    {
        return ITableManager(tableManager).getTableById(_tableId);
    }

    function addTableToOrder(uint256 _orderId, uint256 _tableId)
        external
        onlyAdmin
    {
        ITableManager(tableManager).addTableToOrder(_orderId, _tableId);
    }

    function updateStatusTable(uint256 _tableId, TableStatus _status)
        external
        onlyAdminOrStaff
    {
        ITableManager(tableManager).updateStatusTable(_tableId, _status);
    }

    // Staff
    function addStaff(
        address _staffId,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external onlyAdmin {
        IStaffManager(staffManager).addStaff(_staffId, _name, _dob, _phone);
    }

    function getStaff(address _staffId) external view returns (Staff memory) {
        return IStaffManager(staffManager).getStaff(_staffId);
    }

    function updateStaffInfo(
        address _staffId,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external onlyAdmin {
        IStaffManager(staffManager).updateStaffInfo(
            _staffId,
            _name,
            _dob,
            _phone
        );
    }

    // thêm
    function getAllStaffs() external returns (Staff[] memory) {
        return IStaffManager(staffManager).getAllStaffs();
    }

    function addStaffToOrder(uint256 _orderId, address _staffId)
        external
        onlyAdmin
    {
        IStaffManager(staffManager).addStaffToOrder(_orderId, _staffId);
    }

    // Các hàm FoodRatingManager
    function addFoodRating(
        uint256 foodId,
        uint256 orderId,
        string[] memory imgs,
        string calldata content,
        uint8 stars
    ) external {
        IFoodRatingManager(foodRatingManager).addFoodRating(
            foodId,
            orderId,
            imgs,
            content,
            stars
        );
    }

    function getFoodRatingsByFoodId(uint256 foodId)
        external
        view
        returns (FoodRating[] memory)
    {
        return
            IFoodRatingManager(foodRatingManager).getFoodRatingsByFoodId(
                foodId
            );
    }

    function updateFoodRating(
        uint256 ratingId,
        string calldata content,
        uint8 stars
    ) external {
        IFoodRatingManager(foodRatingManager).updateFoodRating(
            ratingId,
            content,
            stars
        );
    }

    function deleteFoodRating(uint256 ratingId) external {
        IFoodRatingManager(foodRatingManager).deleteFoodRating(ratingId);
    }

    // staff rating
    function addStaffRating(
        address staffAddress,
        uint256 _orderId,
        string calldata content,
        string[] memory imgs,
        uint8 stars
    ) external {
        IStaffRatingManager(staffRatingManager).addStaffRating(
            staffAddress,
            _orderId,
            content,
            imgs,
            stars
        );
    }

    function getStaffRatingsByStaffId(address staffId)
        external
        view
        returns (StaffRating[] memory)
    {
        return
            IStaffRatingManager(staffRatingManager).getStaffRatingsByStaffId(
                staffId
            );
    }

    function updateStaffRating(
        uint256 ratingId,
        string calldata content,
        uint8 stars
    ) external {
        IStaffRatingManager(staffRatingManager).updateStaffRating(
            ratingId,
            content,
            stars
        );
    }

    function deleteStaffRating(uint256 ratingId) external {
        IStaffRatingManager(staffRatingManager).deleteStaffRating(ratingId);
    }
}
