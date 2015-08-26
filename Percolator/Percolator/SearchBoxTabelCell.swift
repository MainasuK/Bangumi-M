//
//  SearchBoxTabelCell.swift
//  
//
//  Created by Cirno MainasuK on 2015-8-19.
//
//

import UIKit

class SearchBoxTabelCell: MGSwipeTableCell {
    
    var isSaved = false
    var subject = AnimeSubject()
    
    var headerMaskLayer: CAShapeLayer!
    
    @IBOutlet weak var indecatorView: UIView!
    @IBOutlet weak var animeImageView: UIImageView!
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var airDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameCNLabel: UILabel!
    @IBOutlet weak var doingLabel: UILabel!
    
    
    func initCell() {
        indecatorView.hidden = !isSaved
        
        animeImageView.layer.borderColor = UIColor.myGrayColor().CGColor
        animeImageView.layer.borderWidth = 0.75
        animeImageView.hnk_setImageFromURL(NSURL(string: subject.images.largeUrl)!, placeholder: UIImage(named: "404"))
        
        typeLabel.text = PercolatorKey.typeArr[subject.type]
        airDateLabel.text = (subject.airDate == "0000-00-00") ? "" : subject.airDate
        nameLabel.text = subject.name
        nameCNLabel.text = subject.nameCN
        
        let doingArr = PercolatorKey.typeDoingArr[subject.type]!
        doingLabel.text = "\(subject.collection.doing) 人\(doingArr[2])"
        
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.blackColor().CGColor
        let path = UIBezierPath()
        let width = indecatorView.frame.width
        path.moveToPoint(CGPoint(x: 0.0, y: 0.0))
        path.addLineToPoint(CGPoint(x: width, y: 0))
        path.addLineToPoint(CGPoint(x: 0, y: width + 2))    // That's a trick
        headerMaskLayer?.path = path.CGPath
        indecatorView.layer.mask = headerMaskLayer
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
