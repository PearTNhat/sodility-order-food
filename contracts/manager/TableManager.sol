// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/ITableManager.sol";
import "../interfaces/IOrderManager.sol";
import "../access/RoleAccess.sol";

contract TableManager is ITableManager {
    IOrderManager public orderManager;
    RoleAccess public roleAccess;

    uint256 public nextTableId = 1;
    mapping(uint256 => Table) public tables;

    mapping(uint256 => uint256[]) public orderTable;

    constructor(address _roleAccess) {
        roleAccess = RoleAccess(_roleAccess);
    }

    modifier onlyAdmin() {
        require(roleAccess.hasRole(tx.origin,RoleType.ADMIN), "Not admin");
        _;
    }
    
    modifier onlyAdminOrStaff() {
        require(
            roleAccess.hasRole(tx.origin, RoleType.ADMIN) ||
                roleAccess.hasRole(tx.origin, RoleType.STAFF),
            "Not admin or staff"
        );
        _;
    }
    function setOrderManager(address _orderManager) external override {
        orderManager = IOrderManager(_orderManager);
    }

    function addTable(
        uint256 _row,
        uint256 _col,
        string memory _qrUrl
    ) external override onlyAdmin returns (uint256) {
        require(_row > 0 && _col > 0, "Row and column must be greater than 0");
        require(bytes(_qrUrl).length > 0, "QR URL cannot be empty");
        uint256 newTableId = nextTableId++;
        tables[newTableId] = Table({
            tableId: newTableId,
            row: _row,
            col: _col,
            qrUrl: _qrUrl,
            status: TableStatus.Free
        });
        emit TableAdded(newTableId, _row, _col);
        return newTableId;
    }

    function updateTable(
        uint256 _tableId,
        uint256 _row,
        uint256 _col,
        string memory _qrUrl
    ) external onlyAdmin {
        require(tables[_tableId].tableId != 0, "Table does not exist");

        Table storage table = tables[_tableId];
        table.row = _row;
        table.col = _col;

        // Update qrUrl only if a non-empty string is provided
        if (bytes(_qrUrl).length > 0) {
            table.qrUrl = _qrUrl;
        }

        emit TableUpdated(_tableId, table.row, table.col, table.qrUrl);
    }

    function editTable(
        uint256 _tableId,
        uint256 _row,
        uint256 _col
    ) external override onlyAdmin {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        require(_row > 0 && _col > 0, "Row and column must be greater than 0");
        tables[_tableId].row = _row;
        tables[_tableId].col = _col;
        emit TableEdited(_tableId, _row, _col);
    }

    function deleteTable(uint256 _tableId) external override {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        delete tables[_tableId];
        emit TableDeleted(_tableId);
    }

    function getTableById(uint256 _tableId)
        external
        view
        override
        returns (Table memory)
    {
        require(tables[_tableId].tableId != 0, "Table does not exist");
        return tables[_tableId];
    }

    function addTableToOrder(uint256 _orderId, uint256 _tableId)
        external
        override
        onlyAdmin
    {
        require(tables[_tableId].tableId != 0, "Table ID does not exist");
        orderManager.addTableForOrder(_orderId, _tableId);
        emit TableAddedToOrder(_tableId, _orderId);
    }

    function updateStatusTable(uint256 _tableId, TableStatus _status)
        external
        override
        onlyAdminOrStaff
    {
        require(tables[_tableId].tableId != 0, "Table ID does not exist");
        tables[_tableId].status = _status;
        emit TableUpdatedStaus(_tableId);
    }
}
