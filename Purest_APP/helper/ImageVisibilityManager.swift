//
//  ImageVisibilityManager.swift
//  Note001
//
//  Created by Sophors Pheng on 8/5/24.
//

import Foundation
class ImageVisibilityManager {
    static let shared = ImageVisibilityManager()
    private init() {}
    
    var isImageHidden: Bool = false
}
