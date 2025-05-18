// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum RoleType {
    ADMIN,
    STAFF
}
struct Role {
    uint roleId; // none / admin / saff
    RoleType role;
    string name;
}
