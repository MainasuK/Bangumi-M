//
//  ArrayDataSource.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-12.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class ArrayDataSource<T, U: ConfigurableCell where U.ItemType == T, U: UITableViewCell>: NSObject, UITableViewDataSource {

    typealias CellConfigureClosure = (cell: U, item: T) -> Void
    
    private var items: [T]
    private let configure: CellConfigureClosure
    private let cellIdentifier: String
    
    required init(items: [T], cellIdentifier: String, handler: CellConfigureClosure) {
        self.items = items
        self.configure = handler
        self.cellIdentifier = cellIdentifier
    }
    
    private func item(at indexPath: IndexPath) -> T {
        return items[indexPath.row]
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let _cell = cell as? U else {
            fatalError("Cell not conform Configurable protocol")
        }
        
        let item = self.item(at: indexPath)
        
        configure(cell: _cell, item: item)
        configureSeparator(of: _cell, in: tableView, at: indexPath)
        
        return _cell
    }
}

extension ArrayDataSource: ModelDelegate {
    
    func append(contentsOf items: [T]) {
        self.items.append(contentsOf: items)
    }
    
    func clean() {
        items = [T]()
        
    }
    
}

// MARK: - Custom cell separator
extension ArrayDataSource {
    
    func configureSeparator(of cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        // If is last row
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset.left = 0
        } else {
            cell.separatorInset = UITableViewCell().separatorInset
        }
    }
    
}
