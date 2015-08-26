//
//  FavoritesTableViewCell.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-14.
//
//

import UIKit
import CloudKit
import Haneke
import Cosmos

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
//    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var animeImageView: UIImageView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    @IBOutlet weak var watchingLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
//    @IBOutlet weak var favoriteButton: UIButton!
    
//    @IBOutlet weak var cosmosViewFav: CosmosView!
//    @IBOutlet weak var clipView: UIView!
    
    @IBAction func collectionButtonPressed(sender: UIButton) {
        delegate?.cellCollectionButtonpressed(animeItem.id)
    }
    
    @IBAction func moreButtonPressed(sender: AnyObject) {
        debugPrintln("$ SearchTableViewCell: Clip Tapped")
        delegate?.deleteFavoriteButtonPressed(self.cardView)

    }
    
    var animeItem: AnimeSubject!
//    var recordID: CKRecordID!
    var delegate: FavoritesTableViewCellDelegate?
    let request = BangumiRequest.shared
    
    // MARK: - Cell life cycle
    
    internal func initCell() {
        
        debugPrintln("$ SearchTableViewCell init -> \(animeItem.name)")
        nameLabel.text = animeItem.name
        nameCNLabel.text = animeItem.nameCN
        let doingType = ["在看", "在读", "在看", "在听", "在玩", "在看", "在看"]
        watchingLabel.text = "\(animeItem.collection.doing) 人\(doingType[animeItem.type])"

        let typeArr = ["Zero", "书籍", "动画", "音乐", "游戏", "Five", "三次元"]
        typeLabel.text = typeArr[animeItem.type]
        
        animeImageView.layer.borderColor = UIColor.myGrayColor().CGColor
        animeImageView.layer.borderWidth = 1.0
        animeImageView.hnk_setImageFromURL(NSURL(string: animeItem.images.largeUrl)!, placeholder: UIImage(named: "404"))
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
