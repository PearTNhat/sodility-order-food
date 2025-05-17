// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../structs/RatingStruct.sol";

interface IFoodRatingManager {
    event FoodRatingAdded(uint ratingId, uint foodId, address reviewer, uint8 stars);
    event FoodRatingUpdated(uint ratingId, uint foodId, address reviewer, uint8 stars);
    event FoodRatingDeleted(uint ratingId, uint foodId);
    
    function setFoodManager(address _foodManager) external;
    function addFoodRating(uint foodId, string calldata content, uint8 stars) external returns (uint);
    function updateFoodRating(uint ratingId, string calldata content, uint8 stars) external; // Thường không cho phép sửa rating.
    function deleteFoodRating(uint ratingId) external;  // Thường không cho phép xóa rating.
    function getFoodRatingsByFoodId(uint foodId) external view returns (FoodRating[] memory);
}