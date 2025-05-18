// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../structs/RatingStruct.sol";

interface IStaffRatingManager {
    event StaffRatingAdded(uint indexed ratingId, address indexed staffAddress, address reviewer, uint8 stars);
    event StaffRatingUpdated(uint indexed ratingId, address indexed staffAddress, address reviewer, uint8 stars);
    event StaffRatingDeleted(uint indexed ratingId, address indexed staffAddress);

    function setStaffManager(address _staffManager) external;

    function addStaffRating(address staffAddress, uint _orderId, string calldata content, string[] memory imgs ,uint8 stars) external;

    function getStaffRatingsByStaffId(address staffAddress) external view returns (StaffRating[] memory);

    function updateStaffRating(uint ratingId, string calldata content, uint8 stars) external;

    function deleteStaffRating(uint ratingId) external;
}