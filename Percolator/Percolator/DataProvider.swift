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

//protocol DataProviderDelegate: class {
//    associatedtype ItemType
//    
//    func dataProviderDidUpdate(_ updates: [DataProviderUpdate<ItemType>]?)
//    
//}


//enum DataProviderUpdate<ItemType> {
//    case Insert(IndexPath)
//    case Update(IndexPath, ItemType)
//    case Move(IndexPath, IndexPath)
//    case Delete(IndexPath)
//}


//protocol DataSourceDelegate {

//    func didUpdateDataSource()

//}


