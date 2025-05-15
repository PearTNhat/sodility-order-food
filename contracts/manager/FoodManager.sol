// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFoodManager.sol";
import "../structs/FoodStructs.sol";
import "../access/RoleAccess.sol";
import "../interfaces/ICategoryManager.sol";

contract FoodManager is IFoodManager, RoleAccess {
    ICategoryManager public categoryManager;

    uint256 public nextFoodId = 1;
    uint256 public nextFoodDetailId = 1;
    mapping(uint256 => Food) private foods;
    mapping(uint256 => FoodDetail[]) private foodDetails;
    uint256[] private foodIds;

    constructor(address _categoryManagerAddress) {
        categoryManager = ICategoryManager(_categoryManagerAddress); // Khởi tạo CategoryManager
    }

    function createFood(
        uint256 _foodId,
        string memory _name,
        string memory _description, 
        uint256 _categoryId,
        string[] memory _imageUrl,
        UpdateFoodDetail[] memory _foodDetail
    ) external override {
        // Kiểm tra xem ID thực phẩm đã tồn tại chưa
        require(foods[_foodId].foodId == 0, "Food with this ID already exists");
        require(
            categoryManager.getCategory(_categoryId).categoryId != 0,
            "Category does not exist"
        );

        // Gán ID và lưu trữ thông tin thực phẩm
        Food memory newFood = Food({
            foodId: _foodId,
            name: _name,
            description: _description,
            categoryId: _categoryId,
            imageUrl: _imageUrl,
            sumRating: 0,
            countRating:0
        });
        foods[_foodId] = newFood;
        foodIds.push(_foodId);

        categoryManager.addFoodIdToCategory(_categoryId,_foodId);
        // Lưu trữ chi tiết món ăn
        for (uint256 i = 0; i < _foodDetail.length; i++) {
            FoodDetail memory newFoodDetail = FoodDetail({
                foodDetailId: nextFoodDetailId++, // Gán ID tự động tăng
                size: _foodDetail[i].size,
                quantity: _foodDetail[i].quantity,
                price: _foodDetail[i].price
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
    ) external override {
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

    function deleteFood(uint256 foodId) external override {
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
    {
        //  Require that the food exists.
        require(foods[foodId].foodId != 0, "Food does not exist");
        for (uint256 i = 0; i < details.length; i++) {
            nextFoodDetailId++;

            FoodDetail memory fd = FoodDetail({
                foodDetailId: nextFoodDetailId,
                size: details[i].size,
                quantity: details[i].quantity,
                price: details[i].price
            });
            foodDetails[foodId].push(fd);
        }
        emit FoodDetailsAdded(foodId);
    }

    function updateFoodDetail(
        uint256 foodId,
        uint256 foodDetailId,
        UpdateFoodDetail memory newDetail
    ) external override {
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
    {
        require(foods[foodId].foodId != 0, "Food does not exist");
        FoodDetail[] storage foodDetailList = foodDetails[foodId];
        bool found = false;
        for (uint256 i = 0; i < foodDetailList.length; i++) {
            if (foodDetailList[i].foodDetailId == foodDetailId) {
                foodDetailList[i] = foodDetailList.length > 1
                    ? foodDetailList[foodDetailList.length - 1]
                    : FoodDetail(0, "", 0, 0);
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
// hàm đưa dữ liệu ra bên ngoài
    function getFood(uint256 foodId)
        external
        view
        override
        returns (Food memory)
    {
        require(foods[foodId].foodId != 0, "Food does not exist");
        return foods[foodId];
    }

    function getAllFoods()
        external
        view
        override
        returns (FoodWithDetails[] memory)
    {
        FoodWithDetails[] memory allFoods = new FoodWithDetails[](
            foodIds.length
        );
        for (uint256 i = 0; i < foodIds.length; i++) {
            uint256 foodId = foodIds[i];
            allFoods[i] = FoodWithDetails({
                food: foods[foodId],
                foodDetails: foodDetails[foodId]
            });
        }
        return allFoods;
    }

    function reduceQuantiy (uint _foodId,uint foodDetailId,uint _quantity) external override {
        for(uint i = 0;  i< foodDetails[_foodId].length ; i++ ){
            if(foodDetails[_foodId][i].foodDetailId == foodDetailId){
                require(_quantity < foodDetails[_foodId][i].quantity, "Quantity's food cannot be smaller than 0");
                foodDetails[_foodId][i].quantity -= _quantity;
                break;
            }
        } 
    }
    function increaseQuantiy (uint _foodId,uint foodDetailId,uint _quantity) external override {
        for(uint i = 0;  i< foodDetails[_foodId].length ; i++ ){
            if(foodDetails[_foodId][i].foodDetailId == foodDetailId){
                foodDetails[_foodId][i].quantity += _quantity;
                break;
            }
        } 
    }

   function getFoodDetailByFoodId_FoodDetailId(uint _foodId, uint _foodDetailId) 
    external 
    view 
    override 
    returns (FoodDetail memory fd) 
{
    for (uint i = 0; i < foodDetails[_foodId].length; i++) {
        if (foodDetails[_foodId][i].foodDetailId == _foodDetailId) {
            return foodDetails[_foodId][i];
        }
    }
    revert("FoodDetail not found");
}


}
