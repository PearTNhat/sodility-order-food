// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../structs/TableStruct.sol";
interface ITableManager {
    event TableAdded(uint tableId, uint row, uint col);
    event TableEdited(uint tableId, uint row, uint col);
    event TableDeleted(uint tableId);
    event StaffTableUpdated(uint tableId, uint staffId);
    event TableAddedToOrder( uint _tableId,uint _orderId);
    event TableUpdatedStaus(uint _tableId);

    function addTable(uint _row, uint _col) external returns (uint);
    
    function editTable(uint _tableId, uint _row, uint _col) external;

    function deleteTable(uint _tableId) external;

    function getTableById(uint _tableId) external view returns (Table memory);
    function addTableToOrder(uint _orderId, uint _tableId) external ;
    function updateReservedTable(uint _tableId, TableStatus _status) external;
}