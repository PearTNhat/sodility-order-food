// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/ITableManager.sol";
import "../interfaces/IOrderManager.sol";
import "../access/RoleAccess.sol";
contract TableManager is ITableManager {
    IOrderManager public orderManager;
    RoleAccess public roleAccess;

    uint public nextTableId = 1;
    mapping(uint => Table) public tables;

    mapping(uint => uint[]) public orderTable;

    constructor(address _roleAccess) {
        roleAccess = RoleAccess(_roleAccess);
    }

    modifier onlyAdmin() {
        require(roleAccess.isAdmin(tx.origin), "You are not admin");
        _;
    }
    function setOrderManager(address _orderManager) external onlyAdmin {
        orderManager = IOrderManager(_orderManager);
    }

    function addTable(uint _row, uint _col) external override onlyAdmin returns (uint) {
        require(_row > 0 && _col > 0, "Row and column must be greater than 0");
        uint newTableId = nextTableId++;
        tables[newTableId] = Table({
            tableId: newTableId,
            row: _row,
            col: _col,
            status: TableStatus.Free
        });
        emit TableAdded(newTableId, _row, _col);
        return newTableId;
    }

    function editTable(uint _tableId, uint _row, uint _col) external onlyAdmin override  {
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

    function getTableById(uint _tableId) external override view returns (Table memory) {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        return tables[_tableId];
    }
    function addTableToOrder(uint _orderId, uint _tableId) external override onlyAdmin{
        require(tables[_tableId].tableId != 0, "Table ID does not exist");
        orderManager.addTableForOrder(_orderId,_tableId);
        emit TableAddedToOrder( _tableId,_orderId);
    }
    function updateStatusTable(uint _tableId, TableStatus _status) external override onlyAdmin {
        require(tables[_tableId].tableId != 0, "Table ID does not exist");
        tables[_tableId].status = _status;
        emit TableUpdatedStaus(_tableId);
    }
}
