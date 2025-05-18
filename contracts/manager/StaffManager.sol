// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IStaffManager.sol";
import "../interfaces/IOrderManager.sol";
import "../access/RoleAccess.sol";

contract StaffManagement is IStaffManager {
    IOrderManager public orderManager;
    RoleAccess public roleAccess;
    mapping(address => Staff) public staffs;
    address[] private staffAddresses;
    // để xem staff đó đã nhận đơn order nào chưa nếu để đánh giá
    // staffAddress -> orderId
    mapping (address => uint[]) public staffInOrder; 
    constructor(address _orderManagerAddress, address _roleAccess) {
        orderManager = IOrderManager(_orderManagerAddress);
        roleAccess = RoleAccess(_roleAccess);
    }

    modifier onlyAdmin() {
         require(roleAccess.hasRole(tx.origin,RoleType.ADMIN), "Not admin");
        _;
    }
    function addStaff(
        address addressStaff,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external override onlyAdmin {
        require(addressStaff != address(0), "Invalid staff address");
        require(staffs[addressStaff].staffAddress == address(0), "Staff address already exists");
        staffs[addressStaff] = Staff(addressStaff, _name, _dob, _phone, 0, 0,StaffStatus.Free);
        emit StaffAdded(addressStaff, _name);
    }

    function getStaff(address addressStaff)
        external
        view
        override
        returns (Staff memory)
    {
        return staffs[addressStaff];
    }
    function getAllStaffs() external view returns (Staff[] memory) {
        Staff[] memory allStaffs = new Staff[](staffAddresses.length);
        for (uint256 i = 0; i < staffAddresses.length; i++) {
            allStaffs[i] = staffs[staffAddresses[i]];
        }
        return allStaffs;
    }
    function updateStaffInfo(
        address addressStaff,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external override {
        require(staffs[addressStaff].staffAddress != address(0), "Staff address does not exist");
        staffs[addressStaff].name = _name;
        staffs[addressStaff].dob = _dob;
        staffs[addressStaff].phone = _phone;
        emit StaffUpdated(addressStaff, _name);
    }

    function addStaffToOrder(uint256 _orderId, address addressStaff)
        external
        override
        onlyAdmin
    {
        require(staffs[addressStaff].staffAddress != address(0), "Staff address does not exist");
        staffs[addressStaff].status = StaffStatus.Busy;
        orderManager.addStaffForOrder(_orderId, addressStaff);
        emit StaffAddedToOrder(addressStaff, _orderId);
    }

    function updateRatingStaff(
        address addressStaff,
        uint256 _sumRating,
        uint256 _countRating
    ) external onlyAdmin {
        require(staffs[addressStaff].staffAddress != address(0), "Staff does not exist");
        staffs[addressStaff].sumRating = _sumRating;
        staffs[addressStaff].countRating = _countRating;
        emit StaffRatingUpdated(addressStaff, _sumRating, _countRating);
    }
    function addRaingWhenOrderSuccess (address _staffAddress, uint _orderId) external override  {
        require(staffs[_staffAddress].staffAddress == address(0),"Staff does not exist");
        staffInOrder[_staffAddress].push(_orderId);
    }
    function getStaffInOrder(address _staffAddress, uint _orderId) external view override returns (bool){
        for(uint i = 0 ; i < staffInOrder[_staffAddress].length ;  i++){
            if(staffInOrder[_staffAddress][i]== _orderId ){
                return true;
            }
        }
        return false;
    }
    // mỗi khi đánh giá xong là xóa orderId đó đi
    function removeOrderInStaffInOrder (address _staffAddress, uint _orderId) external override {
        for(uint i = 0 ;i < staffInOrder[_staffAddress].length;  i++){
            if (staffInOrder[_staffAddress][i] == _orderId) { // xóa order đồng thời các rating có bắt buộc là vì sao mà không sử dụng for
                staffInOrder[_staffAddress].pop(); // pop xóa phần tử
            }
        }
    }
}