//
//  ArrayDataSourceTests.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-13.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import XCTest

@testable import Bangumi_M

class ArrayDataSourceTests: Bangumi_M_Tests {
    
    typealias T = String
    typealias U = TestCell
    
    func testNothing() {
        XCTAssertTrue(true)
    }
    
    func testConfiguration() {
        var emptyItem: T = String()
        var emptyCell: U = TestCell()
        
        let dataSource =
            ArrayDataSource<T, U>(items: ["a", "b"], cellIdentifier: "TestCell") { (cell, item) in
                emptyItem = item
                emptyCell = cell
            }
        
        let mockTableView: UITableView = {
            let tableView = (UIStoryboard.init(name: "Tests", bundle: Bundle(for: Bangumi_M_Tests.self)).instantiateViewController(withIdentifier: "UITableViewController") as! UITableViewController).tableView!
            tableView.dataSource = dataSource
            
            return tableView
        }()
        
        mockTableView.reloadData()
        
        let cell = dataSource.tableView(mockTableView, cellForRowAt: IndexPath(item: 0, section: 0))
        
        XCTAssertNil(cell as? SearchBoxTableViewCell, "Shoulde be nil")
        XCTAssertNotNil(cell as? TestCell, "Should downcast success")
        XCTAssertEqual(emptyCell, cell, "Shoule same cell")
        XCTAssertEqual(emptyItem, "a", "Should be configure to 'a'")
    }

}

class TestCell: UITableViewCell {
    var item: ItemType?
    var isLast: Bool = false
}

extension TestCell: ConfigurableCell {
    typealias ItemType = String
    
    func configure(with item: ItemType) {
        self.item = item
    }
    
}
