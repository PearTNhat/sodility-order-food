// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../structs/StaffStruct.sol";

interface IStaffManager {
    event StaffAdded(uint256 indexed staffId, string name);
    event StaffUpdated(uint256 indexed staffId, string name);
    event StaffAddedToOrder(uint256 indexed staffId, uint256 _orderId);
    event StaffRatingUpdated(
        uint256 staffId,
        uint256 sumRating,
        uint256 countRating
    );

    function addStaff(
        uint256 _staffId,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external;

    function getStaff(uint256 _staffId) external view returns (Staff memory);

    function updateStaffInfo(
        uint256 _staffId,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external;

    function addStaffToOrder(uint256 _orderId, uint256 _staffId) external;

    function updateRatingStaff(
        uint256 _staffId,
        uint256 _sumRating,
        uint256 _countRating
    ) external;
}
