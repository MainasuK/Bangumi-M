////
////  FetchedResultsDataProvider.swift
////  Percolator
////
//
//import UIKit
//import CoreData
//
//class FetchedResultsDataProvider<Delegate: DataProviderDelegate where Delegate.ItemType == NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate, DataProvider {
//    
//    typealias ItemType = Delegate.ItemType
//    
//    private let controller: NSFetchedResultsController<ItemType>
//    private weak var delegate: Delegate!
//    private var updates: [DataProviderUpdate<ItemType>] = []
//    
//    
//    init(fetchedResultsController controller: NSFetchedResultsController<ItemType>, dataProviderDelegate delegate: Delegate) {
//        self.controller = controller
//        self.delegate = delegate
//    }
//    
//    
//}
//
//// MARK: - DataProvider
//extension FetchedResultsDataProvider {
//    
//    func numberOfSections() -> Int {
//        return 1
//    }
//    
//    func numberOfItems(in section: Int) -> Int {
//        return fetchedResultsController
//    }
//    
//    func item(at indexPath: IndexPath) -> SearchBoxTableViewModel.ItemType {
//        return items[indexPath.row]
//    }
//    
//    func identifier(at indexPath: IndexPath) -> String {
//        return StoryboardKey.SearchBoxTableViewCellKey
//    }
//    
//}
