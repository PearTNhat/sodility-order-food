// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum TableStatus { Free, Booked }

struct Table {
    uint tableId;
    uint row;
    uint col;
    string qrUrl;
    TableStatus status; // hoặc reservationStatus
}