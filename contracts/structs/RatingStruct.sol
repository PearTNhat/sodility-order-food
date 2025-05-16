// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct FoodRating {
    uint id;
    address reviewer;
    uint foodId;
    string content;
    uint8 stars; // 1–5
    uint timestamp;
}

struct StaffRating {
    uint id;
    address reviewer;      // Người đánh giá (user)
    uint staffId;    // Người bị đánh giá (staff)
    string content;
    uint8 stars;           // 1 - 5
    uint timestamp;
}