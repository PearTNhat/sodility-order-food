// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct FoodRating {
    uint id;
    address reviewer;
    string[] image; // cho tối đa 5 ảnh
    uint foodId;
    string content;
    uint8 stars; // 1–5
    uint timestamp;
}

struct StaffRating {
    uint id;
    address reviewer;      // Người đánh giá (user)
    address staffAddress;    // Người bị đánh giá (staff)
    string content;
    string[] image; // cho tối đa 5 ảnh
    uint8 stars;           // 1 - 5
    uint timestamp;
}