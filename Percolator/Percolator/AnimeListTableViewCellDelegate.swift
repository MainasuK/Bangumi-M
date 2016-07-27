//
//  AnimeListTableViewCellDelegate.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-23.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import UIKit

protocol AnimeListTableViewCellDelegate: class {
    
    func watchedButtonPressed(_ sender: UIButton, with mark: AnimeMark)
    
}

enum AnimeMark {
    case none
    case episode(Episode, Subject)
    case subject(Subject)
}
