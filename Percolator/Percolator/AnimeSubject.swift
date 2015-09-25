//
//  AnimeSubject.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-20.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

// FIXME: rebuild it !
public struct AnimeSubject {
    public var id = 0
    public var url = ""
    public var type = 0
    public var name = ""
    public var nameCN = ""
    public var summary = ""
    public var eps = 0
    public var airDate = ""
    public var airWeekday = 0
    
    public var images = AnimeImages()
    public var collection = AnimeCollection()
    
    init() {
    }
    
    init(animeSubjectDict: NSDictionary) {
        if let subjectImagesDict = animeSubjectDict[BangumiKey.subjectImages] as? NSDictionary {
            images = AnimeImages(animeImagesDict: subjectImagesDict)
        }
        if let subjectCollectionDict = animeSubjectDict[BangumiKey.subjectCollection] as? NSDictionary {
            collection = AnimeCollection(animeCollectionDict: subjectCollectionDict)
        }
        
        id = animeSubjectDict[BangumiKey.id] as! Int
        url = animeSubjectDict[BangumiKey.url] as! String
        type = animeSubjectDict[BangumiKey.type] as! Int
        name = animeSubjectDict[BangumiKey.name] as! String
        nameCN = animeSubjectDict[BangumiKey.nameCN] as! String
        summary = animeSubjectDict[BangumiKey.summary] as! String
        eps = animeSubjectDict[BangumiKey.eps] as! Int
        airDate = animeSubjectDict[BangumiKey.airDate] as! String
        airWeekday = animeSubjectDict[BangumiKey.airWeekday] as! Int
    }
}

extension AnimeSubject {
    init(record: CKRecord) {
        id      = record.objectForKey("id") as? Int ?? 0
        url     = record.objectForKey("url") as? String ?? ""
        type    = record.objectForKey("type") as? Int ?? 0
        name    = record.objectForKey("name") as? String ?? ""
        nameCN  = record.objectForKey("nameCN") as? String ?? ""
        summary = record.objectForKey("summary") as? String ?? ""
        eps     = 0
        airDate = record.objectForKey("airDate") as? String ?? ""
        airWeekday = record.objectForKey("airWeekday") as? Int ?? 0
        
        images.commonUrl    = record.objectForKey("imageLargeUrl") as? String ?? ""
        images.gridUrl      = record.objectForKey("imageLargeUrl") as? String ?? ""
        images.largeUrl     = record.objectForKey("imageLargeUrl") as? String ?? ""
        images.mediumUrl    = record.objectForKey("imageLargeUrl") as? String ?? ""
        images.gridUrl      = record.objectForKey("imageLargeUrl") as? String ?? ""
        
        collection.collect  = record.objectForKey("collectionCollect") as? Int ?? 0
        collection.doing    = record.objectForKey("collectionDoing") as? Int ?? 0
        collection.dropped  = record.objectForKey("collectionDropped") as? Int ?? 0
        collection.onHold   = record.objectForKey("collectionOnHold") as? Int ?? 0
        collection.wish     = record.objectForKey("collectionWish") as? Int ?? 0
    }
    
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Subject")
        record.setValue(self.id, forKey: "id")
        record.setValue(self.url, forKey: "url")
        record.setValue(self.type, forKey: "type")
        record.setValue(self.name , forKey: "name")
        record.setValue(self.nameCN, forKey: "nameCN")
        record.setValue(self.summary, forKey: "summary")
        record.setValue(self.airDate, forKey: "ariDate")
        record.setValue(self.airWeekday, forKey: "airWeekday")
        record.setValue(self.images.largeUrl, forKey: "imageLargeUrl")
        
        record.setValue(self.collection.collect, forKey: "collectionCollect")
        record.setValue(self.collection.doing, forKey: "collectionDoing")
        record.setValue(self.collection.dropped, forKey: "collectionDropped")
        record.setValue(self.collection.onHold, forKey: "collectionOnHold")
        record.setValue(self.collection.wish, forKey: "collectionWish")
        
        return record
    }
}

