// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IStaffManager.sol";
import "../interfaces/IOrderManager.sol";
import "../access/RoleAccess.sol";

contract StaffManagement is IStaffManager {
    IOrderManager public orderManager;
    RoleAccess public roleAccess;
    mapping(uint256 => Staff) public staffs;

    // mapping(uint => uint) public staffInOrder;

    constructor(address _orderManagerAddress, address _roleAccess) {
        orderManager = IOrderManager(_orderManagerAddress);
        roleAccess = RoleAccess(_roleAccess);
    }

    modifier onlyAdmin() {
        require(roleAccess.isAdmin(tx.origin), "You are not admin");
        _;
    }

    function addStaff(
        uint256 _staffId,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external override onlyAdmin {
        require(staffs[_staffId].staffId == 0, "Staff ID already exists");
        staffs[_staffId] = Staff(_staffId, _name, _dob, _phone, 0, 0);
        emit StaffAdded(_staffId, _name);
    }

    function getStaff(uint256 _staffId)
        external
        view
        override
        returns (Staff memory)
    {
        return staffs[_staffId];
    }

    function updateStaffInfo(
        uint256 _staffId,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external override {
        require(staffs[_staffId].staffId != 0, "Staff ID does not exist");
        staffs[_staffId].name = _name;
        staffs[_staffId].dob = _dob;
        staffs[_staffId].phone = _phone;
        emit StaffUpdated(_staffId, _name);
    }

    function addStaffToOrder(uint256 _orderId, uint256 _staffId)
        external
        override
        onlyAdmin
    {
        require(staffs[_staffId].staffId != 0, "Staff ID does not exist");
        orderManager.addStaffForOrder(_orderId, _staffId);
        emit StaffAddedToOrder(_staffId, _orderId);
    }

    function updateRatingStaff(
        uint256 _staffId,
        uint256 _sumRating,
        uint256 _countRating
    ) external onlyAdmin {
        require(staffs[_staffId].staffId != 0, "Staff does not exist");
        staffs[_staffId].sumRating = _sumRating;
        staffs[_staffId].countRating = _countRating;
        emit StaffRatingUpdated(_staffId, _sumRating, _countRating);
    }
}
