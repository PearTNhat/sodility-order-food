// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../structs/StaffStruct.sol";

interface IStaffManager {
    event StaffAdded(address indexed staffAddress, string name);
    event StaffUpdated(address indexed staffAddress, string name);
    event StaffAddedToOrder(address indexed staffAddress, uint256 _orderId);
    event StaffRatingUpdated(
        address staffAddress,
        uint256 sumRating,
        uint256 countRating
    );

    function addStaff(
        address addressStaff,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external;

    function getStaff(address addressStaff) external view returns (Staff memory);

    function updateStaffInfo(
        address addressStaff,
        string calldata _name,
        string calldata _dob,
        string calldata _phone
    ) external;

    function addStaffToOrder(uint256 _orderId, address addressStaff) external;

    function updateRatingStaff(
        address addressStaff,
        uint256 _sumRating,
        uint256 _countRating
    ) external;
}