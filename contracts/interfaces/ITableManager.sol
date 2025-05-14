// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ITableManager {
    event TableAdded(uint tableId, uint row, uint col);
    event TableEdited(uint tableId, uint row, uint col);
    event TableDeleted(uint tableId);
    event StaffTableUpdated(uint tableId, uint staffId);

    struct Table {
        uint tableId;
        uint row;
        uint col;
        uint staffId;
        bool isReserved;
    }

    function addTable(uint _row, uint _col) external returns (uint);
    
    function editTable(uint _tableId, uint _row, uint _col) external;

    function deleteTable(uint _tableId) external;

    function updateStaffTable(uint _tableId, uint _staffId) external;

    function getTableById(uint _tableId) external view returns (Table memory);
}