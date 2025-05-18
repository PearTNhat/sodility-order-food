// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../structs/RoleStruct.sol";

contract RoleAccess {
    address public owner;

    mapping(address => Role) private userRole; // danh sách user đã cấp quyền
    mapping(uint256 => Role) private roles; // danh sách các role
    uint256[] private arrRoles; // danh sách các roleId

    event RoleAssigned(
        address indexed account,
        string roleName,
        RoleType roleType
    );
    event RoleUpdated(
        address indexed account,
        string roleName,
        RoleType roleType
    );
    event RoleRevoked(address indexed account);

    constructor() {
        owner = msg.sender;
        // Init 2 default roles
        roles[1] = Role(1, RoleType.ADMIN, "Administrator");
        arrRoles.push(1);
        roles[2] = Role(2, RoleType.STAFF, "Staff");
        arrRoles.push(2);
    }

    // 2. Gán Role cho user
    function assignRole(address account, uint256 roleId) external {
        require(roles[roleId].roleId != 0, "Invalid role ID");
        userRole[account] = roles[roleId];
        emit RoleAssigned(account, roles[roleId].name, roles[roleId].role);
    }

    // // 3. Cập nhật Role của user
    // function updateUserRole(address account, uint256 newRoleId) external onlyOwner {
    //     require(roles[newRoleId].roleId != 0, "Invalid role ID");
    //     require(userRole[account].roleId != 0, "User does not have a role");
    //     userRole[account] = roles[newRoleId];
    //     emit RoleUpdated(account, roles[newRoleId].name, roles[newRoleId].role);
    // }

    // 4. Thu hồi Role của user
    function revokeRole(address account) external  {
        require(userRole[account].roleId != 0, "User has no role assigned");
        delete userRole[account];
        emit RoleRevoked(account);
    }

    // 5. Lấy Role của user
    function getUserRole(address account) external view returns (Role memory) {
        require(userRole[account].roleId != 0, "User has no role assigned");
        return userRole[account];
    }

    // 7. Lấy tất cả Role
    function getAllRoles() external view returns (Role[] memory) {
        Role[] memory allRoles = new Role[](arrRoles.length);
        for (uint i = 0; i < arrRoles.length; i++) {
            allRoles[i] = roles[arrRoles[i]];
        }
        return allRoles;
    }

    // 8. Kiểm tra user có Role cụ thể không
    function hasRole(address account, RoleType roleType) external view returns (bool) {
        if(userRole[account].roleId == 0){
            return false;
        } 
        return userRole[account].role == roleType;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
