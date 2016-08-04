//
//  Subject.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-12.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

typealias SubjectID = Int

struct Subject {
    
    var responseGroup: ResponseGroup = .none
    
    let id: SubjectID
    let url: String
    let type: Int
    let name: String
    let nameCN: String
    let summary: String
    let eps: Int // Depend of responseGroup type
    
    let airDate: String
    let airWeekday: Int
    
    let rank: Int
    
    let images: Images
    let collection: Collection
    let rating: Rating
    
    /// responseGroup medium or large
    let crts: [Crt]
    let staffs: [Staff]
    
    /// responseGroup Large only
    // TODO: topic
    // TODO: blog
    
    /// responseGroup Large only
    private let EPS: [Episode]
    var epTable: [Episode] { return EPS.filter { $0.type == .ep } }
    var spTable: [Episode] { return EPS.filter { $0.type == .sp } }
    var opTable: [Episode] { return EPS.filter { $0.type == .op } }
    var edTable: [Episode] { return EPS.filter { $0.type == .ed } }
    
    var epTableReversed: [Episode] { return epTable.reversed() }
    
    init(from json: JSON, of responseGroup: ResponseGroup = .none) {
        id = json[BangumiKey.id].int!
        url = json[BangumiKey.url].string!
        type = json[BangumiKey.type].int!
        name = json[BangumiKey.name].stringValue.replaceEscapes()
        nameCN = json[BangumiKey.nameCN].stringValue.replaceEscapes()
        summary = json[BangumiKey.summary].stringValue.replaceEscapes()
        
        airDate = json[BangumiKey.airDate].stringValue.replacingOccurrences(of: "0000-00-00", with: "")
        airWeekday = json[BangumiKey.airWeekday].int!
        
        rank = json[BangumiKey.rank].int!
        
        let imageDict = json[BangumiKey.subjectImages].dictionaryValue
        images = Images(json: imageDict)
        
        let collectionDict = json[BangumiKey.subjectCollection].dictionaryValue
        collection = Collection(json: collectionDict)
        
        let ratingDict = json[BangumiKey.subjectRating].dictionaryValue
        rating = Rating(json: ratingDict)
        
        // For responseGroup large
        crts = json[BangumiKey.subjectCrt].arrayValue.map { Crt(from: $0) }
        staffs = json[BangumiKey.staffDict].arrayValue.map { Staff(from: $0) }
        
        let EPSArray = json[BangumiKey.eps].arrayValue.map { Episode(from: $0) }
        EPS = EPSArray
        eps = json[BangumiKey.eps].intValue ?? EPSArray.count
    }
    
    init(from cdSubject: CDSubject) {
        id = Int(cdSubject.id)
        url = cdSubject.url ?? ""
        type = Int(cdSubject.type)
        name = cdSubject.name ?? ""
        nameCN = cdSubject.nameCN ?? ""
        summary = cdSubject.summary ?? ""
        eps = Int(cdSubject.eps)
        
        airDate = cdSubject.airDate ?? ""
        airWeekday = Int(cdSubject.airWeekday)
        
        rank = Int(cdSubject.rank)
        
        images = Images(from: cdSubject.images)
        collection = Collection(from: cdSubject.collection)
        rating = Rating(from: cdSubject.rating)
        
        crts = []
        staffs = []
        EPS = []
    }
    
    func isSaved() -> Bool {
        let fetchRequest: NSFetchRequest<CDSubject> = CDSubject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.context,
        let cdSubjects = try? context.fetch(fetchRequest), !cdSubjects.isEmpty else {
            return false
        }
        
        return true
    }
    
    func saveToCoreData() -> Bool {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.context else {
            return false
        }
        
        guard let cdSubject = NSEntityDescription.insertNewObject(forEntityName: "CDSubject", into: context) as? CDSubject,
        let cdCollection = NSEntityDescription.insertNewObject(forEntityName: "CDCollection", into: context) as? CDCollection,
        let cdImages = NSEntityDescription.insertNewObject(forEntityName: "CDImages", into: context) as? CDImages,
        let cdRating = NSEntityDescription.insertNewObject(forEntityName: "CDRating", into: context) as? CDRating else {
            
            context.reset()
            return false
        }

        cdSubject.airDate = airDate
        cdSubject.airWeekday = Int64(airWeekday)
        cdSubject.eps = Int64(eps)
        cdSubject.id = Int64(id)
        cdSubject.name = name
        cdSubject.nameCN = nameCN
        cdSubject.rank = Int64(rank)
        cdSubject.summary = summary
        cdSubject.type = Int64(type)
        cdSubject.url = url
        
        cdCollection.collect = Int64(collection.collect)
        cdCollection.doing = Int64(collection.doing)
        cdCollection.dropped = Int64(collection.dropped)
        cdCollection.onHold = Int64(collection.onHold)
        cdCollection.wish = Int64(collection.wish)
        cdSubject.collection = cdCollection
        
        cdImages.commonUrl = images.commonUrl
        cdImages.gridUrl = images.gridUrl
        cdImages.largeUrl = images.largeUrl
        cdImages.mediumUrl = images.mediumUrl
        cdImages.smallUrl = images.smallUrl
        cdSubject.images = cdImages

        cdRating.count = rating.count
        cdRating.score = rating.score
        cdRating.total = Int64(rating.total)
        cdSubject.rating = cdRating
        do {
            try context.save()
            return true
            
        } catch {
            context.reset()
            consolePrint(error)
            return false
        }
    }
    
    func deleteFromCoreData() -> Bool {
        let fetchRequest: NSFetchRequest<CDSubject> = CDSubject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.context else {
            return false
            
        }
        
        guard let subjects = try? context.fetch(fetchRequest),
        let subject = subjects.first else {
            context.reset()
            return false
        }

        do {
            context.delete(subject)
            try context.save()
            
            return true
        } catch {
            context.reset()
            consolePrint(error)
            return false
        }
    }

}

extension Subject {

    enum ResponseGroup {
        case large
        case medium
        case small
        
        case none
    }
}

extension String {
    
    private func replaceEscapes() -> String {
        return self.replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "&amp;", with: "&")
    }

}



//    // FIXME: Swift2.0 error handle need here (throws)
//    class func fetchSubject(handler: ([AnimeSubject]?) -> Void) {
//        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext else {
//            
//            handler(nil)
//            return
//        }
//        
//        let fetchRequest = NSFetchRequest(entityName: "Subject")
//        var subjects = [Subject]()
//        var animeSubjects = [AnimeSubject]()
//        
//        do {
//            subjects = (try managedObjectContext.executeFetchRequest(fetchRequest)) as! [Subject]
//            for subject in subjects {
//                animeSubjects.append(AnimeSubject(subject: subject))
//            }
//        } catch let error as NSError {
//            NSLog("% Subject: Failed to retrieve record: \(error.localizedDescription)")
//            handler(nil)
//            return
//        }
//        
//        handler(animeSubjects)
//    }
//    
//    class func searchSubjectInLocal(subjectID: Int) -> Bool {
//        
//        let fetchRequest = NSFetchRequest(entityName: "Subject")
//        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(subjectID)")
//        
//        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext,
//            let subjects = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Subject],
//            let _  = subjects.first else {
//                
//                return false
//        }
//        
//        do {
//            try managedObjectContext.save()
//        } catch let error as NSError {
//            NSLog("% Subject: Delete error: \(error.localizedDescription)")
//            return false
//        }
//        
//        return true
//    }
//}
