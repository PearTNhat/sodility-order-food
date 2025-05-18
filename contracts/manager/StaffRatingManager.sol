// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../access/RoleAccess.sol";
import "../interfaces/IStaffManager.sol";
import "../interfaces/IStaffRatingManager.sol";
import "hardhat/console.sol";

contract StaffRatingManager is IStaffRatingManager {
    RoleAccess public roleAccess;
    IStaffManager public staffManager;

    uint public nextStaffRatingId = 1;
    mapping(uint => StaffRating) public staffRatings;
    mapping(address => uint[]) public staffAddressToRatingIds; // Changed from uint to address

    modifier onlyAdmin() {
        require(roleAccess.hasRole(tx.origin,RoleType.ADMIN), "You are not admin");
        _;
    }

    constructor(address _roleAccess) {
        roleAccess = RoleAccess(_roleAccess);

    }

    function setStaffManager(address _staffManager) external override {
        require(_staffManager != address(0), "Invalid address");
        staffManager = IStaffManager(_staffManager);
    }

    function addStaffRating(address staffAddress, uint _orderId, string calldata content, string[] memory imgs ,uint8 stars) external override {
        require(staffAddress != address(0), "Invalid staff address");
        require(stars > 0 && stars <= 5, "Stars in [1,5]");
        require(imgs.length <=5 , "Img <= 5");
        require(staffManager.getStaffInOrder(staffAddress, _orderId));
        console.log("sender",msg.sender);
        staffManager.removeOrderInStaffInOrder(staffAddress, _orderId);
        uint ratingId = nextStaffRatingId++;
        StaffRating storage rating = staffRatings[ratingId];
        rating.id = ratingId;
        rating.reviewer = msg.sender;
        rating.staffAddress = staffAddress; // Changed from staffId
        rating.content = content;
        rating.stars = stars;
        rating.timestamp = block.timestamp;

        staffAddressToRatingIds[staffAddress].push(ratingId);

        // Update average rating for staff
        Staff memory staff = staffManager.getStaff(staffAddress);
        uint256 newSumRating = staff.sumRating + stars;
        uint256 newCountRating = staff.countRating + 1;
        staffManager.updateRatingStaff(staffAddress, newSumRating, newCountRating);

        emit StaffRatingAdded(ratingId, staffAddress, msg.sender, stars);
    }

    function getStaffRatingsByStaffId(address staffAddress) external view override returns (StaffRating[] memory) {
        uint[] storage ratingIds = staffAddressToRatingIds[staffAddress];
        uint count = ratingIds.length;
        StaffRating[] memory ratings = new StaffRating[](count);
        for (uint i = 0; i < count; i++) {
            ratings[i] = staffRatings[ratingIds[i]];
        }
        return ratings;
    }

    function updateStaffRating(uint ratingId, string calldata content, uint8 stars) external override {
        require(staffRatings[ratingId].id != 0, "Rating does not exist");
         require(msg.sender == staffRatings[ratingId].reviewer ||roleAccess.hasRole(tx.origin,RoleType.ADMIN), "Only reviewer or admin can delete");
        require(stars > 0 && stars <= 5, "Stars must be between 1 and 5");
        console.log("sender",msg.sender);
        uint8 oldStars = staffRatings[ratingId].stars;
        address staffAddress = staffRatings[ratingId].staffAddress; // Changed from staffId
        staffRatings[ratingId].content = content;
        staffRatings[ratingId].stars = stars;

        // Update average rating for staff
        Staff memory staff = staffManager.getStaff(staffAddress);
        uint256 newSumRating = staff.sumRating + stars - oldStars;
        staffManager.updateRatingStaff(staffAddress, newSumRating, staff.countRating);

        emit StaffRatingUpdated(ratingId, staffAddress, msg.sender, stars);
    }

    function deleteStaffRating(uint ratingId) external override {
        require(staffRatings[ratingId].id != 0, "Rating does not exist");
        require(msg.sender == staffRatings[ratingId].reviewer || roleAccess.hasRole(tx.origin,RoleType.ADMIN), "Only reviewer or admin can delete");

        // Remove rating from staffAddressToRatingIds
        address staffAddress = staffRatings[ratingId].staffAddress; // Changed from staffId
        uint8 oldStars = staffRatings[ratingId].stars;
        uint[] storage ratingIds = staffAddressToRatingIds[staffAddress];
        for (uint i = 0; i < ratingIds.length; i++) {
            if (ratingIds[i] == ratingId) {
                ratingIds[i] = ratingIds[ratingIds.length - 1];
                ratingIds.pop();
                break;
            }
        }

        // Update average rating for staff
        Staff memory staff = staffManager.getStaff(staffAddress);
        uint256 newSumRating = staff.sumRating - oldStars;
        uint256 newCountRating = staff.countRating - 1;
        staffManager.updateRatingStaff(staffAddress, newSumRating, newCountRating);

        delete staffRatings[ratingId];
        emit StaffRatingDeleted(ratingId, staffAddress);
    }
}