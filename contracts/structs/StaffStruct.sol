// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
enum StaffStatus {Free, Busy}
struct Staff {
    address staffAddress;
    string name;
    string dob;
    string phone;
    uint sumRating;
    uint countRating;
    StaffStatus status;
}