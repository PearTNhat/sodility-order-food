"""Creat food """
100, "Pizza Hải sản", "Pizza tôm, mực, phô mai", 1, ["https://img.com/pizza1.png", "https://img.com/pizza2.png"], [ ["Small", 10, 150000], ["Medium", 5, 180000], ["Large", 2, 210000] ]

3. updateFood
100, "Pizza Hải sản đặc biệt", "Có thêm phô mai và sốt cay", 1, ["https://img.com/pizza-updated.png"]

4. addFoodDetails
100, [ ["XL", 3, 240000] ]

5. createOrder

"user_address_here", 100, "Nguyễn Văn A - 0909123456", "Không hành", "https://img.com/order1.png", [ [100, 1, 0, 2, 150000, "https://img.com/food1.png"], [100, 2, 0, 1, 180000, "https://img.com/food2.png"] ]

6. updateOrderItemStatus
1, 1, 1  // → Cập nhật đơn hàng 1, món 1 thành "Confirmed"

7. updateOrderStatus
1, 2  // → Đơn hàng 1 chuyển sang trạng thái Cancelled

8. addTable(uint row, uint col)
1, 1

9. editTable(uint tableId, uint row, uint col)
1, 2, 3

10. updateStaffTable(uint tableId, uint staffId)
1, 101


