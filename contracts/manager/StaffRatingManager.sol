// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../access/RoleAccess.sol";
import "../interfaces/IStaffManager.sol";
import "../interfaces/IStaffRatingManager.sol"; // Import interface của StaffManager

contract StaffRatingManager is IStaffRatingManager {
    RoleAccess public roleAccess;
    IStaffManager public staffManager;
    uint public nextStaffRatingId = 1;
    mapping(uint => StaffRating) public staffRatings;
    mapping(uint => uint[]) public staffIdToRatingIds; // Để lấy tất cả ratings cho một staff

    modifier onlyAdmin() {
        require(roleAccess.isAdmin(tx.origin), "You are not admin");
        _;
    }

    constructor(address _roleAccess) {
        roleAccess = RoleAccess(_roleAccess);
    }

    function setStaffManager(address _staffManager) external override  {
        require(_staffManager != address(0), "Invalid address");
        staffManager = IStaffManager(_staffManager);
    }

    function addStaffRating(uint staffId, string calldata content, uint8 stars) external override {
        require(stars > 0 && stars <= 5, "Stars must be between 1 and 5");
        uint ratingId = nextStaffRatingId++;
        StaffRating storage rating = staffRatings[ratingId];
        rating.id = ratingId;
        rating.reviewer = msg.sender;
        rating.staffId = staffId; 
        rating.content = content;
        rating.stars = stars;
        rating.timestamp = block.timestamp;

        staffIdToRatingIds[staffId].push(ratingId);

        // Cập nhật điểm rating trung bình cho staff
        Staff memory staff = staffManager.getStaff(staffId);
        uint256 newSumRating = staff.sumRating + stars;
        uint256 newCountRating = staff.countRating + 1;
        staffManager.updateRatingStaff(staffId, newSumRating, newCountRating);

        emit StaffRatingAdded(ratingId, staffId, msg.sender, stars);
    }

    function getStaffRatingsByStaffId(uint staffId) external view override returns (StaffRating[] memory) {
        uint[] storage ratingIds = staffIdToRatingIds[staffId];
        uint count = ratingIds.length;
        StaffRating[] memory ratings = new StaffRating[](count);
        for (uint i = 0; i < count; i++) {
            ratings[i] = staffRatings[ratingIds[i]];
        }
        return ratings;
    }

    function updateStaffRating(uint ratingId, string calldata content, uint8 stars) external override {
        require(staffRatings[ratingId].id != 0, "Rating does not exist");
        // require(msg.sender == staffRatings[ratingId].reviewer, "Only reviewer can update");
        require(stars > 0 && stars <= 5, "Stars must be between 1 and 5");
        uint oldStars = staffRatings[ratingId].stars;
        uint staffId =staffRatings[ratingId].staffId;
        staffRatings[ratingId].content = content;
        staffRatings[ratingId].stars = stars;

        // Cập nhật điểm rating trung bình cho staff
        Staff memory staff = staffManager.getStaff(staffId);
        uint256 newSumRating = staff.sumRating + stars - oldStars;
        staffManager.updateRatingStaff(staffId, newSumRating, staff.countRating);

        emit StaffRatingUpdated(ratingId, staffId, msg.sender, stars);
    }

    function deleteStaffRating(uint ratingId) external override {
        require(staffRatings[ratingId].id != 0, "Rating does not exist");
        // require(msg.sender == staffRatings[ratingId].reviewer || roleAccess.isAdmin(msg.sender), "Only reviewer or admin can delete"); // Quyền admin

        // Xóa rating khỏi mapping staffIdToRatingIds
        uint staffId = staffRatings[ratingId].staffId;
        uint oldStars = staffRatings[ratingId].stars;
        uint[] storage ratingIds = staffIdToRatingIds[staffId];
        for (uint i = 0; i < ratingIds.length; i++) {
            if (ratingIds[i] == ratingId) {
                ratingIds[i] = ratingIds[ratingIds.length - 1];
                ratingIds.pop();
                break;
            }
        }
        // Cập nhật điểm rating trung bình cho staff
        Staff memory staff = staffManager.getStaff(staffId);
        uint256 newSumRating = staff.sumRating - oldStars;
        uint256 newCountRating = staff.countRating - 1;
        staffManager.updateRatingStaff(staffId, newSumRating, newCountRating);

        delete staffRatings[ratingId];
        emit StaffRatingDeleted(ratingId, staffId);
    }
}