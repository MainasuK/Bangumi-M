//
//  TableViewDataSource+DataProvider.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import XCTest

@testable import Bangumi_M

class TableViewDataSource_DataProvider: XCTestCase {
    
    typealias T = Provider
    typealias U = TableViewCell
    typealias V = String
    
    var model: Provider!
    var dataSource: TableViewDataSource<T, U>!
    var mockTableView: UITableView!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        model = Provider()
        dataSource = TableViewDataSource<T, U>(model: model)
        mockTableView = {
            let tableView = (UIStoryboard.init(name: "Tests", bundle: Bundle(for: Bangumi_M_Tests.self)).instantiateViewController(withIdentifier: "UITableViewController") as! UITableViewController).tableView!
            tableView.dataSource = dataSource
            
            return tableView
        }()
    }
    
    func testConfiguration() {
        var indexPath = IndexPath(row: 0, section: 0)
        var testItem: V = "funny item"
        
        mockTableView.reloadData()
        
        var cell: UITableViewCell? = mockTableView.cellForRow(at: indexPath)
        XCTAssertNil(cell)
        
        // Push data in model
        let data = [["0, 0", "0, 1"], ["1, 0", "1, 1", "1, 2"]]
        data.forEach { model.append($0) }
        
        mockTableView.reloadData()
        indexPath = IndexPath(row: 1, section: 1)
        cell = mockTableView.cellForRow(at: indexPath)
        
        XCTAssertNotNil(cell as? TableViewCell, "Should downcast success")
        if let cell = cell as? TableViewCell {
            testItem = cell.item
        }
        XCTAssertEqual(testItem, data[indexPath.section][indexPath.row], "Should be same value")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }



}

class Provider: DataProvider {
    
    typealias ItemType = String
    
    // At least one item on (0, 0)
    var items = [[ItemType]]()
    
    
    func append(_ item: [ItemType]) {
        items.append(item)
    }
    
    
    func numberOfSections() -> Int {
        return items.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        return items[section].count
    }
    
    func item(at indexPath: IndexPath) -> Provider.ItemType {
        return items[indexPath.section][indexPath.row]
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        return "TableViewDataSource_DataProvider"
    }
    
}

class TableViewCell: UITableViewCell, ConfigurableCell {
    
    typealias ItemType = String
    
    var item = ItemType()
    var isLast: Bool = false
    func configure(with item: TableViewCell.ItemType) {
        self.item = item
    }
    
}
