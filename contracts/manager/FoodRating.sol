// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFoodRatingManager.sol";
import "../access/RoleAccess.sol";
import "../interfaces/IFoodManager.sol";

contract FoodRatingManager is IFoodRatingManager {
    RoleAccess public roleAccess;
    IFoodManager public foodManager;
    uint public nextFoodRatingId = 1;
    mapping(uint => FoodRating) public foodRatings;
    mapping(uint => uint[]) public foodIdToRatingIds; // Để lấy tất cả ratings cho một món ăn


    modifier onlyAdmin() {
        require(roleAccess.isAdmin(tx.origin), "You are not admin");  //Sửa lại nếu thư viện RoleAccess có hàm isAdmin
        _;
    }

    constructor(address _roleAccess) {
        roleAccess = RoleAccess(_roleAccess);
    }
    function setFoodManager(address _foodManager) external {
        require(_foodManager != address(0), "Invalid address");
        foodManager = IFoodManager(_foodManager);
    }
    function addFoodRating(uint foodId, string calldata content, uint8 stars) external override returns (uint) {
        require(stars > 0 && stars <= 5, "Stars must be between 1 and 5");
        uint ratingId = nextFoodRatingId++;
        FoodRating storage rating = foodRatings[ratingId];
        rating.id = ratingId;
        rating.reviewer = msg.sender;
        rating.foodId = foodId;
        rating.content = content;
        rating.stars = stars;
        rating.timestamp = block.timestamp;

        foodIdToRatingIds[foodId].push(ratingId);
        Food memory food = foodManager.getFood(foodId);
        uint sumRating = food.sumRating + stars;
        uint countRating = food.countRating+1;
        foodManager.updateRatingFood(foodId,sumRating,countRating);
        emit FoodRatingAdded(ratingId, foodId, msg.sender, stars);
        return ratingId;
    }


    function getFoodRatingsByFoodId(uint foodId) external view override returns (FoodRating[] memory) {
        uint[] storage ratingIds = foodIdToRatingIds[foodId];
        uint count = ratingIds.length;
        FoodRating[] memory ratings = new FoodRating[](count);
        for (uint i = 0; i < count; i++) {
            ratings[i] = foodRatings[ratingIds[i]];
        }
        return ratings;
    }

    function updateFoodRating(uint ratingId, string calldata content, uint8 stars) external override {
        require(foodRatings[ratingId].id != 0, "Rating does not exist");
        // require(msg.sender == foodRatings[ratingId].reviewer, "Only reviewer can update");
        require(stars > 0 && stars <= 5, "Stars must be between 1 and 5");
        uint oldStars =  foodRatings[ratingId].stars ;
        foodRatings[ratingId].content = content;
        foodRatings[ratingId].stars = stars;
         Food memory food = foodManager.getFood(foodRatings[ratingId].foodId);
        uint sumRating = food.sumRating + stars - oldStars;
        uint countRating = food.countRating;
        foodManager.updateRatingFood(foodRatings[ratingId].foodId,sumRating,countRating);
        emit FoodRatingUpdated(ratingId, foodRatings[ratingId].foodId, msg.sender, stars);
    }

    function deleteFoodRating(uint ratingId) external override {
        require(foodRatings[ratingId].id != 0, "Rating does not exist");
        // require(msg.sender == foodRatings[ratingId].reviewer || roleAccess.isAdmin(msg.sender), "Only reviewer or admin can delete"); //Sửa lại nếu thư viện RoleAccess có hàm isAdmin

        // Xóa rating khỏi mapping foodIdToRatingIds
        uint foodId = foodRatings[ratingId].foodId;
        uint oldStars =  foodRatings[ratingId].stars;
        uint[] storage ratingIds = foodIdToRatingIds[foodId];
        for (uint i = 0; i < ratingIds.length; i++) {
            if (ratingIds[i] == ratingId) {
                // Xóa phần tử khỏi mảng (đảm bảo không làm thay đổi thứ tự các phần tử khác nếu cần)
                ratingIds[i] = ratingIds[ratingIds.length - 1];
                ratingIds.pop();
                break;
            }
        }
        Food memory food = foodManager.getFood(foodId);
        uint sumRating = food.sumRating - oldStars;
        uint countRating = food.countRating-1;
        foodManager.updateRatingFood(foodId,sumRating,countRating);
        delete foodRatings[ratingId];
        emit FoodRatingDeleted(ratingId, foodId);
    }

   
}