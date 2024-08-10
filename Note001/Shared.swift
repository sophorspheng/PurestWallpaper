//
//  Shared.swift
//  Note001
//
//  Created by Sophors Pheng on 7/20/24.
//

import Foundation


import Foundation
class UserData {
    static let shared = UserData()
    
    var username: String?
    
    private init() {}
}

