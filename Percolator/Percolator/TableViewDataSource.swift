//
//  TableViewDataSource.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-14.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

class TableViewDataSource<Model: DataProvider, Cell: ConfigurableCell>: DataSource<Model>, UITableViewDataSource where Model.ItemType == Cell.ItemType, Cell: UITableViewCell {
    
    deinit {
        consolePrint("TableViewDataSource deinit")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = model.identifier(at: indexPath)
        guard var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Cell should be configurable")
        }
        
        cell.isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.configure(with: model.item(at: indexPath))

        
        return cell
    }
    
}
