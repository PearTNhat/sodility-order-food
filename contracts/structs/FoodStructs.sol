// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Food {
    uint foodId;
    string name;
    string description;
    uint categoryId;
    string[] imageUrl;
    uint sumRating;
    uint countRating;
}

struct FoodDetail {
    uint foodDetailId;
    string size;       // VD: Small, Medium, Large
    uint quantity;     // tồn kho
    uint price;        // giá theo size
}
struct UpdateFoodDetail {
    string size;       
    uint quantity;    
    uint price;  
}
struct FoodWithDetails { // Struct mới để chứa cả Food và FoodDetail
    Food food;
    FoodDetail[] foodDetails;
}