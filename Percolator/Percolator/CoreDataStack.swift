//
//  CoreDataStack.swift
//  Mocaccino
//
//  Created by Cirno MainasuK on 2016-2-5.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import CoreData

class CoreDataStack {
    var modelName: String
    var storeName: String
    var options: [AnyHashable : Any]?
    
    // Flag of listening notification or not
    var updateContextWithUbiquitousContentUpdates: Bool = false {
        willSet {
            ubiquitousChangesObserver = newValue ? NotificationCenter.default : nil
        }
    }
    
    private var ubiquitousChangesObserver: NotificationCenter? {
        didSet {
            oldValue?.removeObserver(self, name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: psc)
            ubiquitousChangesObserver?.addObserver(self, selector: #selector(CoreDataStack.persistentStoreDidimportUbiquitousContentChanges(_:)), name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: psc)
            
            oldValue?.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: psc)
            ubiquitousChangesObserver?.addObserver(self, selector: #selector(CoreDataStack.persistentStoreCoordinatorWillChangeStores(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: psc)
            
            oldValue?.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: psc)
            ubiquitousChangesObserver?.addObserver(self, selector: #selector(CoreDataStack.persistentStoreCoordinatorDidChangeStores(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: psc)
        }
    }
    
    init(modelName: String, storeName: String, options: ([AnyHashable : Any])?) {
        self.modelName = modelName
        self.storeName = storeName
        self.options = options
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var applicationDocumentsDirectory = URL.documentsURL
    
    /// Root context
    lazy var rootContext: NSManagedObjectContext = {
        var moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.psc
        // Giving priority to in-memory changes
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return moc
    }()
    
    /// Main context
    lazy var context: NSManagedObjectContext = {
        var moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.parent = self.rootContext
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        NotificationCenter.default.addObserver(self, selector: #selector(CoreDataStack.mainContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: moc)
        
        return moc
    }()
    
    func newDerivedContext() -> NSManagedObjectContext {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self.context
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return moc
    }
    
    lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.modelName + ".sqlite")
        
        do {
            let store: NSPersistentStore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: self.options)
        } catch {
            consolePrint("Error adding persistent stroe.")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // Ref: *Core Data by Tutorials*
    func saveContext(context moc: NSManagedObjectContext) {
        guard moc.parent !== self.context else {
            self.saveDerivedContext(context: moc)
            return
        }
        
        moc.perform {
            do {
                try moc.obtainPermanentIDs(for: Array(moc.insertedObjects))
            } catch {
                consolePrint("Error obtaining permanent IDs for \(moc.insertedObjects), \(error)")
            }
            
            do {
                try moc.save()
            } catch {
                consolePrint("Unresolved core data error: \(error)")
                abort()
            }
        }
    }
    
    func saveDerivedContext(context moc: NSManagedObjectContext) {
        moc.perform {
            do {
                try moc.obtainPermanentIDs(for: Array(moc.insertedObjects))
            } catch {
                consolePrint("Error obtaining permanent IDs for \(moc.insertedObjects), \(error)")
            }
            
            do {
                try moc.save()
            } catch {
                consolePrint("Unresolved core data error: \(error)")
                abort()
            }
        }
        
        self.saveContext(context: self.context)
    }
    
    @objc func persistentStoreDidimportUbiquitousContentChanges(_ notification: Notification) {
        consolePrint("Merging ubiquitous content changes")
        context.perform { () -> Void in
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func persistentStoreCoordinatorWillChangeStores(_ notification: Notification) {
        consolePrint("NSPersistentStoreCoordinator will change")
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                consolePrint("Error saving \(error)")
            }
        }
        
        context.reset()
    }
    
    @objc func persistentStoreCoordinatorDidChangeStores(_ notification: Notification) {
        consolePrint("NSPersistentStoreCoordinator did change")
    }
    
    @objc func mainContextDidSave(_ notification: Notification) {
        self.saveContext(context: self.rootContext)
    }
}
