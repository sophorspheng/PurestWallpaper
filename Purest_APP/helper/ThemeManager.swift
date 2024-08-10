//
//  ThemeManager.swift
//  Note001
//
//  Created by Sophors Pheng on 8/1/24.
//

import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    enum Theme {
        case light
        case dark
    }
    
    var currentTheme: Theme = .light {
        didSet {
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}
