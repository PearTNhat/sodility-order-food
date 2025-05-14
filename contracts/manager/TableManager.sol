// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/ITableManager.sol";
contract TableManager is ITableManager {
    mapping(uint => Table) public tables;
    uint public nextTableId = 1;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addTable(uint _row, uint _col) external override returns (uint) {
        require(_row > 0 && _col > 0, "Row and column must be greater than 0");
        uint newTableId = nextTableId++;
        tables[newTableId] = Table({
            tableId: newTableId,
            row: _row,
            col: _col,
            staffId: 0, // Mặc định là chưa có nhân viên quản lý
            isReserved: false
        });
        emit TableAdded(newTableId, _row, _col);
        return newTableId;
    }

    function editTable(uint _tableId, uint _row, uint _col) external override  {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        require(_row > 0 && _col > 0, "Row and column must be greater than 0");
        tables[_tableId].row = _row;
        tables[_tableId].col = _col;
        emit TableEdited(_tableId, _row, _col);

    }

    function deleteTable(uint _tableId) external override  {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        delete tables[_tableId];
        emit TableDeleted(_tableId);
    }

    function updateStaffTable(uint _tableId, uint _staffId) external override {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        tables[_tableId].staffId = _staffId;
        emit StaffTableUpdated(_tableId, _staffId);
    }

    function getTableById(uint _tableId) external override view returns (Table memory) {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        return tables[_tableId];
    }
}
