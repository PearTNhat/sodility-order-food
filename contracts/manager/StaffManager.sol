// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IStaffManager.sol";
import "../interfaces/IOrderManager.sol";
import "../access/RoleAccess.sol";

contract StaffManagement is IStaffManager {
    IOrderManager public orderManager;
    RoleAccess public roleAccess;
    mapping(address => Staff) public staffs; // Changed from uint256 to address

    constructor(address _orderManagerAddress, address _roleAccess) {
        orderManager = IOrderManager(_orderManagerAddress);
        roleAccess = RoleAccess(_roleAccess);
    }

    modifier onlyAdmin() {
        require(roleAccess.isAdmin(tx.origin), "You are not admin");
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
        staffs[addressStaff] = Staff(addressStaff, _name, _dob, _phone, 0, 0);
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
}