////
////  SearchTableViewController.swift
////  
////
////  Created by Cirno MainasuK on 2015-8-12.
////
////
//
//import UIKit
//import Haneke
//import MJRefresh
//
//
//class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, BangumiTabelViewCellDelegate {
//    
//
//
//
//    
//    // MARK: - Navigation
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let naviVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.animeDetailVC) as! UINavigationController
//        let animeDetailVC = naviVC.childViewControllers.first as! AnimeDetailViewController
//        
////        let item = searchModel.subjectsListAtIndex(indexPath.row)
//        animeDetailVC.navigationItem.title = item.name
//        animeDetailVC.animeItem = Anime(subject: item)
//        animeDetailVC.subjectAllStatus = nil
//        animeDetailVC.animeDetailLarge = nil
//        
//        self.navigationController?.pushViewController(animeDetailVC, animated: true)
//    }
//
//
//
//    // MARK: - BangumiTabelViewCellDelegate
//    
//    func cellCollectionButtonpressed(subjecID: Int) {
//        let collectVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardKey.AnimeCollectVC) as! AnimeCollectTableViewController
//        collectVC.animeItem = Anime(subject: searchModel.subjectsList[subjecID]!)
//        self.navigationController?.pushViewController(collectVC, animated: true)
//        self.searchController.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//}
