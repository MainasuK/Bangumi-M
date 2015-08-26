//
//  FavoritesTableViewCellDelegate.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2015-8-14.
//  Copyright (c) 2015年 Cirno MainasuK. All rights reserved.
//

import Foundation
import UIKit

protocol FavoritesTableViewCellDelegate: BangumiTabelViewCellDelegate {
    func deleteFavoriteButtonPressed(sender: UIView)
}