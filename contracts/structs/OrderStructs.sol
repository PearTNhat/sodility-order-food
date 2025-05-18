// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum OrderStatus { Success,Confirmed,Pending, Cancelled }
enum OrderItemStatus {Success, Doing, Cancelled }
struct OrderItem {
    uint orderItemId;
    uint foodDetailId;
    uint foodId;
    uint quantity;
    uint price;
    OrderItemStatus status;
    uint timestamp;
}
struct OrderItemRequest {
    uint foodId;
    uint foodDetailId;
    uint quantity;
}
// khi order gọi món khách hàng chọn
// 1. order k có nhân viên thì staffId 0 , tableId 0
// 2. order có nv, staffId != 0
// 3. order có nv, bàn staffId != 0, tableId !=0
struct Order {
    uint orderId;
    address user;
    string userInfo;
    string note;
    string name;
    string imgage;
    address staffAddress; // nếu staffId = 0 thì k có nhân viên
    uint tableId; // bàn được order nếu = 0 là k có bàn
    OrderItem[] items;
    uint totalAmount;
    OrderStatus status;
    uint timestamp;
}
