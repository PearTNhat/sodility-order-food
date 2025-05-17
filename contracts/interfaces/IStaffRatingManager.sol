// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../structs/RatingStruct.sol";
interface IStaffRatingManager {
     event StaffRatingAdded(uint ratingId, uint staffId, address reviewer, uint8 stars);
    event StaffRatingUpdated(uint ratingId, uint staffId, address reviewer, uint8 stars);
    event StaffRatingDeleted(uint ratingId, uint staffId);
    
    function setStaffManager(address _staffManager) external;
    function addStaffRating(uint staffId, string calldata content, uint8 stars) external;
    function getStaffRatingsByStaffId(uint staffId) external view returns (StaffRating[] memory);
    function updateStaffRating(uint ratingId, string calldata content, uint8 stars) external;
    function deleteStaffRating(uint ratingId) external;
}
