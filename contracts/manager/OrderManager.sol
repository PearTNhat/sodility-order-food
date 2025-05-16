// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IOrderManager.sol";
import "../interfaces/IFoodManager.sol";
import "../interfaces/ITableManager.sol";
import "../access/RoleAccess.sol";

// import "hardhat/console.log";

contract OrderManager is IOrderManager {
    IFoodManager public foodManager;
    ITableManager public tableManager;
    RoleAccess public roleAccess;


    uint256 nextOrderItemId = 1;
    mapping(uint256 => Order) public orders;
    uint256 public nextOrderId = 1;
    mapping(address => uint256[]) public userOrders; //track order ids by user

    constructor(address _foodManagerAddress, address _roleAcces, address _tableManager) {
        foodManager = IFoodManager(_foodManagerAddress);
        tableManager=ITableManager(_tableManager);
        roleAccess = RoleAccess(_roleAcces);
    }

    modifier onlyAdmin() {
        require(roleAccess.isAdmin(msg.sender), "You are not admin");
        _;
    }

    function createOrder(
        address _user,
        uint256 _foodId,
        string memory _userInfo,
        string memory _note,
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
        o.staffId =0; // nếu staffId = 0 thì k có nhân viên
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
            foodManager.reduceQuantiy(
                _foodId,
                _items[i].foodDetailId,
                _items[i].quantity
            );
            foodManager.increaseSoldQuantiy(_foodId,foodDetail.foodDetailId, _items[i].quantity);
            o.items.push(
                OrderItem({
                    orderItemId: nextOrderItemId++,
                    foodDetailId: _items[i].foodDetailId,
                    foodId: _items[i].foodId,
                    quantity: _items[i].quantity,
                    price: foodDetail.price,
                    status: OrderItemStatus.Shipping
                })
            );
        }
        o.totalAmount = totalAmount;
        orders[orderId] = o;
        userOrders[_user].push(orderId);
        emit OrderCreated(orderId, _user, totalAmount, OrderStatus.Pending);
        return o;
    }

    function updateOrderItemStatus(
        uint256 _orderId,
        uint256 _orderItemId,
        OrderItemStatus _newStatus
    ) public override onlyAdmin {
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
                require(
                    order.items[i].status != OrderItemStatus.Success,
                    "Order item already marked as success. Can not update"
                );
                order.items[i].status = _newStatus;
                OrderItem memory orderItem =order.items[i];
                if (_newStatus != OrderItemStatus.Success) {
                    foodManager.increaseQuantiy(orderItem.foodId, orderItem.foodDetailId, orderItem.quantity);
                    foodManager.reduceSoldQuantiy(orderItem.foodId, orderItem.foodDetailId, orderItem.quantity);
                }
                order.totalAmount -= orderItem.price;
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
        onlyAdmin
    {
        Order memory tempOrder = orders[_orderId];
        require(tempOrder.orderId != 0, "Order does not exist");
        require(
            tempOrder.status != OrderStatus.Confirmed,
            "Order already marked as confirm. Can not update"
        );
        for (uint256 i = 0; i < tempOrder.items.length; i++) {
            foodManager.increaseQuantiy(
                tempOrder.items[i].foodId,
                tempOrder.items[i].foodDetailId,
                tempOrder.items[i].quantity
            );
            foodManager.reduceSoldQuantiy(tempOrder.items[i].foodId, tempOrder.items[i].foodDetailId,  tempOrder.items[i].quantity);
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
    function addStaffForOrder(uint orderId, uint staffId) public onlyAdmin {
        require(orders[orderId].orderId != 0, "OrderId does not exist");
        orders[orderId].staffId = staffId;
    }
    function addTableForOrder(uint _orderId, uint _tableId ) public onlyAdmin {
         require(orders[_orderId].orderId != 0, "OrderId does not exist");
         orders[_orderId].tableId = _tableId;
    }
}
