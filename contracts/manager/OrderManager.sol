// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IOrderManager.sol";
import "../interfaces/IFoodManager.sol";
import "../interfaces/ITableManager.sol";
import "../interfaces/IStaffManager.sol";
import "../access/RoleAccess.sol";
import "hardhat/console.sol";

contract OrderManager is IOrderManager {
    IFoodManager public foodManager;
    ITableManager public tableManager;
    IStaffManager public staffManager;
    RoleAccess public roleAccess;

    uint256 nextOrderItemId = 1;
    mapping(uint256 => Order) public orders;
    uint256 public nextOrderId = 1;
    mapping(address => uint256[]) public userOrders; //track order ids by user

    constructor(
        address _foodManagerAddress,
        address _roleAcces,
        address _tableManager
    ) {
        foodManager = IFoodManager(_foodManagerAddress);
        tableManager = ITableManager(_tableManager);
        roleAccess = RoleAccess(_roleAcces);
    }

    modifier onlyAdmin() {
         require(roleAccess.hasRole(tx.origin,RoleType.ADMIN), "Not admin");
        _;
    }
    modifier onlyAdminOrStaff() {
        require(
            roleAccess.hasRole(tx.origin, RoleType.ADMIN) ||
                roleAccess.hasRole(tx.origin, RoleType.STAFF),
            "Not admin or staff"
        );
        _;
    }

    function setStaffManager(address _staffManagerAddress)
        external
        override
        onlyAdmin
    {
        require(
            _staffManagerAddress != address(0),
            "Invalid staff manager address"
        );
        staffManager = IStaffManager(_staffManagerAddress);
    }

    function createOrder(
        address _user,
        uint256 _foodId,
        string memory _userInfo,
        string memory _note,
        uint256 _tableId,
        OrderItemRequest[] memory _items
    ) public override returns (Order memory) {
        require(_items.length > 0, "Order must contain at least one item");
        Food memory food = foodManager.getFood(_foodId);
        uint256 totalAmount = 0;
        uint256 orderId = nextOrderId++;
        Order storage o = orders[orderId];
        o.orderId = orderId;
        o.user = _user;
        o.userInfo = _userInfo;
        o.name = food.name;
        o.staffAddress = address(0); // nếu staffId = 0 thì k có nhân viên
        o.tableId = _tableId; // k có là 0
        o.note = _note;
        o.imgage = food.imageUrl[0];
        o.status = OrderStatus.Pending;
        o.timestamp = block.timestamp;

        for (uint256 i = 0; i < _items.length; i++) {
            FoodDetail memory foodDetail = foodManager
                .getFoodDetailByFoodId_FoodDetailId(
                    _foodId,
                    _items[i].foodDetailId
                );
            totalAmount += foodDetail.price * _items[i].quantity;
            foodManager.increaseSoldQuantiy(
                _foodId,
                foodDetail.foodDetailId,
                _items[i].quantity
            );
            o.items.push(
                OrderItem({
                    orderItemId: nextOrderItemId++,
                    foodDetailId: _items[i].foodDetailId,
                    foodId: _items[i].foodId,
                    quantity: _items[i].quantity,
                    price: foodDetail.price,
                    status: OrderItemStatus.Doing,
                    timestamp: block.timestamp
                })
            );
        }
        o.totalAmount = totalAmount;
        orders[orderId] = o;
        if (_tableId > 0) {
            tableManager.updateStatusTable(_tableId, TableStatus.Booked);
        }
        userOrders[_user].push(orderId);
        emit OrderCreated(orderId, _user, totalAmount, OrderStatus.Pending);
        return o;
    }

    function updateOrderItemStatus(
        uint256 _orderId,
        uint256 _orderItemId,
        OrderItemStatus _newStatus
    ) public override onlyAdminOrStaff {
        require(orders[_orderId].orderId != 0, "Order does not exist");
        require(
            orders[_orderId].items.length != 0,
            "Order item does not exist"
        );
        Order storage order = orders[_orderId];
        bool found = false;
        for (uint256 i = 0; i < order.items.length; i++) {
            // tìm kiếm orderItemId trong đó xem =  truyền vào k
            if (order.items[i].orderItemId == _orderItemId) {
                // Check if cancellation is within 10 minutes
                if (_newStatus == OrderItemStatus.Cancelled) {
                    require(
                        block.timestamp <= order.timestamp + 600,
                        "Cannot cancel order item after 10 minutes"
                    );
                }
                require(
                    order.items[i].status != OrderItemStatus.Success,
                    "Order item already marked as success. Cannot update"
                );
                require(
                    order.items[i].status != OrderItemStatus.Cancelled,
                    "Order item already marked as cancelled. Cannot update"
                );
                order.items[i].status = _newStatus;
                OrderItem memory orderItem = order.items[i];
                if (order.items[i].status == OrderItemStatus.Cancelled) {
                    if (_newStatus != OrderItemStatus.Success) {
                        // foodManager.increaseQuantiy(orderItem.foodId, orderItem.foodDetailId, orderItem.quantity);
                        foodManager.reduceSoldQuantiy(
                            orderItem.foodId,
                            orderItem.foodDetailId,
                            orderItem.quantity
                        );
                    }
                    order.totalAmount -= orderItem.price;
                }
                // nếu thành công thì cho đánh giá food.
                if (_newStatus == OrderItemStatus.Success) {
                    foodManager.addRaingWhenOrderSuccess(
                        _orderId,
                        orderItem.foodId
                    );
                }
                found = true;
                break;
            }
        }
        require(found, "Order item not found");
        emit OrderItemStatusUpdated(_orderId, _orderItemId, _newStatus);
    }

    function getOrdersByStatus(OrderStatus _status)
        public
        view
        override
        returns (Order[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 1; i < nextOrderId; i++) {
            if (orders[i].status == _status) {
                count++;
            }
        }

        Order[] memory result = new Order[](count);
        uint256 index = 0;
        for (uint256 i = 1; i < nextOrderId; i++) {
            if (orders[i].status == _status) {
                result[index++] = orders[i];
            }
        }
        return result;
    }

    // nếu cancled thì hoàn lại hàng sp nếu confirm r thì k cho hủy
    function updateOrderStatus(uint256 _orderId, OrderStatus _status)
        public
        override
        onlyAdminOrStaff
    {
        Order memory tempOrder = orders[_orderId];
        require(tempOrder.orderId != 0, "Order does not exist");
        require(
            tempOrder.status != OrderStatus.Confirmed,
            "Order already marked as confirm. Can not update"
        );
        require(
            tempOrder.status != OrderStatus.Cancelled,
            "Order already cancelled as confirm. Can not update"
        );
        for (uint256 i = 0; i < tempOrder.items.length; i++) {
            // nếu item cancel trc đó r
            if (tempOrder.items[i].status == OrderItemStatus.Cancelled)
                continue;
            if (_status == OrderStatus.Cancelled) {
                tempOrder.items[i].status = OrderItemStatus.Cancelled;
            }
            foodManager.reduceSoldQuantiy(
                tempOrder.items[i].foodId,
                tempOrder.items[i].foodDetailId,
                tempOrder.items[i].quantity
            );
            // foodManager.increaseQuantiy(
            //     tempOrder.items[i].foodId,
            //     tempOrder.items[i].foodDetailId,
            //     tempOrder.items[i].quantity
            // );
        }
        if (tempOrder.tableId > 0) {
            tableManager.updateStatusTable(tempOrder.tableId, TableStatus.Free);
        }
        // khi 1 đơn hàng thành công thì cho khách hàng đó đc đánh giá staff
        if (
            tempOrder.status == OrderStatus.Success &&
            tempOrder.staffAddress != address(0)
        ) {
            staffManager.addRaingWhenOrderSuccess(
                tempOrder.staffAddress,
                tempOrder.orderId
            );
        }
        orders[_orderId].status = _status;
        emit OrderUpdated(_orderId, _status);
    }

    function getUserOrders(address _user)
        public
        view
        override
        returns (uint256[] memory)
    {
        return userOrders[_user];
    }

    function addStaffForOrder(uint256 orderId, address staffAddress)
        public
        onlyAdmin
    {
        require(orders[orderId].orderId != 0, "OrderId does not exist");
        orders[orderId].staffAddress = staffAddress;
    }

    function addTableForOrder(uint256 _orderId, uint256 _tableId)
        public
        onlyAdmin
    {
        require(orders[_orderId].orderId != 0, "OrderId does not exist");
        orders[_orderId].tableId = _tableId;
    }
}
