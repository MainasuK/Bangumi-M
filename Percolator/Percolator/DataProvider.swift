//
//  DataProvider.swift
//  Percolator
//

import UIKit

protocol DataProvider: class {
    
    associatedtype ItemType
    
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    
    func item(at indexPath: IndexPath) -> ItemType
    func identifier(at indexPath: IndexPath) -> String
    
}

protocol HeaderDataProvider: class {
    
    associatedtype HeaderItemType
    
    func headerItem(at indexPath: IndexPath) -> HeaderItemType
    func headerIdentifier(at indexPath: IndexPath) -> String
}
