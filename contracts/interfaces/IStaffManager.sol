// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../structs/StaffStruct.sol";
interface IStaffManager {

    event StaffAdded(uint indexed staffId, string name);
    event StaffUpdated(uint indexed staffId, string name);

    function addStaff(uint _staffId, string calldata _name, string calldata _dob, string calldata _phone) external;
    function getStaff(uint _staffId) external view returns (Staff memory);
    function updateStaffInfo(uint _staffId, string calldata _name, string calldata _dob, string calldata _phone) external;
    function recordRating(uint _staffId, uint _rating) external;
    function getAverageRating(uint _staffId) external view returns (uint);
    function addStaffToOrder(uint _orderId, uint _staffId) external;
}