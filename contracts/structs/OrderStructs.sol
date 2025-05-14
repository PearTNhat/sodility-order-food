// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum OrderStatus { Pending, Confirmed, Cancelled }
enum OrderItemStatus {Success, Cancelled, Shipping }
struct OrderItem {
    uint orderItemId;
    uint foodDetailId;
    uint foodId;
    uint name;
    uint quantity;
    uint price;
    OrderItemStatus status;
}
struct OrderItemRequest {
    uint foodId;
    uint foodDetailId;
    uint name;
    uint quantity;
    uint price;
    string imageUrl;
    
}

struct Order {
    uint orderId;
    address user;
    string userInfo;
    string note;
    OrderItem[] items;
    uint totalAmount;
    OrderStatus status;
    string image;
    uint timestamp;
}
