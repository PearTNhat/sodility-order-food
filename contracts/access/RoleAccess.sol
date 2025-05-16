// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoleAccess {
    address owner;
    enum Role {
        NONE,
        ADMIN,
        CUSTOMER
    }
    mapping(address => Role) public roles;

    modifier onlyAdmin() {
        require(roles[msg.sender] == Role.ADMIN, "You are not admin");
        _;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can perform this function");
        _;
    }
     constructor(){
        owner =msg.sender;
    }
     function getOwner () public view returns (address){
        return owner;
    }
    function addAdmin(address _admin) external virtual  {
        // implement quyền cấp cao hơn nếu cần
        roles[_admin] = Role.ADMIN;
    }
    function isAdmin(address _addr) external view returns (bool) {
        return roles[_addr] == Role.ADMIN;
    }

    function removeAdmin(address _admin) external {
        roles[_admin] = Role.NONE;
    }
}
