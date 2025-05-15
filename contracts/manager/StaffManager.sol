// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IStaffManager.sol";

contract StaffManagement is IStaffManager {
    mapping(uint => Staff) public staffs;
    mapping(uint => uint[]) public orderStaffs;
    uint public nextStaffId = 1;

    function addStaff(uint _staffId, string calldata _name, string calldata _dob, string calldata _phone) external override {
        require(staffs[_staffId].staffId == 0, "Staff ID already exists");
        staffs[_staffId] = Staff(_staffId, _name, _dob, _phone, 0, 0);
        emit StaffAdded(_staffId, _name);
    }

    function getStaff(uint _staffId) external view override returns (Staff memory) {
        return staffs[_staffId];
    }

    function updateStaffInfo(uint _staffId, string calldata _name, string calldata _dob, string calldata _phone) external override {
        require(staffs[_staffId].staffId != 0, "Staff ID does not exist");
        staffs[_staffId].name = _name;
        staffs[_staffId].dob = _dob;
        staffs[_staffId].phone = _phone;
        emit StaffUpdated(_staffId, _name);
    }

    function recordRating(uint _staffId, uint _rating) external override {
        require(staffs[_staffId].staffId != 0, "Staff ID does not exist");
        staffs[_staffId].sumRating += _rating;
        staffs[_staffId].countRating++;
    }

    function getAverageRating(uint _staffId) external view override returns (uint) {
        require(staffs[_staffId].countRating > 0, "No ratings yet");
        return staffs[_staffId].sumRating / staffs[_staffId].countRating;
    }

    function addStaffToOrder(uint _orderId, uint _staffId) external override {
        require(staffs[_staffId].staffId != 0, "Staff ID does not exist");
        orderStaffs[_orderId].push(_staffId);
        emit StaffAddedToOrder(_orderId, _staffId);
    }

    function getStaffForOrder(uint _orderId) external view override returns (uint[] memory) {
        return orderStaffs[_orderId];
    }
}