extension AnimeSubject {
    init(subject: Subject) {
        id      = Int(subject.id)!
        url     = subject.url
        type    = Int(subject.type)!
        name    = subject.name
        nameCN  = subject.nameCN
        summary = subject.summary
        eps     = Int(subject.eps)!
        airDate = subject.airDate
        airWeekday = Int(subject.airWeekday)!
        
        images.commonUrl    = subject.imageLargeUrl
        images.gridUrl      = subject.imageLargeUrl
        images.largeUrl     = subject.imageLargeUrl
        images.mediumUrl    = subject.imageLargeUrl
        images.gridUrl      = subject.imageLargeUrl
        
        collection.collect  = Int(subject.collectionCollect)!
        collection.doing    = Int(subject.collectionDoing)!
        collection.dropped  = Int(subject.collectionDropped)!
        collection.onHold   = Int(subject.collectionOnHold)!
        collection.wish     = Int(subject.collectionWish)!

    }
}

@objc(Subject)
class Subject: NSManagedObject {
    @NSManaged var airDate: String!
    @NSManaged var airWeekday: String!
    @NSManaged var collectionCollect: String!
    @NSManaged var collectionDoing: String!
    @NSManaged var collectionDropped: String!
    @NSManaged var collectionOnHold: String!
    @NSManaged var collectionWish: String!
    @NSManaged var eps: String!
    @NSManaged var id: String!
    @NSManaged var imageLargeUrl: String!
    @NSManaged var name: String!
    @NSManaged var nameCN: String!
    @NSManaged var summary: String!
    @NSManaged var type: String!
    @NSManaged var url: String!

    
    // FIXME: Swift2.0 error handle need here (throws)
    class func saveAnimeSubject(animeSubject: AnimeSubject, _ handler: (Bool) -> Void) {
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext,
        let subject = NSEntityDescription.insertNewObjectForEntityForName("Subject", inManagedObjectContext: managedObjectContext) as? Subject else {
            
            handler(false)
            return
        }
        
        subject.airDate = animeSubject.airDate
        subject.airWeekday = "\(animeSubject.airWeekday)"
        subject.collectionCollect = "\(animeSubject.collection.collect)"
        subject.collectionDoing = "\(animeSubject.collection.doing)"
        subject.collectionDropped = "\(animeSubject.collection.dropped)"
        subject.collectionOnHold = "\(animeSubject.collection.onHold)"
        subject.collectionWish = "\(animeSubject.collection.wish)"
        subject.eps = "\(animeSubject.eps)"
        subject.id = "\(animeSubject.id)"
        subject.imageLargeUrl = animeSubject.images.largeUrl
        subject.name = animeSubject.name
        subject.nameCN = animeSubject.nameCN
        subject.summary = animeSubject.summary
        subject.type = "\(animeSubject.type)"
        subject.url = animeSubject.url
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("% Subject: Insert error: \(error.localizedDescription)")
            handler(false)
            return
        }
        
        handler(true)
        
    }   // class func saveAnimeSubject(…)
    
    // FIXME: Siwft2.0 error handle need here (throws)
    class func deleteSubject(subjectToDelete: AnimeSubject, _ handler: (Bool) -> Void) {

        let fetchRequest = NSFetchRequest(entityName: "Subject")
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(subjectToDelete.id)")
        
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext,
        let subjects = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Subject],
        let subject = subjects.first else {
        
            handler(false)
            return
        }
        
        do {
            managedObjectContext.deleteObject(subject)
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("% Subject: Delete error: \(error.localizedDescription)")
            handler(false)
            return
        }
        
        handler(true)
    }
    
    // FIXME: Swift2.0 error handle need here (throws)
    class func fetchSubject(handler: ([AnimeSubject]?) -> Void) {
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext else {
            
            handler(nil)
            return
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Subject")
        var subjects = [Subject]()
        var animeSubjects = [AnimeSubject]()
        
        do {
            subjects = (try managedObjectContext.executeFetchRequest(fetchRequest)) as! [Subject]
            for subject in subjects {
                animeSubjects.append(AnimeSubject(subject: subject))
            }
        } catch let error as NSError {
            NSLog("% Subject: Failed to retrieve record: \(error.localizedDescription)")
            handler(nil)
            return
        }
        
        handler(animeSubjects)
    }
    
    class func searchSubjectInLocal(subjectID: Int) -> Bool {
        
        let fetchRequest = NSFetchRequest(entityName: "Subject")
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(subjectID)")
        
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext,
            let subjects = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Subject],
            let _  = subjects.first else {
                
                return false
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("% Subject: Delete error: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
}






















