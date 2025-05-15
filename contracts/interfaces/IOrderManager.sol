// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../structs/OrderStructs.sol";
interface IOrderManager {
    event OrderCreated(uint orderId, address user, uint totalAmount, OrderStatus status);
    event OrderUpdated(uint orderId, OrderStatus status);
     event OrderItemStatusUpdated(uint orderId, uint orderItemId, OrderItemStatus newStatus); // Thêm sự kiện
    event OrderDeleted(uint orderId);

    function createOrder(
        address _user,
        uint _foodId,
        string memory _userInfo,
        string memory note,
        OrderItemRequest[] memory _items
    ) external returns (Order memory);


    function updateOrderItemStatus(
        uint _orderId,
        uint _orderItemId,
        OrderItemStatus _newStatus
    ) external;
    function getOrdersByStatus(OrderStatus _status)
        external
        view
        returns (Order[] memory);
    function updateOrderStatus(uint _orderId, OrderStatus _status) external;
    function getUserOrders(address _user) external view returns (uint[] memory);

}