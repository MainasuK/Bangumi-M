//
//  BangumiFavoriteModel.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-13.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

public class BangumiFavoriteModel {
    
    let container = CKContainer.defaultContainer()
    let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
    
    
    var isCloudAvailiable = false
    var isModelUpToDate = false
    var isFavoriteListLoading = false
    var favoriteList = [AnimeSubject]()
    var favoriteCKRecordList = [CKRecord]()
    /// subjectID : isExist
    var isExistCacheList = [Int : Bool]()
    
    // - MARK: Singleton
    private static let instance = BangumiFavoriteModel()

    private init() {
        
    }

    public static var shared: BangumiFavoriteModel {
        return self.instance
    }

    
    // MARK: - Model method
    public func dropModel() {
        self.favoriteList = [AnimeSubject]()
        self.favoriteCKRecordList = [CKRecord]()
        self.isExistCacheList = [Int : Bool]()
    }
    
    func getFavoriteModel(handler: (Bool) -> Void) {
        debugPrintln("$ BangumiFavoriteModel: Start model fetch method")
        
        getRecordsFromCloud { (success) -> Void in
            handler(success)
        }
    }
    
    func saveSubjectToCloud(subject: AnimeSubject, _ handler: (Bool) -> Void) {
        
        let record = subject.toCKRecord()
        saveRecordToCloud(record) { (success) -> Void in
            
            if success {
                self.isExistCacheList[subject.id] = true
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    
    func deleteSubjectInCloud(index: Int, handler: (Bool) -> Void) {
        
        let selectedRecordID = favoriteCKRecordList[index].recordID
        deleteRecordFromCloud(selectedRecordID) { (success) -> Void in
            
            if success {
                let subjectID = self.favoriteList[index].id
                self.isExistCacheList[subjectID] = false
                self.favoriteCKRecordList.removeAtIndex(index)
                self.favoriteList.removeAtIndex(index)
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    
    func isRecordExistInCloud(subjectID: Int, _ handler: (Bool) -> Void) {
        // search local
        if let isExist = isExistCacheList[subjectID] {
            handler(isExist)
            return
        }
        
        if isModelUpToDate { return }
        
        // Search cloud
        searchRecordsFromCloud(subjectID) { (results) -> Void in

            if results != nil {
                self.isExistCacheList[subjectID] = true
                handler(true)
            } else {
                self.isExistCacheList[subjectID] = false
                handler(false)
            }
        }
    }
    
    public func findSubjectWith(subjectID: Int) -> AnimeSubject? {
        for subject in favoriteList {
            if subject.id == subjectID {
                return subject
            }
        }
        
        return nil
    }

    
    // MARK: - Local method
    
    // Convert records to AnimeSubject Arr
    private func getAnimeSubjectFromRecord(records: [CKRecord]) -> [AnimeSubject] {
        self.isExistCacheList.removeAll()
        var subjectList = [AnimeSubject]()
        
        for record in records {
            let subject = AnimeSubject(record: record)
            subjectList.append(subject)
            self.isExistCacheList[subject.id] = true
        }
        
        return subjectList
    }
    
    // MARK: - CloudKit method
    
    // Fetch all records
    private func getRecordsFromCloud(handler: (Bool) -> Void) {
        // Fetch data using Convenience API
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Subject", predicate: predicate)
        debugPrintln("$ BangumiFavoriteModel: Perforem Query to fetch Subject from cloud")
        privateDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { results, error in
            
            NSNotificationCenter.defaultCenter().postNotificationName("setCloudStatus", object: error?.code)
            if error == nil {
                // success
                debugPrintln("$ BangumiFavoriteModel: Completed the download of Subject data…")
                debugPrintln("$ BangumiFavoriteModel: Fetch \(results.count) record(s)")
                self.favoriteList = self.getAnimeSubjectFromRecord(results as! [CKRecord])
                self.favoriteCKRecordList = results as! [CKRecord]
                self.isModelUpToDate = true
                
                handler(true)
            } else {
                debugPrintln("$ BangumiFavoriteModel: Fetch Subject Records failed…")
                debugPrintln(error)
                
                
                handler(false)
            }
        })
    }

    private func deleteRecordFromCloud(selectedRecordID: CKRecordID, handler: (Bool) -> Void) {
        privateDatabase.deleteRecordWithID(selectedRecordID, completionHandler: { (recordID, error) -> Void in
            if error != nil {
                debugPrintln(error)
                handler(false)
            } else {
                handler(true)
            }
        })
    }
    
//    func getRecordsFromCloud() {
//
//        
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "Subject", predicate: predicate)
//
//        // Create the query operation with the query
//        let queryOperation = CKQueryOperation(query: query)
////        queryOperation.desiredKeys = ["name", "image"]
//        queryOperation.queuePriority = .VeryHigh
////        queryOperation.resultsLimit = 50
//        queryOperation.recordFetchedBlock = { (record: CKRecord!) -> Void in
//            if let subjectRecord = record {
//                self.favoriteList.append(AnimeSubject(record: subjectRecord))
//            }
//        }
//        queryOperation.queryCompletionBlock = { (cursor:CKQueryCursor!, error:NSError!) -> Void in
//            if (error != nil) {
//                println("Failed to get data from iCloud - \(error.localizedDescription)")
//            } else {
//                println("Successfully retrieve the data from iCloud")
////                dispatch_async(dispatch_get_main_queue(), {
////                    self.tableView.reloadData()
////                })
//            }
//        }
//        
//        // Execute the query
//        privateDatabase.addOperation(queryOperation)
//    }
    
    
    
    
    // Search record
    private func searchRecordsFromCloud(subjectID: Int, _ handler: ([AnyObject]?) -> Void) {
                    
        let predicate = NSPredicate(format: "id = %d", subjectID)
        let query = CKQuery(recordType: "Subject", predicate: predicate)
        debugPrintln("$ BangumiFavoriteModel: Search record in Cloud")
        privateDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                // TODO: disable like button and try again
                debugPrintln("$ BangumiFavoriteModel: Search record in cloud failed…")
                debugPrintln(error.localizedDescription)
                handler(nil)
            } else if results.count > 0 {
                debugPrintln("$ BangumiFavoriteModel: Search record in cloud success")
                handler(results)
            } else {
                debugPrintln("$ BangumiFavoriteModel: Search record in cloud success, and no data exist")
                handler(nil)
            }
            
        }
    }
    
    // Save record
    private func saveRecordToCloud(record: CKRecord, handler: (Bool) -> Void) {
        
        debugPrintln("$ BangumiFavoriteModel: Save record to cloud…")
        privateDatabase.saveRecord(record) { (record, error) -> Void in
            
            if error != nil {
                debugPrintln("$ BangumiFavoriteModel: Save record to cloud failed…")
                debugPrintln(error.localizedDescription)
                handler(false)
            } else {
                debugPrintln("$ BangumiFavoriteModel: Save record to cloud success")
                handler(true)
            }
        }
    }
}

