// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../structs/FoodStructs.sol";

interface IFoodManager {
    event FoodCreated(
        uint256 foodId,
        string name,
        string description,
        uint256 categoryId,
        string[] imageUrl
    );
    event FoodUpdated(
        uint256 foodId,
        string name,
        string description,
        uint256 categoryId,
        string[] imageUrl
    );
    event FoodDeleted(uint256 foodId);
    event FoodDetailsAdded(uint foodId);
    event FoodDetailUpdated(uint foodId, uint foodDetailId);
    event FoodDetailDeleted(uint foodId, uint foodDetailId);
    event FoodVisibilityChanged(uint _foodId,bool hidden);
    event FoodRatingUpdate(uint _foodId, uint _newTotalRatingSum);

    function createFood(
        uint256 foodId,
        string memory name,
        string memory description,
        uint256 categoryId,
        string[] memory imageUrl,
        UpdateFoodDetail[] memory foodDetail
    ) external;

    function updateFood(
        uint256 foodId,
        string memory name,
        string memory description,
        uint256 categoryId,
        string[] memory imageUrl
    ) external;

    function deleteFood(uint256 foodId) external;

    function addFoodDetails(uint foodId, UpdateFoodDetail[] memory details) external;

    function updateFoodDetail(
        uint foodId,
        uint foodDetailId,
        UpdateFoodDetail memory newDetail
    ) external;

    function deleteFoodDetail(uint foodId, uint foodDetailId) external;

    function getFoodDetails(uint foodId)
        external
        view
        returns (FoodDetail[] memory);

    function getFood(uint foodId) external view returns (Food memory);

    function getAllFoods()
        external
        view
        returns (FoodWithDetails[] memory);
    function setFoodVisibility(uint _foodId, bool hidden) external;
    function reduceQuantiy (uint _foodId,uint foodDetailId,uint _quantity) external;
    function increaseQuantiy (uint _foodId,uint foodDetailId,uint _quantity) external ;
    function increaseSoldQuantiy(
        uint256 _foodId,
        uint256 foodDetailId,
        uint256 _quantity
    ) external;
    function reduceSoldQuantiy(
        uint256 _foodId,
        uint256 foodDetailId,
        uint256 _quantity
    ) external;
    function getFoodDetailByFoodId_FoodDetailId (uint _foodId,uint _foodDetailId) external  returns (FoodDetail memory);

     function updateRatingFood(
        uint256 _foodId,
        uint256 _sumRating,
        uint256 _countRating
    ) external;
}
