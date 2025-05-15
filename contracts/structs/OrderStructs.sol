// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum OrderStatus { Pending, Confirmed, Cancelled }
enum OrderItemStatus {Success, Cancelled, Shipping }
struct OrderItem {
    uint orderItemId;
    uint foodDetailId;
    uint foodId;
    uint quantity;
    uint price;
    OrderItemStatus status;
}
struct OrderItemRequest {
    uint foodId;
    uint foodDetailId;
    uint quantity;
}

struct Order {
    uint orderId;
    address user;
    string userInfo;
    string note;
    string name;
    string imgage;
    OrderItem[] items;
    uint totalAmount;
    OrderStatus status;
    uint timestamp;
}
