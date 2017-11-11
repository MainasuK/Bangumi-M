//
//  UserDefaults.swift
//  Bangumi M
//
//  Created by Cirno MainasuK on 2017-8-31.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension UserDefaults {
    @objc dynamic var prefersLargeTitlesInNaviagtionBar: Bool {
        return value(forKey: "prefersLargeTitlesInNaviagtionBar") as? Bool ?? true
    }
}
