// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFoodManager.sol";
import "../structs/FoodStructs.sol";
import "../access/RoleAccess.sol";
import "../interfaces/ICategoryManager.sol";
import "hardhat/console.sol";

contract FoodManager is IFoodManager {
    ICategoryManager public categoryManager;
    RoleAccess public roleAccess;

    uint256 public nextFoodId = 1;
    uint256 public nextFoodDetailId = 1;
    mapping(uint256 => Food) private foods;
    mapping(uint256 => FoodDetail[]) private foodDetails;
    uint256[] private foodIds;

    // orderId -> [foodId] khi muốn đánh giá phải có orderId, foodId, nếu có thì xóa foodId r đánh giá
    mapping(uint => uint[]) public orderFoodRatings;

    constructor(address _categoryManagerAddress, address _roleAcces) {
        categoryManager = ICategoryManager(_categoryManagerAddress); // Khởi tạo CategoryManager
        roleAccess = RoleAccess(_roleAcces);
    }

    modifier onlyAdmin() {
         require(roleAccess.hasRole(tx.origin,RoleType.ADMIN), "Not admin");
        _;
    }

    function createFood(
        uint256 _foodId,
        string memory _name,
        string memory _description,
        uint256 _categoryId,
        string[] memory _imageUrl,
        UpdateFoodDetail[] memory _foodDetail
    ) external override onlyAdmin {
        // Kiểm tra xem ID thực phẩm đã tồn tại chưa
        require(foods[_foodId].foodId == 0, "Food with this ID already exists");
        require(
            categoryManager.getCategory(_categoryId).categoryId != 0,
            "Category does not exist"
        );
        uint newQuantity = 0;
        for(uint i = 0 ; i <_foodDetail.length ; i++ ){
            newQuantity+=_foodDetail[i].quantity;
        }
        // Gán ID và lưu trữ thông tin thực phẩm
        Food memory newFood = Food({
            foodId: _foodId,
            name: _name,
            description: _description,
            categoryId: _categoryId,
            imageUrl: _imageUrl,
            soldQuantity: 0,
            quantity: newQuantity,
            sumRating: 0,
            countRating: 0,
            isHidden: false
        });
        foods[_foodId] = newFood;
        foodIds.push(_foodId);

        categoryManager.addFoodIdToCategory(_categoryId, _foodId);
        // Lưu trữ chi tiết món ăn
        for (uint256 i = 0; i < _foodDetail.length; i++) {
            FoodDetail memory newFoodDetail = FoodDetail({
                foodDetailId: nextFoodDetailId++, // Gán ID tự động tăng
                size: _foodDetail[i].size,
                soldQuantity: 0,
                quantity: _foodDetail[i].quantity,
                price: _foodDetail[i].price,
                isHidden:false
            });
            foodDetails[_foodId].push(newFoodDetail);
        }

        // Phát sinh sự kiện FoodCreated
        emit FoodCreated(_foodId, _name, _description, _categoryId, _imageUrl);
    }

    function updateFood(
        uint256 _foodId,
        string memory _name,
        string memory _description,
        uint256 _categoryId,
        string[] memory _imageUrl
    ) external override onlyAdmin {
        require(foods[_foodId].foodId != 0, "Food does not exist");
        require(
            categoryManager.getCategory(_categoryId).categoryId != 0,
            "Category does not exist"
        );

        foods[_foodId].name = _name;
        foods[_foodId].description = _description;
        foods[_foodId].categoryId = _categoryId;
        foods[_foodId].imageUrl = _imageUrl;

        emit FoodUpdated(_foodId, _name, _description, _categoryId, _imageUrl);
    }

    function deleteFood(uint256 foodId) external override onlyAdmin {
        require(foods[foodId].foodId != 0, "Food does not exist");
        delete foods[foodId];
        // Xóa chi tiết món ăn liên quan
        delete foodDetails[foodId];
        // Remove from foodIds array
        for (uint256 i = 0; i < foodIds.length; i++) {
            if (foodIds[i] == foodId) {
                foodIds[i] = foodIds[foodIds.length - 1];
                foodIds.pop();
                break;
            }
        }
        emit FoodDeleted(foodId);
    }

    //   chi tiết món của food
    function addFoodDetails(uint256 foodId, UpdateFoodDetail[] memory details)
        external
        override
        onlyAdmin
    {
        //  Require that the food exists.
        require(foods[foodId].foodId != 0, "Food does not exist");
        for (uint256 i = 0; i < details.length; i++) {
            nextFoodDetailId++;

            FoodDetail memory fd = FoodDetail({
                foodDetailId: nextFoodDetailId,
                size: details[i].size,
                soldQuantity: 0,
                quantity: details[i].quantity,
                price: details[i].price,
                isHidden:false
            });
            foods[foodId].quantity += details[i].quantity;
            foodDetails[foodId].push(fd);
        }
        emit FoodDetailsAdded(foodId);
    }

    function updateFoodDetail(
        uint256 foodId,
        uint256 foodDetailId,
        UpdateFoodDetail memory newDetail
    ) external override onlyAdmin {
        require(foods[foodId].foodId != 0, "Food does not exist");
        FoodDetail[] storage foodDetailList = foodDetails[foodId];
        bool found = false;
        for (uint256 i = 0; i < foodDetailList.length; i++) {
            if (foodDetailList[i].foodDetailId == foodDetailId) {
                foodDetailList[i].size = newDetail.size;
                foodDetailList[i].quantity = newDetail.quantity;
                foodDetailList[i].price = newDetail.price;
                found = true;
                emit FoodDetailUpdated(foodId, foodDetailId);
                break;
            }
        }
        require(found, "FoodDetail does not exist");
    }

    function deleteFoodDetail(uint256 foodId, uint256 foodDetailId)
        external
        override
        onlyAdmin
    {
        require(foods[foodId].foodId != 0, "Food does not exist");
        FoodDetail[] storage foodDetailList = foodDetails[foodId];
        bool found = false;
        for (uint256 i = 0; i < foodDetailList.length; i++) {
            if (foodDetailList[i].foodDetailId == foodDetailId) {
                foodDetailList[i] = foodDetailList.length > 1
                    ? foodDetailList[foodDetailList.length - 1]
                    : FoodDetail(0, "", 0, 0, 0,false);
                foodDetailList.pop();
                found = true;
                emit FoodDetailDeleted(foodId, foodDetailId);
                break;
            }
        }
        require(found, "FoodDetail does not exist");
    }

    // user
    function getFoodDetails(uint256 foodId)
        external
        view
        override
        returns (FoodDetail[] memory)
    {
        require(foods[foodId].foodId != 0, "Food does not exist");
        return foodDetails[foodId];
    }

    // bán chạy
    function getAllFoodsSortedBySoldQuantity()
        public
        view
        returns (Food[] memory)
    {
        uint256 length = foodIds.length;
        Food[] memory foodList = new Food[](length);
        for (uint256 i = 0; i < length; i++) {
            foodList[i] = foods[foodIds[i]];
        }

        // Bubble Sort để sắp xếp theo soldQuantity giảm dần
        for (uint256 i = 0; i < length - 1; i++) {
            for (uint256 j = 0; j < length - i - 1; j++) {
                if (foodList[j].soldQuantity < foodList[j + 1].soldQuantity) {
                    // Hoán đổi vị trí
                    Food memory temp = foodList[j];
                    foodList[j] = foodList[j + 1];
                    foodList[j + 1] = temp;
                }
            }
        }
        return foodList;
    }

    // ẩn hiện foood
    function setFoodVisibility(uint _foodId, bool hidden) external onlyAdmin {
        require(foods[_foodId].foodId != 0, "Food does not exist");
        foods[_foodId].isHidden = hidden;
        emit FoodVisibilityChanged(_foodId, hidden);
    }

  function setFoodDetailHidden(uint256 _foodId, uint256 _foodDetailId, bool hidden) external onlyAdmin {
    require(foods[_foodId].foodId != 0, "Food does not exist");

    // Find the FoodDetail with the given foodDetailId
    bool found = false;
    for (uint256 i = 0; i < foodDetails[_foodId].length; i++) {
        if (foodDetails[_foodId][i].foodDetailId == _foodDetailId) {
            foodDetails[_foodId][i].isHidden = hidden;
            found = true;
            break;
        }
    }
    require(found, "FoodDetail does not exist");

    emit FoodDetailVisibilityChanged(_foodId, _foodDetailId, hidden);
}

    // hàm đưa dữ liệu ra bên ngoài
    function getFood(uint256 _foodId)
        external
        view
        override
        returns (Food memory)
    {
        require(foods[_foodId].foodId != 0, "Food does not exist");
        return foods[_foodId];
    }
    // k get ra san phẩm bị ẩn
    function getAllFoods() external view returns (FoodWithDetails[] memory) {
        // Count non-hidden foods
        uint256 count = 0;
        for (uint256 i = 0; i < foodIds.length; i++) {
            uint256 foodId = foodIds[i];
            if (!foods[foodId].isHidden) {
                count++;
            }
        }

        FoodWithDetails[] memory availableFoods = new FoodWithDetails[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < foodIds.length; i++) {
            uint256 foodId = foodIds[i];
            if (!foods[foodId].isHidden) {
                // Count non-hidden FoodDetails for this food
                uint256 detailCount = 0;
                for (uint256 j = 0; j < foodDetails[foodId].length; j++) {
                    if (!foodDetails[foodId][j].isHidden) {
                        detailCount++;
                    }
                }

                // Create a new FoodDetail array with only non-hidden details
                FoodDetail[] memory filteredDetails = new FoodDetail[](detailCount);
                uint256 detailIndex = 0;
                for (uint256 j = 0; j < foodDetails[foodId].length; j++) {
                    if (!foodDetails[foodId][j].isHidden) {
                        filteredDetails[detailIndex] = foodDetails[foodId][j];
                        detailIndex++;
                    }
                }

                availableFoods[index] = FoodWithDetails({
                    food: foods[foodId],
                    foodDetails: filteredDetails
                });
                index++;
            }
        }
        return availableFoods;
    }

    function getHiddenFoods() external view override returns (FoodWithDetails[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < foodIds.length; i++) {
            uint256 foodId = foodIds[i];
            if (foods[foodId].isHidden) {
                count++;
            }
        }
        FoodWithDetails[] memory hiddenFoods = new FoodWithDetails[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < foodIds.length; i++) {
            uint256 foodId = foodIds[i];
            if (foods[foodId].isHidden) {
                hiddenFoods[index] = FoodWithDetails({
                    food: foods[foodId],
                    foodDetails: foodDetails[foodId]
                });
                index++;
            }
        }
        return hiddenFoods;
    }
     // Returns all hidden food details across all foods
    function getHiddenFoodDetails() external view returns (FoodDetail[] memory) {
        // Count total hidden FoodDetails across all foods
        uint256 totalHiddenDetails = 0;
        for (uint256 i = 0; i < foodIds.length; i++) {
            uint256 foodId = foodIds[i];
            for (uint256 j = 0; j < foodDetails[foodId].length; j++) {
                if (foodDetails[foodId][j].isHidden) {
                    totalHiddenDetails++;
                }
            }
        }
        // Create an array to store all hidden FoodDetails
        FoodDetail[] memory hiddenDetails = new FoodDetail[](totalHiddenDetails);
        uint256 index = 0;
        for (uint256 i = 0; i < foodIds.length; i++) {
            uint256 foodId = foodIds[i];
            for (uint256 j = 0; j < foodDetails[foodId].length; j++) {
                if (foodDetails[foodId][j].isHidden) {
                    hiddenDetails[index] = foodDetails[foodId][j];
                    index++;
                }
            }
        }
        return hiddenDetails;
    }

    function reduceQuantiy(
        uint256 _foodId,
        uint256 foodDetailId,
        uint256 _quantity
    ) external override {
        console.log("FoodId",foods[_foodId].quantity ,"Quantity", _quantity);
        for (uint256 i = 0; i < foodDetails[_foodId].length; i++) {
            if (foodDetails[_foodId][i].foodDetailId == foodDetailId) {
                require(
                    _quantity < foodDetails[_foodId][i].quantity,
                    "Quantity's food item cannot be smaller than 0"
                );
                foodDetails[_foodId][i].quantity -= _quantity;
                break;
            }
        }
        require(
            foods[_foodId].quantity >= _quantity,
            "Quantity's food cannot be smaller than 0"
        );
        foods[_foodId].quantity -= _quantity;
    }

    function increaseQuantiy(
        uint256 _foodId,
        uint256 foodDetailId,
        uint256 _quantity
    ) external override {
        for (uint256 i = 0; i < foodDetails[_foodId].length; i++) {
            if (foodDetails[_foodId][i].foodDetailId == foodDetailId) {
                foodDetails[_foodId][i].quantity += _quantity;
                break;
            }
        }
        foods[_foodId].quantity += _quantity;
    }

    function increaseSoldQuantiy(
        uint256 _foodId,
        uint256 _foodDetailId,
        uint256 _quantity
    ) external override {
        for (uint256 i = 0; i < foodDetails[_foodId].length; i++) {
            if (foodDetails[_foodId][i].foodDetailId == _foodDetailId) {
                foodDetails[_foodId][i].soldQuantity += _quantity;
                break;
            }
        }
        foods[_foodId].soldQuantity += _quantity;
    }

    function reduceSoldQuantiy(
        uint256 _foodId,
        uint256 foodDetailId,
        uint256 _quantity
    ) external override {
        for (uint256 i = 0; i < foodDetails[_foodId].length; i++) {
            if (foodDetails[_foodId][i].foodDetailId == foodDetailId) {
                require(
                    foodDetails[_foodId][i].soldQuantity >= _quantity,
                    "Quantity's food detail cannot be smaller than 0"
                );
                foodDetails[_foodId][i].soldQuantity -= _quantity;
                break;
            }
        }
        require(
            foods[_foodId].soldQuantity >= _quantity,
            "Sold quantity's food cannot be smaller than 0"
        );
        foods[_foodId].soldQuantity -= _quantity;
    }

    function getFoodDetailByFoodId_FoodDetailId(
        uint256 _foodId,
        uint256 _foodDetailId
    ) external view override returns (FoodDetail memory fd) {
        require(foodDetails[_foodId].length > 0, "Invalid foodId");
        for (uint256 i = 0; i < foodDetails[_foodId].length; i++) {
            if (foodDetails[_foodId][i].foodDetailId == _foodDetailId) {
                return foodDetails[_foodId][i];
            }
        }
        revert("FoodDetail not found ___.");
    }

    function updateRatingFood(
        uint256 _foodId,
        uint256 _sumRating,
        uint256 _countRating
    ) public {
        require(foods[_foodId].foodId > 0, "Food does not exist");
        foods[_foodId].sumRating = _sumRating;
        foods[_foodId].countRating = _countRating;
        emit FoodRatingUpdate(_foodId, _sumRating);
    }
    function addRaingWhenOrderSuccess (uint _orderId, uint _foodId ) external override  {
        require( foods[_foodId].foodId != 0,"Food does not exist");
        orderFoodRatings[_orderId].push(_foodId);
    }
    function getFoodInOrder(uint  _foodId, uint _orderId) external view override returns (bool){
        for(uint i = 0 ; i < orderFoodRatings[_orderId].length ;  i++){
            if(orderFoodRatings[_orderId][i]== _foodId ){
                return true;
            }
        }
        return false;
    }
    // mỗi khi đánh giá xong là xóa foodId đó đi
    function removeFoodInOrder (uint  _foodId, uint _orderId) external override {
        for(uint i = 0 ;i < orderFoodRatings[_orderId].length;  i++){
            if (orderFoodRatings[_orderId][i] == _foodId) { // xóa order đồng thời các rating có bắt buộc là vì sao mà không sử dụng for
                orderFoodRatings[_orderId].pop(); // pop xóa phần tử
            }
        }
    }
}